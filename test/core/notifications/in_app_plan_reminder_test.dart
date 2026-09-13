import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/navigation.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/notifications/in_app_plan_reminder.dart';
import 'package:learning_bird/core/notifications/plan_notification_service.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';

class _RecordingNotificationService extends PlanNotificationService {
  final cancelled = <int?>[];

  @override
  Future<void> cancel(int? id) async => cancelled.add(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('计划到时在前台弹窗并取消对应系统通知', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PlansRepository(database);
    final notifications = _RecordingNotificationService();
    await repository.createPlan(
      PlanDraft(
        title: '英语阅读提醒',
        startsAt: DateTime.now().add(const Duration(minutes: 5)),
        estimatedMinutes: 45,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.none,
        reminderOffsetMinutes: 10,
      ),
    );

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
    expect(find.text('计划提醒'), findsOneWidget);
    expect(find.text('英语阅读提醒'), findsOneWidget);
    expect(notifications.cancelled, [100001]);

    await tester.tap(find.widgetWithText(TextButton, '知道了'));
    await tester.pumpAndSettle();
    expect(find.text('计划提醒'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
    expect(tester.takeException(), isNull);
  });
}
