import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

void main() {
  late AppDatabase database;
  late VocabularyRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VocabularyRepository(database);
  });

  tearDown(() => database.close());

  test('同一批单词可以重复导入并形成两个独立批次', () async {
    final bookId = await repository.createWordBook('考研核心词');
    const rows = [
      WordImportRow(word: 'persist', meaning: '坚持'),
      WordImportRow(word: 'derive', meaning: '获得；源自'),
    ];

    final first = await repository.importRows(
      wordBookId: bookId,
      fileName: 'words.csv',
      sourceType: 'csv',
      sourceFingerprint: 'same-fingerprint',
      rows: rows,
      duplicateStrategy: DuplicateStrategy.skip,
    );
    final second = await repository.importRows(
      wordBookId: bookId,
      fileName: 'words.csv',
      sourceType: 'csv',
      sourceFingerprint: 'same-fingerprint',
      rows: rows,
      duplicateStrategy: DuplicateStrategy.skip,
    );

    expect(first.successCount, 2);
    expect(second.skippedCount, 2);
    expect(await database.select(database.importRecords).get(), hasLength(2));
    expect(await database.select(database.wordBookItems).get(), hasLength(2));
  });

  test('复习反馈会写入记录并更新下次复习时间', () async {
    final bookId = await repository.createWordBook('测试词书');
    await repository.importRows(
      wordBookId: bookId,
      fileName: 'one.csv',
      sourceType: 'csv',
      sourceFingerprint: 'one',
      rows: const [WordImportRow(word: 'focus', meaning: '专注')],
      duplicateStrategy: DuplicateStrategy.skip,
    );
    final word = (await repository.loadStudyQueue(bookId)).single;
    final reviewedAt = DateTime.utc(2026, 8, 26, 8);

    // Reuse the same snapshot to ensure persisted progress is authoritative.
    for (var i = 0; i < 2; i++) {
      final pending = await repository.recordReview(
        word: word,
        rating: ReviewRating.remembered,
        reviewedAt: reviewedAt,
      );
      expect(pending.needsConfirmation, isTrue);
    }
    final decision = await repository.recordReview(
      word: word,
      rating: ReviewRating.remembered,
      reviewedAt: reviewedAt,
    );

    expect(decision.dueAt, reviewedAt.add(const Duration(days: 3)));
    expect(await database.select(database.reviewRecords).get(), hasLength(3));
    final schedule = await database
        .select(database.reviewSchedules)
        .getSingle();
    expect(schedule.intervalDays, 3);
  });

  test('删除词书会级联清除关联数据和学习记录', () async {
    final bookId = await repository.createWordBook('待删除词书');
    await repository.importRows(
      wordBookId: bookId,
      fileName: 'delete.csv',
      sourceType: 'csv',
      sourceFingerprint: 'delete',
      rows: const [WordImportRow(word: 'remove', meaning: '删除')],
      duplicateStrategy: DuplicateStrategy.skip,
    );
    final word = (await repository.loadStudyQueue(bookId)).single;
    await repository.recordReview(word: word, rating: ReviewRating.remembered);

    await repository.deleteWordBook(bookId);

    expect(await database.select(database.wordBooks).get(), isEmpty);
    expect(await database.select(database.wordBookItems).get(), isEmpty);
    expect(await database.select(database.reviewSchedules).get(), isEmpty);
    expect(await database.select(database.reviewRecords).get(), isEmpty);
    expect(await database.select(database.importRecords).get(), isEmpty);
    expect(await database.select(database.words).get(), hasLength(1));
  });
}
