import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';
import 'package:learning_bird/features/plans/presentation/editor/plan_editor_page.dart';
import 'package:learning_bird/features/plans/presentation/plans_home_page.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('预计时长支持直接输入分钟数并校验范围', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith((ref) => Stream.value(const [])),
          wordBooksProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          home: PlanEditorPage(initialDate: DateTime(2026, 9, 8)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final durationField = find.byKey(const ValueKey('plan-estimated-minutes'));
    expect(durationField, findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    final widget = tester.widget<TextFormField>(durationField);
    expect(widget.validator?.call(''), '请输入预计时长');
    expect(widget.validator?.call('0'), '请输入 1–1440 分钟');
    expect(widget.validator?.call('1441'), '请输入 1–1440 分钟');
    expect(widget.validator?.call('37'), isNull);

    await tester.enterText(durationField, '37');
    await tester.pump();
    expect(find.text('37'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('每日重复可以再次点击取消并恢复不重复', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesProvider.overrideWith((ref) => Stream.value(const [])),
          wordBooksProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: MaterialApp(
          home: PlanEditorPage(initialDate: DateTime(2026, 9, 3)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final none = find.byKey(const ValueKey('plan-repeat-none'));
    final daily = find.byKey(const ValueKey('plan-repeat-daily'));
    expect(tester.widget<ChoiceChip>(none).selected, isTrue);

    await tester.tap(daily);
    await tester.pump();
    expect(tester.widget<ChoiceChip>(daily).selected, isTrue);
    expect(tester.widget<ChoiceChip>(none).selected, isFalse);

    await tester.tap(daily);
    await tester.pump();
    expect(tester.widget<ChoiceChip>(daily).selected, isFalse);
    expect(tester.widget<ChoiceChip>(none).selected, isTrue);
    expect(find.text('再次点击已选中的规则可取消重复'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('已保存每日计划可从操作菜单取消重复并保留当前计划', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlansRepository(database);
    final date = DateTime(2026, 9, 3);
    await repository.createPlan(
      PlanDraft(
        title: '每日背单词',
        startsAt: DateTime(2026, 9, 3, 20),
        estimatedMinutes: 25,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.daily,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          selectedPlanDateProvider.overrideWith((ref) => date),
          weeklyPlanViewProvider.overrideWith((ref) => false),
          planReminderRestoreProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(home: PlansHomePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('每日背单词'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('取消每天重复'), findsOneWidget);
    await tester.tap(find.text('取消每天重复'));
    await tester.pumpAndSettle();
    expect(find.text('取消重复计划？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '取消重复'));
    await tester.pumpAndSettle();

    final saved = await database.select(database.plans).getSingle();
    expect(saved.title, '每日背单词');
    expect(saved.repeatRule, isNull);
    expect(saved.deletedAt, isNull);
    expect(find.text('已取消重复，当前计划仍然保留'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
