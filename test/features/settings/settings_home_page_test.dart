import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/core/notifications/plan_notification_service.dart';
import 'package:learning_bird/features/settings/presentation/settings_home_page.dart';

void main() {
  testWidgets('设置页展示权限状态和数据安全入口', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          notificationPermissionProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: SettingsHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('系统通知'), findsOneWidget);
    expect(find.textContaining('已允许'), findsOneWidget);
    expect(find.text('后台提醒设置检查'), findsOneWidget);
    expect(find.text('备份全部数据'), findsOneWidget);
    expect(find.text('从备份恢复'), findsOneWidget);
    await tester.ensureVisible(find.text('隐私政策'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐私政策'));
    await tester.pumpAndSettle();
    expect(find.text('Learning Bird 隐私政策'), findsOneWidget);
    expect(find.text('关联其他应用'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('关于 Learning Bird'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('关于 Learning Bird'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1.0 正式发布准备版'), findsOneWidget);
    expect(find.textContaining('1.0.0'), findsWidgets);
  });
}
