import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/dashboard/data/dashboard_repository.dart';
import 'package:learning_bird/features/dashboard/domain/dashboard_models.dart';

void main() {
  late AppDatabase database;
  late DashboardRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DashboardRepository(database);
  });

  tearDown(() => database.close());

  test('今日汇总会聚合计划、单词和专注数据', () async {
    final now = DateTime.now();
    final todayAtNine = DateTime(now.year, now.month, now.day, 9).toUtc();
    await database
        .into(database.plans)
        .insert(
          PlansCompanion.insert(
            title: '英语阅读',
            startsAt: todayAtNine,
            status: const Value('completed'),
            completedAt: Value(todayAtNine.add(const Duration(minutes: 30))),
          ),
        );
    await database
        .into(database.plans)
        .insert(
          PlansCompanion.insert(
            title: '数学真题',
            startsAt: todayAtNine.add(const Duration(hours: 2)),
          ),
        );
    final itemId = await _insertWordItem(database);
    await database
        .into(database.reviewSchedules)
        .insert(
          ReviewSchedulesCompanion.insert(
            wordBookItemId: Value(itemId),
            dueAt: now.subtract(const Duration(minutes: 5)).toUtc(),
          ),
        );
    await database
        .into(database.reviewRecords)
        .insert(
          ReviewRecordsCompanion.insert(
            wordBookItemId: itemId,
            rating: 'good',
            reviewedAt: now.toUtc(),
            nextDueAt: now.add(const Duration(days: 1)).toUtc(),
          ),
        );
    await database
        .into(database.pomodoroSessions)
        .insert(
          PomodoroSessionsCompanion.insert(
            phase: const Value('focus'),
            status: const Value('completed'),
            startedAt: now.subtract(const Duration(minutes: 25)).toUtc(),
            targetEndAt: now.toUtc(),
            completedAt: Value(now.toUtc()),
            actualDurationMs: Value(const Duration(minutes: 25).inMilliseconds),
          ),
        );

    final summary = await repository.watchTodaySummary().first;

    expect(summary.planTotal, 2);
    expect(summary.planCompleted, 1);
    expect(summary.dueWords, 1);
    expect(summary.reviewedWords, 1);
    expect(summary.pomodoroCount, 1);
    expect(summary.focusMinutes, 25);
    expect(summary.nextPlanTitle, '数学真题');
    expect(summary.planProgress, 0.5);
  });

  test('按日统计返回最近七天并汇总学习成果', () async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.plans)
        .insert(
          PlansCompanion.insert(
            title: '政治复习',
            startsAt: now,
            status: const Value('completed'),
            completedAt: Value(now),
          ),
        );
    final itemId = await _insertWordItem(database);
    await database
        .into(database.reviewRecords)
        .insert(
          ReviewRecordsCompanion.insert(
            wordBookItemId: itemId,
            rating: 'easy',
            reviewedAt: now,
            nextDueAt: now.add(const Duration(days: 2)),
          ),
        );
    await database
        .into(database.pomodoroSessions)
        .insert(
          PomodoroSessionsCompanion.insert(
            phase: const Value('focus'),
            status: const Value('completed'),
            startedAt: now.subtract(const Duration(minutes: 40)),
            targetEndAt: now,
            completedAt: Value(now),
            actualDurationMs: Value(const Duration(minutes: 40).inMilliseconds),
          ),
        );

    final statistics = await repository.loadStatistics(StatisticsPeriod.daily);

    expect(statistics.points, hasLength(7));
    expect(statistics.completedPlans, 1);
    expect(statistics.reviewedWords, 1);
    expect(statistics.totalFocusMinutes, 40);
  });
}

Future<int> _insertWordItem(AppDatabase database) async {
  final bookId = await database
      .into(database.wordBooks)
      .insert(WordBooksCompanion.insert(name: '测试词书'));
  final wordId = await database
      .into(database.words)
      .insert(
        WordsCompanion.insert(
          word: 'focus',
          normalizedWord: 'focus',
          meaning: '专注',
        ),
      );
  return database
      .into(database.wordBookItems)
      .insert(
        WordBookItemsCompanion.insert(wordBookId: bookId, wordId: wordId),
      );
}
