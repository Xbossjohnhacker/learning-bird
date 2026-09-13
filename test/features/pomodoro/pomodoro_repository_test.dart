import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_providers.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_repository.dart';
import 'package:learning_bird/features/pomodoro/domain/pomodoro_models.dart';

void main() {
  late AppDatabase database;
  late PomodoroRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PomodoroRepository(database);
  });

  tearDown(() => database.close());

  test('暂停再恢复会按暂停时长顺延目标结束时间', () async {
    final started = DateTime(2026, 8, 27, 8);
    final target = started.add(const Duration(minutes: 25));
    final id = await repository.startSession(
      phase: PomodoroPhase.focus,
      startedAt: started,
      targetEndAt: target,
    );

    await repository.pauseSession(id, started.add(const Duration(minutes: 5)));
    final paused = await repository.loadActiveSession();
    final resumedTarget = await repository.resumeSession(
      paused!,
      started.add(const Duration(minutes: 8)),
    );

    expect(resumedTarget, target.add(const Duration(minutes: 3)));
    final restored = await repository.loadActiveSession();
    expect(restored!.status, 'running');
    expect(restored.pausedTotalMs, const Duration(minutes: 3).inMilliseconds);
  });

  test('完成关联计划的专注会累计实际学习时长', () async {
    final planId = await database
        .into(database.plans)
        .insert(
          PlansCompanion.insert(
            title: '数学真题',
            startsAt: DateTime.utc(2026, 8, 27, 8),
          ),
        );
    final started = DateTime.utc(2026, 8, 27, 8);
    final id = await repository.startSession(
      phase: PomodoroPhase.focus,
      startedAt: started,
      targetEndAt: started.add(const Duration(minutes: 25)),
      planId: planId,
    );

    await repository.completeSession(
      id: id,
      phase: PomodoroPhase.focus,
      startedAt: started,
      pausedTotalMs: 0,
      completedAt: started.add(const Duration(minutes: 25)),
      planId: planId,
    );

    final plan = await (database.select(
      database.plans,
    )..where((row) => row.id.equals(planId))).getSingle();
    expect(plan.actualMinutes, 25);
    final session = await database
        .select(database.pomodoroSessions)
        .getSingle();
    expect(session.status, 'completed');
    expect(
      session.actualDurationMs,
      const Duration(minutes: 25).inMilliseconds,
    );
  });

  test('自定义计时设置可在重启后恢复', () async {
    const settings = PomodoroSettings(
      focusMinutes: 45,
      shortBreakMinutes: 10,
      longBreakMinutes: 20,
      longBreakEvery: 3,
    );

    await repository.saveSettings(settings);
    final restored = await repository.loadSettings();

    expect(restored.focusMinutes, 45);
    expect(restored.shortBreakMinutes, 10);
    expect(restored.longBreakMinutes, 20);
    expect(restored.longBreakEvery, 3);
  });

  test('关联候选只包含普通计划和当前课表课程', () async {
    final firstSchedule = await database
        .into(database.courseSchedules)
        .insert(
          CourseSchedulesCompanion.insert(
            name: '第一课表',
            sourceType: 'web:first',
          ),
        );
    final secondSchedule = await database
        .into(database.courseSchedules)
        .insert(
          CourseSchedulesCompanion.insert(
            name: '第二课表',
            sourceType: 'web:second',
          ),
        );
    Future<void> addPlan(String title, {int? scheduleId}) {
      return database
          .into(database.plans)
          .insert(
            PlansCompanion.insert(
              title: title,
              startsAt: DateTime.utc(2026, 9, 14, 8),
              courseScheduleId: Value(scheduleId),
            ),
          )
          .then((_) {});
    }

    await addPlan('普通计划');
    await addPlan('第一课程', scheduleId: firstSchedule);
    await addPlan('第二课程', scheduleId: secondSchedule);

    final first = await repository
        .watchAvailablePlans(courseScheduleId: firstSchedule)
        .first;
    expect(first.map((item) => item.title), containsAll(['普通计划', '第一课程']));
    expect(first.map((item) => item.title), isNot(contains('第二课程')));
    expect(first.singleWhere((item) => item.title == '第一课程').isCourse, isTrue);

    final plansOnly = await repository.watchAvailablePlans().first;
    expect(plansOnly.map((item) => item.title), ['普通计划']);
  });

  test('切换当前课表会同步刷新关联候选', () async {
    final firstSchedule = await database
        .into(database.courseSchedules)
        .insert(
          CourseSchedulesCompanion.insert(
            name: '第一课表',
            sourceType: 'web:provider-first',
          ),
        );
    final secondSchedule = await database
        .into(database.courseSchedules)
        .insert(
          CourseSchedulesCompanion.insert(
            name: '第二课表',
            sourceType: 'web:provider-second',
          ),
        );
    for (final entry in [('第一课程', firstSchedule), ('第二课程', secondSchedule)]) {
      await database
          .into(database.plans)
          .insert(
            PlansCompanion.insert(
              title: entry.$1,
              startsAt: DateTime.utc(2026, 9, 14, 8),
              courseScheduleId: Value(entry.$2),
            ),
          );
    }
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        selectedCourseScheduleIdProvider.overrideWith((ref) => firstSchedule),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      availableFocusPlansProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final first = await container.read(availableFocusPlansProvider.future);
    expect(first.map((item) => item.title), ['第一课程']);

    container.read(selectedCourseScheduleIdProvider.notifier).state =
        secondSchedule;
    final second = await container.read(availableFocusPlansProvider.future);
    expect(second.map((item) => item.title), ['第二课程']);
  });
}
