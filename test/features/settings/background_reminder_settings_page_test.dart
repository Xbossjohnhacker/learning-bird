import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/notifications/background_reminder_settings.dart';
import 'package:learning_bird/core/notifications/plan_notification_service.dart';
import 'package:learning_bird/features/settings/presentation/background_reminder_settings_page.dart';

void main() {
  testWidgets('后台提醒检查页展示通用厂商人工确认步骤', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPermissionProvider.overrideWith((ref) async => true),
          backgroundReminderStatusProvider.overrideWith(
            (ref) async => const BackgroundReminderStatus(
              canScheduleExactly: true,
              ignoringBatteryOptimizations: true,
              manufacturer: 'OPPO',
              sdkInt: 36,
            ),
          ),
        ],
        child: const MaterialApp(home: BackgroundReminderSettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('通知与顶部横幅'), findsOneWidget);
    expect(find.text('精确闹钟'), findsOneWidget);
    expect(find.text('闹钟式强提醒'), findsOneWidget);
    expect(find.text('后台运行与省电限制'), findsOneWidget);
    expect(find.textContaining('自启动'), findsOneWidget);
    expect(find.textContaining('ColorOS'), findsOneWidget);
    expect(find.text('打开系统设置并搜索'), findsOneWidget);
    expect(find.text('检查横幅与锁屏通知'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('10 秒后测试后台提醒'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('10 秒后测试后台提醒'), findsOneWidget);
    expect(find.textContaining('计划和番茄钟'), findsWidgets);
  });
}
