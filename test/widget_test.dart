import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/app.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';

void main() {
  testWidgets('五个一级入口可以切换', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    await PlansRepository(database).createPlan(
      PlanDraft(
        title: '今日复习任务',
        startsAt: DateTime(now.year, now.month, now.day, 12),
        estimatedMinutes: 30,
        priority: 1,
        targetPomodoros: 0,
        repeat: PlanRepeat.none,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const LearningBirdApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('快速开始'), findsOneWidget);
    expect(find.text('今日'), findsWidgets);
    expect(find.text('单词'), findsOneWidget);
    expect(find.text('计划'), findsOneWidget);
    expect(find.text('番茄钟'), findsOneWidget);
    expect(find.text('工具箱'), findsOneWidget);

    await tester.tap(find.text('单词'));
    await tester.pumpAndSettle();
    expect(find.text('我的单词'), findsOneWidget);

    await tester.tap(find.text('新建词书'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '考研核心词');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();
    expect(find.text('考研核心词'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('考研核心词'));
    await tester.pumpAndSettle();
    expect(find.text('全部单词 · 共 0 词'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('我的单词'), findsOneWidget);

    await tester.tap(find.text('导入单词'));
    await tester.pumpAndSettle();
    expect(find.text('Excel / CSV 格式要求'), findsOneWidget);
    expect(find.text('只需要两列：单词、意思'), findsOneWidget);
    expect(find.text('persist'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('删除词书'));
    await tester.pumpAndSettle();
    expect(find.text('删除词书'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(find.text('考研核心词'), findsNothing);
    expect(find.text('还没有词书'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('计划'));
    await tester.pumpAndSettle();
    expect(find.text('计划'), findsWidgets);
    expect(
      tester
          .widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>))
          .selected,
      {false},
    );
    expect(find.text('今日复习任务'), findsOneWidget);

    await tester.tap(find.text('番茄钟'));
    await tester.pumpAndSettle();
    expect(find.text('25:00'), findsOneWidget);

    await tester.tap(find.text('工具箱'));
    await tester.pumpAndSettle();
    expect(find.text('考研资料'), findsOneWidget);
    expect(find.text('导入并在应用内播放本地课程视频'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
