import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/pomodoro_models.dart';

class RestoredPomodoroSession {
  const RestoredPomodoroSession({
    required this.id,
    required this.phase,
    required this.status,
    required this.startedAt,
    required this.targetEndAt,
    required this.pausedTotalMs,
    this.pausedAt,
    this.planId,
    this.planTitle,
  });

  final int id;
  final PomodoroPhase phase;
  final String status;
  final DateTime startedAt;
  final DateTime targetEndAt;
  final DateTime? pausedAt;
  final int pausedTotalMs;
  final int? planId;
  final String? planTitle;
}

class PomodoroRepository {
  PomodoroRepository(this.database);

  final AppDatabase database;

  Future<PomodoroSettings> loadSettings() async {
    int read(String? value, int fallback) =>
        int.tryParse(value ?? '') ?? fallback;
    return PomodoroSettings(
      focusMinutes: read(
        await database.readSetting('pomodoro_focus_minutes'),
        25,
      ),
      shortBreakMinutes: read(
        await database.readSetting('pomodoro_short_break_minutes'),
        5,
      ),
      longBreakMinutes: read(
        await database.readSetting('pomodoro_long_break_minutes'),
        15,
      ),
      longBreakEvery: read(
        await database.readSetting('pomodoro_long_break_every'),
        4,
      ),
    );
  }

  Future<void> saveSettings(PomodoroSettings settings) async {
    await database.transaction(() async {
      await database.putSetting(
        'pomodoro_focus_minutes',
        settings.focusMinutes.toString(),
      );
      await database.putSetting(
        'pomodoro_short_break_minutes',
        settings.shortBreakMinutes.toString(),
      );
      await database.putSetting(
        'pomodoro_long_break_minutes',
        settings.longBreakMinutes.toString(),
      );
      await database.putSetting(
        'pomodoro_long_break_every',
        settings.longBreakEvery.toString(),
      );
    });
  }

  Future<int> startSession({
    required PomodoroPhase phase,
    required DateTime startedAt,
    required DateTime targetEndAt,
    int? planId,
  }) {
    return database
        .into(database.pomodoroSessions)
        .insert(
          PomodoroSessionsCompanion.insert(
            planId: Value(planId),
            phase: Value(phase.storageValue),
            startedAt: startedAt.toUtc(),
            targetEndAt: targetEndAt.toUtc(),
          ),
        );
  }

  Future<RestoredPomodoroSession?> loadActiveSession() async {
    final row = await database
        .customSelect(
          '''
SELECT ps.*, p.title AS plan_title
FROM pomodoro_sessions ps
LEFT JOIN plans p ON p.id = ps.plan_id
WHERE ps.status IN ('running', 'paused')
ORDER BY ps.started_at DESC
LIMIT 1
''',
          readsFrom: {database.pomodoroSessions, database.plans},
        )
        .getSingleOrNull();
    if (row == null) return null;
    return RestoredPomodoroSession(
      id: row.read<int>('id'),
      phase: PomodoroPhase.fromStorage(row.read<String>('phase')),
      status: row.read<String>('status'),
      startedAt: row.read<DateTime>('started_at').toLocal(),
      targetEndAt: row.read<DateTime>('target_end_at').toLocal(),
      pausedAt: row.readNullable<DateTime>('paused_at')?.toLocal(),
      pausedTotalMs: row.read<int>('paused_total_ms'),
      planId: row.readNullable<int>('plan_id'),
      planTitle: row.readNullable<String>('plan_title'),
    );
  }

  Future<void> pauseSession(int id, DateTime pausedAt) {
    return (database.update(
      database.pomodoroSessions,
    )..where((session) => session.id.equals(id))).write(
      PomodoroSessionsCompanion(
        status: const Value('paused'),
        pausedAt: Value(pausedAt.toUtc()),
      ),
    );
  }

  Future<DateTime> resumeSession(
    RestoredPomodoroSession session,
    DateTime resumedAt,
  ) async {
    final pausedAt = session.pausedAt ?? resumedAt;
    final pauseDuration = resumedAt.difference(pausedAt);
    final targetEndAt = session.targetEndAt.add(pauseDuration);
    await (database.update(
      database.pomodoroSessions,
    )..where((row) => row.id.equals(session.id))).write(
      PomodoroSessionsCompanion(
        status: const Value('running'),
        pausedAt: const Value(null),
        targetEndAt: Value(targetEndAt.toUtc()),
        pausedTotalMs: Value(
          session.pausedTotalMs + pauseDuration.inMilliseconds,
        ),
      ),
    );
    return targetEndAt;
  }

  Future<void> completeSession({
    required int id,
    required PomodoroPhase phase,
    required DateTime startedAt,
    required int pausedTotalMs,
    required DateTime completedAt,
    required int? planId,
    String status = 'completed',
  }) {
    return database.transaction(() async {
      final actualMs =
          completedAt.difference(startedAt).inMilliseconds - pausedTotalMs;
      await (database.update(
        database.pomodoroSessions,
      )..where((session) => session.id.equals(id))).write(
        PomodoroSessionsCompanion(
          status: Value(status),
          completedAt: Value(completedAt.toUtc()),
          actualDurationMs: Value(actualMs.clamp(0, 86400000)),
        ),
      );
      if (status == 'completed' &&
          phase == PomodoroPhase.focus &&
          planId != null) {
        final minutes = (actualMs / 60000).round().clamp(0, 1440);
        final plan = await (database.select(
          database.plans,
        )..where((row) => row.id.equals(planId))).getSingleOrNull();
        if (plan != null) {
          await (database.update(
            database.plans,
          )..where((row) => row.id.equals(planId))).write(
            PlansCompanion(
              actualMinutes: Value(plan.actualMinutes + minutes),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      }
    });
  }

  Future<int> completedFocusCountToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toUtc();
    final end = DateTime(now.year, now.month, now.day + 1).toUtc();
    final count = database.pomodoroSessions.id.count();
    final query = database.selectOnly(database.pomodoroSessions)
      ..addColumns([count])
      ..where(
        database.pomodoroSessions.phase.equals('focus') &
            database.pomodoroSessions.status.equals('completed') &
            database.pomodoroSessions.startedAt.isBiggerOrEqualValue(start) &
            database.pomodoroSessions.startedAt.isSmallerThanValue(end),
      );
    return (await query.getSingle()).read(count) ?? 0;
  }

  Stream<List<FocusPlanOption>> watchAvailablePlans({int? courseScheduleId}) {
    return (database.select(database.plans)
          ..where(
            (plan) =>
                plan.deletedAt.isNull() &
                plan.status.isIn(['pending', 'in_progress']) &
                (courseScheduleId == null
                    ? plan.courseScheduleId.isNull()
                    : plan.courseScheduleId.isNull() |
                          plan.courseScheduleId.equals(courseScheduleId)),
          )
          ..orderBy([(plan) => OrderingTerm.asc(plan.startsAt)])
          ..limit(30))
        .watch()
        .map(
          (rows) => rows
              .map(
                (plan) => FocusPlanOption(
                  id: plan.id,
                  title: plan.title,
                  courseScheduleId: plan.courseScheduleId,
                ),
              )
              .toList(growable: false),
        );
  }
}
