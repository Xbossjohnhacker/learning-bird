import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/backup/backup_repository.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repo;
  final today = DateTime(2026, 8, 30, 12);
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = VocabularyRepository(db);
  });
  tearDown(() => db.close());

  Future<int> seed() async {
    final id = await repo.createWordBook('英语');
    await repo.importRows(
      wordBookId: id,
      fileName: 'test.csv',
      sourceType: 'csv',
      sourceFingerprint: 'test',
      rows: const [
        WordImportRow(word: 'focus', meaning: '专注'),
        WordImportRow(word: 'persist', meaning: '坚持'),
        WordImportRow(word: 'learn', meaning: '学习'),
      ],
      duplicateStrategy: DuplicateStrategy.skip,
    );
    return id;
  }

  Future<void> pass(StudyWord word, DateTime at) async {
    for (var i = 0; i < 3; i++) {
      await repo.recordReview(
        word: word,
        rating: ReviewRating.remembered,
        reviewedAt: at,
      );
    }
  }

  test('目标按词书保存、验证范围并支持提高或降低目标', () async {
    final a = await seed();
    final b = await seed();
    expect((await repo.loadDailyProgress(a, now: today)).goal, 20);
    await repo.saveDailyGoal(a, 1);
    await repo.saveDailyGoal(b, 2);
    expect(await repo.loadDailyStudyQueue(a, now: today), hasLength(1));
    expect(await repo.loadDailyStudyQueue(b, now: today), hasLength(2));
    for (final invalid in [0, -1, 1001]) {
      await expectLater(repo.saveDailyGoal(a, invalid), throwsFormatException);
    }
    await pass((await repo.loadDailyStudyQueue(a, now: today)).first, today);
    expect(await repo.loadDailyStudyQueue(a, now: today), isEmpty);
    expect((await repo.loadDailyProgress(b, now: today)).completed, 0);
    await repo.saveDailyGoal(a, 3);
    expect(await repo.loadDailyStudyQueue(a, now: today), hasLength(2));
    await repo.saveDailyGoal(a, 1);
    expect((await repo.loadDailyProgress(a, now: today)).completed, 1);
    expect(
      await repo.loadDailyStudyQueue(a, now: today, extra: true),
      hasLength(1),
    );
  });

  test('三次认识仅计一个词，额外学习可超过目标且不抽取未到期词', () async {
    final id = await seed();
    await repo.saveDailyGoal(id, 1);
    final first = (await repo.loadDailyStudyQueue(id, now: today)).single;
    for (var i = 0; i < 2; i++) {
      await repo.recordReview(
        word: first,
        rating: ReviewRating.remembered,
        reviewedAt: today,
      );
      expect((await repo.loadDailyProgress(id, now: today)).completed, 0);
    }
    await repo.recordReview(
      word: first,
      rating: ReviewRating.remembered,
      reviewedAt: today,
    );
    expect((await repo.loadDailyProgress(id, now: today)).completed, 1);
    for (var i = 0; i < 2; i++) {
      final extra = (await repo.loadDailyStudyQueue(
        id,
        now: today,
        extra: true,
      )).single;
      expect(extra.itemId, isNot(first.itemId));
      await pass(extra, today);
    }
    expect((await repo.loadDailyProgress(id, now: today)).completed, 3);
    expect((await repo.loadDailyProgress(id, now: today)).hasMore, isFalse);
    expect(
      await repo.loadDailyStudyQueue(id, now: today, extra: true),
      isEmpty,
    );
    // Duplicate successful records still count one entry per local calendar day.
    await repo.recordReview(
      word: first,
      rating: ReviewRating.remembered,
      reviewedAt: today,
    );
    expect((await repo.loadDailyProgress(id, now: today)).completed, 3);
  });

  test('本地午夜重新计数，未完成确认仍保留，到期复习优先', () async {
    final id = await seed();
    await repo.saveDailyGoal(id, 2);
    final before = DateTime(2026, 8, 30, 23, 59, 59);
    final after = DateTime(2026, 8, 31);
    final words = await repo.loadDailyStudyQueue(id, now: before);
    await pass(words.first, before);
    await repo.recordReview(
      word: words.last,
      rating: ReviewRating.remembered,
      reviewedAt: before,
    );
    expect((await repo.loadDailyProgress(id, now: before)).completed, 1);
    expect((await repo.loadDailyProgress(id, now: after)).completed, 0);
    final nextDay = await repo.loadDailyStudyQueue(id, now: after);
    expect(nextDay, hasLength(2));
    expect(nextDay.first.itemId, words.last.itemId);
    expect(nextDay.first.confirmationCount, 1);
    await repo.recordReview(
      word: words.last,
      rating: ReviewRating.remembered,
      reviewedAt: after,
    );
    await repo.recordReview(
      word: words.last,
      rating: ReviewRating.remembered,
      reviewedAt: after,
    );
    expect((await repo.loadDailyProgress(id, now: after)).completed, 1);
    final dueDay = before.add(const Duration(days: 3));
    final review = (await repo.loadDailyStudyQueue(id, now: dueDay)).first;
    expect(review.itemId, words.first.itemId);
    await repo.recordReview(
      word: review,
      rating: ReviewRating.remembered,
      reviewedAt: dueDay,
    );
    expect((await repo.loadDailyProgress(id, now: dueDay)).completed, 1);
  });

  test('目标和当天计数随备份恢复，删除词书清理专属设置', () async {
    final id = await seed();
    await repo.saveDailyGoal(id, 1);
    await pass((await repo.loadDailyStudyQueue(id, now: today)).single, today);
    final backup = await BackupRepository(db).createBackup();
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final restored = db;
    await BackupRepository(restored).restoreBackup(backup);
    final repository = VocabularyRepository(restored);
    final progress = await repository.loadDailyProgress(id, now: today);
    expect(progress.goal, 1);
    expect(progress.completed, 1);
    expect(await repository.loadDailyStudyQueue(id, now: today), isEmpty);
    await repository.deleteWordBook(id);
    expect(await restored.readSetting('wordbook_daily_goal_$id'), isNull);
  });

  test('跳过已认识记录随备份保存，仅作用于当前词书且后续复习一次通过', () async {
    final a = await seed();
    final b = await seed();
    await repo.saveDailyGoal(a, 1);
    final word = (await repo.loadDailyStudyQueue(a, now: today)).single;
    final skipped = await repo.recordReview(
      word: word,
      rating: ReviewRating.alreadyKnown,
      reviewedAt: today,
    );
    expect(skipped.needsConfirmation, isFalse);
    expect((await repo.loadDailyProgress(a, now: today)).completed, 1);
    expect((await repo.loadDailyProgress(b, now: today)).completed, 0);
    expect(
      (await repo.loadStudyQueue(
        b,
      )).every((word) => word.learningState == 'new'),
      isTrue,
    );
    final backup = await BackupRepository(db).createBackup();
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = VocabularyRepository(db);
    await BackupRepository(db).restoreBackup(backup);
    expect(
      (await db.select(db.reviewRecords).getSingle()).rating,
      'already_known',
    );
    expect((await repo.loadDailyProgress(a, now: today)).completed, 1);
    final next = today.add(const Duration(days: 3));
    final review = (await repo.loadDailyStudyQueue(a, now: next)).single;
    expect(review.itemId, word.itemId);
    final passed = await repo.recordReview(
      word: review,
      rating: ReviewRating.remembered,
      reviewedAt: next,
    );
    expect(passed.needsConfirmation, isFalse);
    expect(passed.intervalDays, 6);
  });
}
