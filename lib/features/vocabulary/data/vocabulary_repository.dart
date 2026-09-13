import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/review_scheduler.dart';
import '../domain/manual_word_validator.dart';
import '../domain/word_import.dart';
import '../domain/builtin_word_book.dart';

class DailyStudyProgress {
  const DailyStudyProgress({
    required this.goal,
    required this.completed,
    required this.hasMore,
  });
  final int goal;
  final int completed;
  final bool hasMore;
  bool get goalReached => completed >= goal;
  int get remaining => (goal - completed).clamp(0, goal);
}

class WordBookSummary {
  const WordBookSummary({
    required this.id,
    required this.name,
    required this.totalCount,
    required this.newCount,
    required this.dueCount,
  });

  final int id;
  final String name;
  final int totalCount;
  final int newCount;
  final int dueCount;
}

class BookWord {
  const BookWord({required this.id, required this.word, required this.meaning});
  final int id;
  final String word;
  final String meaning;
}

class MistakeWord {
  const MistakeWord({required this.studyWord, required this.wordBookName});

  final StudyWord studyWord;
  final String wordBookName;
}

class StudyWord {
  const StudyWord({
    required this.itemId,
    required this.word,
    required this.meaning,
    required this.streak,
    required this.lapseCount,
    this.learningState = 'new',
    this.lastRating,
    this.phonetic,
    this.example,
    this.exampleTranslation,
    this.phrase,
    this.note,
  });

  final int itemId;
  final String word;
  final String meaning;
  final int streak;
  final int lapseCount;
  final String learningState;
  final String? lastRating;
  bool get needsConfirmation =>
      ReviewScheduler.needsConfirmation(learningState, lastRating);
  int get confirmationCount => ReviewScheduler.confirmationCount(learningState);

  StudyWord afterReview(ReviewDecision decision, ReviewRating rating) =>
      StudyWord(
        itemId: itemId,
        word: word,
        meaning: meaning,
        streak: decision.streak,
        lapseCount: decision.lapseCount,
        learningState: decision.learningState,
        lastRating: rating.storageValue,
        phonetic: phonetic,
        example: example,
        exampleTranslation: exampleTranslation,
        phrase: phrase,
        note: note,
      );
  final String? phonetic;
  final String? example;
  final String? exampleTranslation;
  final String? phrase;
  final String? note;
}

class VocabularyRepository {
  VocabularyRepository(this.database);

  final AppDatabase database;
  static const _uuid = Uuid();

