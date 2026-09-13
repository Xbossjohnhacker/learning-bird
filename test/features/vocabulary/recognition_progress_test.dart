import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/backup/backup_repository.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  late int bookId;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VocabularyRepository(db);
    bookId = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: bookId, word: 'focus', meaning: '专注');
  });
  tearDown(() => db.close());

  test('三次通过，后续一次通过，遗忘后重新三次并保留历史', () async {
    final stale = (await repository.loadStudyQueue(bookId)).single;
    for (var i = 1; i <= 3; i++) {
      final result = await repository.recordReview(
        word: stale,
        rating: ReviewRating.remembered,
      );
      expect(result.needsConfirmation, i < 3);
      expect(await repository.loadStudyQueue(bookId), hasLength(i < 3 ? 1 : 0));
    }
    await db
        .update(db.reviewSchedules)
        .write(
          ReviewSchedulesCompanion(
            dueAt: Value(DateTime.now().subtract(const Duration(days: 1))),
          ),
        );
    final reviewWord = (await repository.loadStudyQueue(bookId)).single;
    expect(reviewWord.needsConfirmation, isFalse);
    final once = await repository.recordReview(
      word: reviewWord,
      rating: ReviewRating.remembered,
    );
    expect(once.needsConfirmation, isFalse);
    expect(once.streak, 2);
    expect(once.intervalDays, 6);

    final reset = await repository.recordReview(
      word: stale,
      rating: ReviewRating.forgot,
    );
    expect(reset.learningState, 'learning_0');
    expect(reset.streak, 0);
    expect(reset.lapseCount, 1);
    expect(
      (await repository.loadStudyQueue(bookId)).single.confirmationCount,
      0,
    );
    for (var i = 1; i <= 3; i++) {
      final result = await repository.recordReview(
        word: stale,
        rating: ReviewRating.remembered,
      );
      expect(result.needsConfirmation, i < 3);
    }
    expect(await db.select(db.reviewRecords).get(), hasLength(8));
    expect((await db.select(db.reviewSchedules).getSingle()).intervalDays, 3);
  });

  test('两次认识进度随备份恢复，恢复后再一次即可通过', () async {
    final original = (await repository.loadStudyQueue(bookId)).single;
    await repository.recordReview(
      word: original,
      rating: ReviewRating.remembered,
    );
    await repository.recordReview(
      word: original,
      rating: ReviewRating.remembered,
    );
    final backup = await BackupRepository(db).createBackup();
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final restored = db;
    await BackupRepository(restored).restoreBackup(backup);
    final restoredRepository = VocabularyRepository(restored);
    final pending = (await restoredRepository.loadStudyQueue(bookId)).single;
    expect(pending.confirmationCount, 2);
    expect(pending.needsConfirmation, isTrue);
    expect(
      (await restoredRepository.watchWordBooks().first).single.dueCount,
      1,
    );
    final result = await restoredRepository.recordReview(
      word: pending,
      rating: ReviewRating.remembered,
    );
    expect(result.needsConfirmation, isFalse);
    expect(await restoredRepository.loadStudyQueue(bookId), isEmpty);
  });

  test('不同词书中的相同单词确认进度独立', () async {
    final other = await repository.createWordBook('另一本');
    await repository.addWord(wordBookId: other, word: 'focus', meaning: '专注');
    final word = (await repository.loadStudyQueue(bookId)).single;
    await repository.recordReview(word: word, rating: ReviewRating.remembered);
    await repository.recordReview(word: word, rating: ReviewRating.remembered);
    expect(
      (await repository.loadStudyQueue(bookId)).single.confirmationCount,
      2,
    );
    expect(
      (await repository.loadStudyQueue(other)).single.confirmationCount,
      0,
    );
  });
}
