import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/navigation.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/notifications/in_app_reminder_host.dart';
import 'package:learning_bird/core/notifications/plan_notification_service.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_providers.dart';
import 'package:learning_bird/features/pomodoro/domain/pomodoro_models.dart';

class _RecordingNotificationService extends PlanNotificationService {
  final cancelled = <int?>[];

  @override
  Future<void> cancel(int? id) async => cancelled.add(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('计划和番茄钟提醒通过同一队列依次展示', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PlansRepository(database);
    final notifications = _RecordingNotificationService();
    await repository.createPlan(
      PlanDraft(
        title: '排队中的计划提醒',
        startsAt: DateTime.now().add(const Duration(minutes: 5)),
        estimatedMinutes: 30,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.none,
        reminderOffsetMinutes: 10,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        plansRepositoryProvider.overrideWithValue(repository),
        planNotificationServiceProvider.overrideWithValue(notifications),
        inAppReminderIntervalProvider.overrideWithValue(
          const Duration(days: 1),
        ),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const InAppReminderHost(child: Scaffold(body: Text('首页'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('计划提醒'), findsOneWidget);

    container
        .read(pomodoroFinishedEventProvider.notifier)
        .state = const PomodoroFinishedEvent(
      sessionId: 2,
      finishedPhase: PomodoroPhase.focus,
      nextPhase: PomodoroPhase.shortBreak,
    );
    await tester.pump();
    expect(find.text('专注时间结束'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, '知道了'));
    await tester.pumpAndSettle();
    expect(find.text('计划提醒'), findsNothing);
    expect(find.text('专注时间结束'), findsOneWidget);
    expect(notifications.cancelled, [100001]);

    await tester.tap(find.widgetWithText(TextButton, '稍后休息'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('应用处于后台时不认领计划提醒', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PlansRepository(database);
    final notifications = _RecordingNotificationService();
    await repository.createPlan(
      PlanDraft(
        title: '仅系统通知展示',
        startsAt: DateTime.now().add(const Duration(minutes: 5)),
        estimatedMinutes: 30,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.none,
        reminderOffsetMinutes: 10,
      ),
    );
    addTearDown(database.close);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          plansRepositoryProvider.overrideWithValue(repository),
          planNotificationServiceProvider.overrideWithValue(notifications),
          inAppReminderIntervalProvider.overrideWithValue(
            const Duration(days: 1),
          ),
        ],
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: const InAppPlanReminderHost(child: Scaffold(body: Text('首页'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('计划提醒'), findsNothing);
    expect(notifications.cancelled, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('计划提醒'), findsOneWidget);
    expect(notifications.cancelled, [100001]);

    await tester.tap(find.widgetWithText(TextButton, '知道了'));
    await tester.pumpAndSettle();
  });
}