  Stream<List<WordBookSummary>> watchWordBooks() {
    final now = DateTime.now().toUtc();
    return database
        .customSelect(
          '''
SELECT wb.id, wb.name,
       COUNT(wbi.id) AS total_count,
       SUM(CASE WHEN wbi.learning_state = 'new' THEN 1 ELSE 0 END) AS new_count,
       SUM(CASE WHEN wbi.learning_state IN ('learning_0', 'learning_1', 'learning_2') OR rs.due_at <= ? THEN 1 ELSE 0 END) AS due_count
FROM word_books wb
LEFT JOIN word_book_items wbi ON wbi.word_book_id = wb.id
LEFT JOIN review_schedules rs ON rs.word_book_item_id = wbi.id
WHERE wb.deleted_at IS NULL
GROUP BY wb.id, wb.name
ORDER BY wb.is_archived, wb.created_at DESC
''',
          variables: [Variable.withDateTime(now)],
          readsFrom: {
            database.wordBooks,
            database.wordBookItems,
            database.reviewSchedules,
          },
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => WordBookSummary(
                  id: row.read<int>('id'),
                  name: row.read<String>('name'),
                  totalCount: row.read<int>('total_count'),
                  newCount: row.read<int>('new_count'),
                  dueCount: row.read<int>('due_count'),
                ),
              )
              .toList(growable: false),
        );
  }

  /// Browse all book entries, including learned, suspended and not-yet-due words.
  /// This is deliberately independent of the limited daily study queue.
  Stream<List<BookWord>> watchBookWords(int wordBookId) {
    return database
        .customSelect(
          '''
SELECT w.id, w.word, w.meaning
FROM word_book_items item
JOIN words w ON w.id = item.word_id
JOIN word_books book ON book.id = item.word_book_id
WHERE item.word_book_id = ? AND book.deleted_at IS NULL
ORDER BY w.normalized_word, w.id
''',
          variables: [Variable.withInt(wordBookId)],
          readsFrom: {
            database.wordBookItems,
            database.words,
            database.wordBooks,
          },
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => BookWord(
                  id: row.read<int>('id'),
                  word: row.read<String>('word'),
                  meaning: row.read<String>('meaning'),
                ),
              )
              .toList(growable: false),
        );
  }

  /// Words that were answered incorrectly and have not completed the
  /// three-recognition recovery cycle yet.
  Stream<List<MistakeWord>> watchMistakeWords() {
    return database
        .customSelect(
          '''
SELECT wbi.id AS item_id, wb.name AS book_name, w.word, w.meaning,
       w.phonetic, w.example, w.example_translation, w.phrase, w.note,
       wbi.learning_state, rs.last_rating, rs.last_reviewed_at,
       COALESCE(rs.streak, 0) AS streak,
       COALESCE(rs.lapse_count, 0) AS lapse_count
FROM review_schedules rs
JOIN word_book_items wbi ON wbi.id = rs.word_book_item_id
JOIN word_books wb ON wb.id = wbi.word_book_id
JOIN words w ON w.id = wbi.word_id
WHERE wb.deleted_at IS NULL
  AND wbi.suspended_at IS NULL
  AND rs.lapse_count > 0
  AND wbi.learning_state IN ('learning_0', 'learning_1', 'learning_2')
ORDER BY rs.lapse_count DESC, rs.last_reviewed_at DESC, w.normalized_word
''',
          readsFrom: {
            database.reviewSchedules,
            database.wordBookItems,
            database.wordBooks,
            database.words,
          },
        )
        .watch()
        .map((rows) => rows.map(_mistakeWordFromRow).toList(growable: false));
  }

  Future<List<StudyWord>> loadMistakeStudyQueue({int limit = 200}) async {
    final rows = await database
        .customSelect(
          '''
SELECT wbi.id AS item_id, wb.name AS book_name, w.word, w.meaning,
       w.phonetic, w.example, w.example_translation, w.phrase, w.note,
       wbi.learning_state, rs.last_rating, rs.last_reviewed_at,
       COALESCE(rs.streak, 0) AS streak,
       COALESCE(rs.lapse_count, 0) AS lapse_count
FROM review_schedules rs
JOIN word_book_items wbi ON wbi.id = rs.word_book_item_id
JOIN word_books wb ON wb.id = wbi.word_book_id
JOIN words w ON w.id = wbi.word_id
WHERE wb.deleted_at IS NULL
  AND wbi.suspended_at IS NULL
  AND rs.lapse_count > 0
  AND wbi.learning_state IN ('learning_0', 'learning_1', 'learning_2')
ORDER BY rs.lapse_count DESC, rs.last_reviewed_at, w.normalized_word
LIMIT ?
''',
          variables: [Variable.withInt(limit)],
          readsFrom: {
            database.reviewSchedules,
            database.wordBookItems,
            database.wordBooks,
            database.words,
          },
        )
        .get();
    return rows
        .map((row) => _mistakeWordFromRow(row).studyWord)
        .toList(growable: false);
  }

  MistakeWord _mistakeWordFromRow(QueryRow row) => MistakeWord(
    wordBookName: row.read<String>('book_name'),
    studyWord: StudyWord(
      itemId: row.read<int>('item_id'),
      word: row.read<String>('word'),
      meaning: row.read<String>('meaning'),
      streak: row.read<int>('streak'),
      lapseCount: row.read<int>('lapse_count'),
      learningState: row.read<String>('learning_state'),
      lastRating: row.readNullable<String>('last_rating'),
      phonetic: row.readNullable<String>('phonetic'),
      example: row.readNullable<String>('example'),
      exampleTranslation: row.readNullable<String>('example_translation'),
      phrase: row.readNullable<String>('phrase'),
      note: row.readNullable<String>('note'),
    ),
  );

  Future<int> createWordBook(String name) {
    return database
        .into(database.wordBooks)
        .insert(WordBooksCompanion.insert(name: name.trim()));
  }

  Future<int> installBuiltinWordBook(
    BuiltinWordBook book,
    List<WordImportRow> rows,
  ) async {
    final seen = <String>{};
    if (rows.isEmpty ||
        rows.length != book.count ||
        rows.any(
          (row) =>
              row.word.trim().isEmpty ||
              row.word.trim().length > 120 ||
              row.meaning.trim().isEmpty ||
              !seen.add(row.word.trim().toLowerCase()),
        )) {
      throw const FormatException('内置词库内容不完整');
    }
    return database.transaction(() async {
      // Names belong to users; only the stable source marker identifies a preset.
      final existing =
          await (database.select(database.wordBooks)..where(
                (row) =>
                    row.description.equals(book.storageMarker) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (existing != null) return existing.id;

      final id = await database
          .into(database.wordBooks)
          .insert(
            WordBooksCompanion.insert(
              name: book.name,
              description: Value(book.storageMarker),
            ),
          );
      // Shared words retain user edits. New books receive independent learning state.
      await database.batch(
        (batch) => batch.insertAll(database.words, [
          for (final row in rows)
            WordsCompanion.insert(
              word: row.word.trim(),
              normalizedWord: row.word.trim().toLowerCase(),
              meaning: row.meaning.trim(),
            ),
        ], mode: InsertMode.insertOrIgnore),
      );
      final normalized = seen.toList(growable: false);
      final wordIds = <int>[];
      for (var start = 0; start < normalized.length; start += 400) {
        final end = (start + 400).clamp(0, normalized.length);
        final found =
            await (database.select(database.words)..where(
                  (row) =>
                      row.normalizedWord.isIn(normalized.sublist(start, end)),
                ))
                .get();
        wordIds.addAll(found.map((word) => word.id));
      }
      if (wordIds.length != rows.length) throw StateError('内置词库写入不完整');
      await database.batch(
        (batch) => batch.insertAll(database.wordBookItems, [
          for (final wordId in wordIds)
            WordBookItemsCompanion.insert(wordBookId: id, wordId: wordId),
        ]),
      );
      return id;
    });
  }

  Future<void> addWord({
    required int wordBookId,
    required String word,
    required String meaning,
  }) async {
    final error =
        ManualWordValidator.wordError(word) ??
        ManualWordValidator.meaningError(meaning);
    if (error != null) throw FormatException(error);
    final text = ManualWordValidator.normalizeWord(word);
    final definition = meaning.trim();
    await database.transaction(() async {
      final book =
          await (database.select(database.wordBooks)..where(
                (row) => row.id.equals(wordBookId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (book == null) throw const FormatException('词书已不存在，请返回刷新');
      final existing =
          await (database.select(database.words)
                ..where((row) => row.normalizedWord.equals(text.toLowerCase())))
              .getSingleOrNull();
      int wordId;
      if (existing != null) {
        final relation =
            await (database.select(database.wordBookItems)..where(
                  (row) =>
                      row.wordBookId.equals(wordBookId) &
                      row.wordId.equals(existing.id),
                ))
                .getSingleOrNull();
        if (relation != null) throw const FormatException('这本词书中已有该单词，无需重复添加');
        if (existing.meaning.trim() != definition) {
          throw FormatException(
            '其他词书已收录该单词，意思为“${existing.meaning}”。请使用相同意思添加，避免改动其他词书。',
          );
        }
        wordId = existing.id;
      } else {
        wordId = await database
            .into(database.words)
            .insert(
              WordsCompanion.insert(
                word: text,
                normalizedWord: text.toLowerCase(),
                meaning: definition,
              ),
            );
      }
      await database
          .into(database.wordBookItems)
          .insert(
            WordBookItemsCompanion.insert(
              wordBookId: wordBookId,
              wordId: wordId,
            ),
          );
    });
  }

  Future<void> deleteWordBook(int wordBookId) async {
    await database.transaction(() async {
      await (database.delete(
        database.wordBooks,
      )..where((book) => book.id.equals(wordBookId))).go();
      await (database.delete(database.appSettings)..where(
            (setting) => setting.key.equals('wordbook_daily_goal_$wordBookId'),
          ))
          .go();
    });
  }

  Future<ImportBatchResult> importRows({
    required int wordBookId,
    required String fileName,
    required String sourceType,
    required String sourceFingerprint,
    required List<WordImportRow> rows,
    required DuplicateStrategy duplicateStrategy,
  }) {
    return database.transaction(() async {
      final batchUuid = _uuid.v4();
      final startedAt = DateTime.now().toUtc();
      final importId = await database
          .into(database.importRecords)
          .insert(
            ImportRecordsCompanion.insert(
              batchUuid: batchUuid,
              fileName: fileName,
              sourceFingerprint: Value(sourceFingerprint),
              sourceType: sourceType,
              targetWordBookId: wordBookId,
              startedAt: startedAt,
              totalRows: Value(rows.length),
            ),
          );

      var success = 0;
      var skipped = 0;
      var failed = 0;

      for (var index = 0; index < rows.length; index++) {
        final row = rows[index];
        try {
          final normalized = row.word.trim().toLowerCase();
          final wordQuery = database.select(database.words)
            ..where((word) => word.normalizedWord.equals(normalized));
          var existing = await wordQuery.getSingleOrNull();

          if (existing == null) {
            final wordId = await database
                .into(database.words)
                .insert(
                  WordsCompanion.insert(
                    word: row.word.trim(),
                    normalizedWord: normalized,
                    meaning: row.meaning.trim(),
                    phonetic: Value(row.phonetic),
                    example: Value(row.example),
                    exampleTranslation: Value(row.exampleTranslation),
                    phrase: Value(row.phrase),
                    note: Value(row.note),
                    tags: Value(row.tags),
                  ),
                );
            existing = await (database.select(
              database.words,
            )..where((word) => word.id.equals(wordId))).getSingle();
          }

          final relationQuery = database.select(database.wordBookItems)
            ..where(
              (item) =>
                  item.wordBookId.equals(wordBookId) &
                  item.wordId.equals(existing!.id),
            );
          final relation = await relationQuery.getSingleOrNull();

          if (relation != null && duplicateStrategy == DuplicateStrategy.skip) {
            skipped++;
            continue;
          }

          if (duplicateStrategy == DuplicateStrategy.overwrite) {
            await (database.update(
              database.words,
            )..where((word) => word.id.equals(existing!.id))).write(
              WordsCompanion(
                word: Value(row.word.trim()),
                meaning: Value(row.meaning.trim()),
                phonetic: Value(row.phonetic),
                example: Value(row.example),
                exampleTranslation: Value(row.exampleTranslation),
                phrase: Value(row.phrase),
                note: Value(row.note),
                tags: Value(row.tags),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
          }

          if (relation == null) {
            await database
                .into(database.wordBookItems)
                .insert(
                  WordBookItemsCompanion.insert(
                    wordBookId: wordBookId,
                    wordId: existing.id,
                  ),
                );
          }
          success++;
        } on Object catch (error) {
          failed++;
          await database
              .into(database.importErrors)
              .insert(
                ImportErrorsCompanion.insert(
                  importRecordId: importId,
                  sourceRow: index + 2,
                  errorCode: 'row_write_failed',
                  message: error.toString(),
                  rawData: Value(row.word),
                ),
              );
        }
      }

      await (database.update(
        database.importRecords,
      )..where((record) => record.id.equals(importId))).write(
        ImportRecordsCompanion(
          finishedAt: Value(DateTime.now().toUtc()),
          successCount: Value(success),
          skippedCount: Value(skipped),
          failedCount: Value(failed),
          status: const Value('completed'),
        ),
      );

      return ImportBatchResult(
        batchUuid: batchUuid,
        successCount: success,
        skippedCount: skipped,
        failedCount: failed,
      );
    });
  }

  Future<void> saveDailyGoal(int wordBookId, int goal) async {
    if (goal < 1 || goal > 1000) {
      throw const FormatException('每天学习词数应为 1–1000 的整数');
    }
    await database.transaction(() async {
      final book =
          await (database.select(database.wordBooks)..where(
                (row) => row.id.equals(wordBookId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (book == null) throw StateError('词书已不存在');
      // Separate total target; existing new/review fields retain their meaning.
      await database.putSetting('wordbook_daily_goal_$wordBookId', '$goal');
    });
  }

  Future<DailyStudyProgress> loadDailyProgress(
    int wordBookId, {
    DateTime? now,
  }) async {
    final local = (now ?? DateTime.now()).toLocal();
    final start = DateTime(local.year, local.month, local.day).toUtc();
    final end = DateTime(local.year, local.month, local.day + 1).toUtc();
    final saved = int.tryParse(
      await database.readSetting('wordbook_daily_goal_$wordBookId') ?? '',
    );
    final goal = saved != null && saved >= 1 && saved <= 1000 ? saved : 20;
    // A passed word advances its due date; the first two confirmations do not.
    // DISTINCT ensures repeated answers for one book entry count only once/day.
    final row = await database
        .customSelect(
          '''
SELECT COUNT(DISTINCT r.word_book_item_id) AS completed
FROM review_records r
JOIN word_book_items item ON item.id = r.word_book_item_id
WHERE item.word_book_id = ? AND r.reviewed_at >= ? AND r.reviewed_at < ?
  AND r.rating IN ('remembered', 'mastered', 'already_known') AND r.next_due_at > r.reviewed_at
''',
          variables: [
            Variable.withInt(wordBookId),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
          ],
        )
        .getSingle();
    final available = await loadStudyQueue(wordBookId, limit: 1, now: local);
    return DailyStudyProgress(
      goal: goal,
      completed: row.read<int>('completed'),
      hasMore: available.isNotEmpty,
    );
  }

  Future<List<StudyWord>> loadDailyStudyQueue(
    int wordBookId, {
    bool extra = false,
    DateTime? now,
  }) {
    return database.transaction(() async {
      final progress = await loadDailyProgress(wordBookId, now: now);
      final limit = extra ? progress.goal : progress.remaining;
      if (limit == 0) return <StudyWord>[];
      return loadStudyQueue(wordBookId, limit: limit, now: now);
    });
  }

  Future<List<StudyWord>> loadStudyQueue(
    int wordBookId, {
    int limit = 20,
    DateTime? now,
  }) async {
    final rows = await database
        .customSelect(
          '''
SELECT wbi.id AS item_id, w.word, w.meaning, w.phonetic, w.example,
       w.example_translation, w.phrase, w.note, wbi.learning_state, rs.last_rating,
       COALESCE(rs.streak, 0) AS streak,
       COALESCE(rs.lapse_count, 0) AS lapse_count
FROM word_book_items wbi
JOIN words w ON w.id = wbi.word_id
LEFT JOIN review_schedules rs ON rs.word_book_item_id = wbi.id
WHERE wbi.word_book_id = ?
  AND wbi.suspended_at IS NULL
  AND (wbi.learning_state IN ('new', 'learning_0', 'learning_1', 'learning_2') OR rs.due_at <= ?)
ORDER BY CASE WHEN rs.due_at IS NULL THEN 1 ELSE 0 END, rs.due_at, wbi.id
LIMIT ?
''',
          variables: [
            Variable.withInt(wordBookId),
            Variable.withDateTime((now ?? DateTime.now()).toUtc()),
            Variable.withInt(limit),
          ],
          readsFrom: {
            database.wordBookItems,
            database.words,
            database.reviewSchedules,
          },
        )
        .get();

    return rows
        .map(
          (row) => StudyWord(
            itemId: row.read<int>('item_id'),
            word: row.read<String>('word'),
            meaning: row.read<String>('meaning'),
            streak: row.read<int>('streak'),
            lapseCount: row.read<int>('lapse_count'),
            learningState: row.read<String>('learning_state'),
            lastRating: row.readNullable<String>('last_rating'),
            phonetic: row.readNullable<String>('phonetic'),
            example: row.readNullable<String>('example'),
            exampleTranslation: row.readNullable<String>('example_translation'),
            phrase: row.readNullable<String>('phrase'),
            note: row.readNullable<String>('note'),
          ),
        )
        .toList(growable: false);
  }

  /// Loads words for an independent test session. Correct test answers do not
  /// advance the spaced-repetition schedule; callers may record wrong answers
  /// with [recordReview] so they enter the mistake book.
  Future<List<StudyWord>> loadTestQueue(
    int wordBookId, {
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 100) {
      throw const FormatException('单次测试词数应为 1–100');
    }
    final rows = await database
        .customSelect(
          '''
SELECT wbi.id AS item_id, w.word, w.meaning, w.phonetic, w.example,
       w.example_translation, w.phrase, w.note, wbi.learning_state,
       rs.last_rating, COALESCE(rs.streak, 0) AS streak,
       COALESCE(rs.lapse_count, 0) AS lapse_count
FROM word_book_items wbi
JOIN word_books wb ON wb.id = wbi.word_book_id
JOIN words w ON w.id = wbi.word_id
LEFT JOIN review_schedules rs ON rs.word_book_item_id = wbi.id
WHERE wbi.word_book_id = ?
  AND wb.deleted_at IS NULL
  AND wbi.suspended_at IS NULL
ORDER BY RANDOM()
LIMIT ?
''',
          variables: [Variable.withInt(wordBookId), Variable.withInt(limit)],
          readsFrom: {
            database.wordBookItems,
            database.wordBooks,
            database.words,
            database.reviewSchedules,
          },
        )
        .get();
    return rows.map(_studyWordFromRow).toList(growable: false);
  }

  StudyWord _studyWordFromRow(QueryRow row) => StudyWord(
    itemId: row.read<int>('item_id'),
    word: row.read<String>('word'),
    meaning: row.read<String>('meaning'),
    streak: row.read<int>('streak'),
    lapseCount: row.read<int>('lapse_count'),
    learningState: row.read<String>('learning_state'),
    lastRating: row.readNullable<String>('last_rating'),
    phonetic: row.readNullable<String>('phonetic'),
    example: row.readNullable<String>('example'),
    exampleTranslation: row.readNullable<String>('example_translation'),
    phrase: row.readNullable<String>('phrase'),
    note: row.readNullable<String>('note'),
  );

  Future<ReviewDecision> recordReview({
    required StudyWord word,
    required ReviewRating rating,
    DateTime? reviewedAt,
  }) {
    return database.transaction(() async {
      final time = (reviewedAt ?? DateTime.now()).toUtc();
      // Always read persisted progress: a card snapshot may predate prior answers.
      final item = await (database.select(
        database.wordBookItems,
      )..where((item) => item.id.equals(word.itemId))).getSingleOrNull();
      if (item == null) throw StateError('该单词已不在词书中');
      final schedule =
          await (database.select(database.reviewSchedules)
                ..where((row) => row.wordBookItemId.equals(word.itemId)))
              .getSingleOrNull();
      final decision = ReviewScheduler.next(
        rating: rating,
        reviewedAt: time,
        currentStreak: schedule?.streak ?? 0,
        currentLapseCount: schedule?.lapseCount ?? 0,
        learningState: item.learningState,
        lastRating: schedule?.lastRating,
      );

      await database
          .into(database.reviewSchedules)
          .insertOnConflictUpdate(
            ReviewSchedulesCompanion.insert(
              wordBookItemId: Value(word.itemId),
              dueAt: decision.dueAt,
              intervalDays: Value(decision.intervalDays),
              streak: Value(decision.streak),
              lapseCount: Value(decision.lapseCount),
              lastRating: Value(rating.storageValue),
              lastReviewedAt: Value(time),
            ),
          );
      await database
          .into(database.reviewRecords)
          .insert(
            ReviewRecordsCompanion.insert(
              wordBookItemId: word.itemId,
              rating: rating.storageValue,
              reviewedAt: time,
              previousDueAt: Value(schedule?.dueAt),
              nextDueAt: decision.dueAt,
            ),
          );
      await (database.update(
        database.wordBookItems,
      )..where((item) => item.id.equals(word.itemId))).write(
        WordBookItemsCompanion(learningState: Value(decision.learningState)),
      );
      return decision;
    });
  }
}
