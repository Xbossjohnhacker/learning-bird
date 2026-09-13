import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this.database);

  final AppDatabase database;

  Stream<TodaySummary> watchTodaySummary() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toUtc();
    final end = DateTime(now.year, now.month, now.day + 1).toUtc();
    final current = now.toUtc();
    return database
        .customSelect(
          '''
SELECT
  (SELECT COUNT(*) FROM plans
   WHERE deleted_at IS NULL AND starts_at >= ? AND starts_at < ?) AS plan_total,
  (SELECT COUNT(*) FROM plans
   WHERE deleted_at IS NULL AND starts_at >= ? AND starts_at < ?
     AND status = 'completed') AS plan_completed,
  (SELECT COUNT(*) FROM review_schedules rs
   JOIN word_book_items wbi ON wbi.id = rs.word_book_item_id
   WHERE (wbi.learning_state IN ('learning_0', 'learning_1', 'learning_2') OR rs.due_at <= ?)
     AND wbi.suspended_at IS NULL) AS due_words,
  (SELECT COUNT(DISTINCT word_book_item_id) FROM review_records
   WHERE reviewed_at >= ? AND reviewed_at < ?) AS reviewed_words,
  (SELECT COUNT(*) FROM pomodoro_sessions
   WHERE phase = 'focus' AND status = 'completed'
     AND completed_at >= ? AND completed_at < ?) AS pomodoro_count,
  (SELECT COALESCE(SUM(actual_duration_ms), 0) FROM pomodoro_sessions
   WHERE phase = 'focus' AND status = 'completed'
     AND completed_at >= ? AND completed_at < ?) AS focus_ms,
  (SELECT title FROM plans
   WHERE deleted_at IS NULL AND starts_at >= ? AND starts_at < ?
     AND status IN ('pending', 'in_progress')
   ORDER BY starts_at LIMIT 1) AS next_plan_title,
  (SELECT starts_at FROM plans
   WHERE deleted_at IS NULL AND starts_at >= ? AND starts_at < ?
     AND status IN ('pending', 'in_progress')
   ORDER BY starts_at LIMIT 1) AS next_plan_at
''',
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(current),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            Variable.withDateTime(end),
          ],
          readsFrom: {
            database.plans,
            database.reviewSchedules,
            database.reviewRecords,
            database.wordBookItems,
            database.pomodoroSessions,
          },
        )
        .watchSingle()
        .map(
          (row) => TodaySummary(
            planTotal: row.read<int>('plan_total'),
            planCompleted: row.read<int>('plan_completed'),
            dueWords: row.read<int>('due_words'),
            reviewedWords: row.read<int>('reviewed_words'),
            pomodoroCount: row.read<int>('pomodoro_count'),
            focusMinutes: row.read<int>('focus_ms') ~/ 60000,
            nextPlanTitle: row.readNullable<String>('next_plan_title'),
            nextPlanAt: row.readNullable<DateTime>('next_plan_at')?.toLocal(),
          ),
        );
  }

  Future<StatisticsSummary> loadStatistics(StatisticsPeriod period) async {
    final buckets = _buckets(period);
    final rangeStart = buckets.first.start.toUtc();
    final rangeEnd = buckets.last.end.toUtc();

    final results = await Future.wait([
      database
          .customSelect(
            '''
SELECT completed_at FROM plans
WHERE deleted_at IS NULL AND status = 'completed'
  AND completed_at >= ? AND completed_at < ?
''',
            variables: [
              Variable.withDateTime(rangeStart),
              Variable.withDateTime(rangeEnd),
            ],
            readsFrom: {database.plans},
          )
          .get(),
      database
          .customSelect(
            '''
SELECT reviewed_at, word_book_item_id FROM review_records
WHERE reviewed_at >= ? AND reviewed_at < ?
''',
            variables: [
              Variable.withDateTime(rangeStart),
              Variable.withDateTime(rangeEnd),
            ],
            readsFrom: {database.reviewRecords},
          )
          .get(),
      database
          .customSelect(
            '''
SELECT completed_at, actual_duration_ms FROM pomodoro_sessions
WHERE phase = 'focus' AND status = 'completed'
  AND completed_at >= ? AND completed_at < ?
''',
            variables: [
              Variable.withDateTime(rangeStart),
              Variable.withDateTime(rangeEnd),
            ],
            readsFrom: {database.pomodoroSessions},
          )
          .get(),
    ]);

    final plans = results[0];
    final reviews = results[1];
    final sessions = results[2];
    final points = <StatisticsPoint>[];

    for (final bucket in buckets) {
      bool contains(DateTime value) {
        final local = value.toLocal();
        return !local.isBefore(bucket.start) && local.isBefore(bucket.end);
      }

      final completedPlans = plans
          .where((row) => contains(row.read<DateTime>('completed_at')))
          .length;
      final reviewedItems = <int>{
        for (final row in reviews)
          if (contains(row.read<DateTime>('reviewed_at')))
            row.read<int>('word_book_item_id'),
      };
      final focusMs = sessions
          .where((row) => contains(row.read<DateTime>('completed_at')))
          .fold<int>(
            0,
            (sum, row) => sum + row.read<int>('actual_duration_ms'),
          );
      points.add(
        StatisticsPoint(
          label: bucket.label,
          focusMinutes: focusMs ~/ 60000,
          completedPlans: completedPlans,
          reviewedWords: reviewedItems.length,
        ),
      );
    }

    return StatisticsSummary(
      points: points,
      totalFocusMinutes: points.fold(
        0,
        (sum, point) => sum + point.focusMinutes,
      ),
      completedPlans: points.fold(
        0,
        (sum, point) => sum + point.completedPlans,
      ),
      reviewedWords: points.fold(0, (sum, point) => sum + point.reviewedWords),
    );
  }

  List<_StatisticsBucket> _buckets(StatisticsPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      StatisticsPeriod.daily => List.generate(7, (index) {
        final start = today.subtract(Duration(days: 6 - index));
        return _StatisticsBucket(
          start: start,
          end: start.add(const Duration(days: 1)),
          label: '${start.month}/${start.day}',
        );
      }),
      StatisticsPeriod.weekly => () {
        final monday = today.subtract(Duration(days: today.weekday - 1));
        return List.generate(8, (index) {
          final start = monday.subtract(Duration(days: 49 - index * 7));
          return _StatisticsBucket(
            start: start,
            end: start.add(const Duration(days: 7)),
            label: '${start.month}/${start.day}',
          );
        });
      }(),
      StatisticsPeriod.monthly => List.generate(6, (index) {
        final start = DateTime(now.year, now.month - 5 + index);
        final end = DateTime(start.year, start.month + 1);
        return _StatisticsBucket(
          start: start,
          end: end,
          label: '${start.month}月',
        );
      }),
    };
  }
}

class _StatisticsBucket {
  const _StatisticsBucket({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;
}
