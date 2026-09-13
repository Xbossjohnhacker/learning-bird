import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/dashboard/data/dashboard_repository.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';

void main() {
  test('一万条单词和复习计划下核心查询保持可用', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final bookId = await database
        .into(database.wordBooks)
        .insert(WordBooksCompanion.insert(name: '压力测试词书'));
    final dueAt = DateTime.now().subtract(const Duration(minutes: 1)).toUtc();

    await database.batch((batch) {
      batch.insertAll(
        database.words,
        List.generate(
          10000,
          (index) => WordsCompanion(
            id: Value(index + 1),
            word: Value('word$index'),
            normalizedWord: Value('word$index'),
            meaning: Value('释义$index'),
          ),
          growable: false,
        ),
      );
      batch.insertAll(
        database.wordBookItems,
        List.generate(
          10000,
          (index) => WordBookItemsCompanion(
            id: Value(index + 1),
            wordBookId: Value(bookId),
            wordId: Value(index + 1),
          ),
          growable: false,
        ),
      );
      batch.insertAll(
        database.reviewSchedules,
        List.generate(
          10000,
          (index) => ReviewSchedulesCompanion(
            wordBookItemId: Value(index + 1),
            dueAt: Value(dueAt),
          ),
          growable: false,
        ),
      );
    });

    final stopwatch = Stopwatch()..start();
    final queue = await VocabularyRepository(
      database,
    ).loadStudyQueue(bookId, limit: 100);
    final summary = await DashboardRepository(
      database,
    ).watchTodaySummary().first;
    stopwatch.stop();

    expect(queue, hasLength(100));
    expect(summary.dueWords, 10000);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
