import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/app.dart';
import 'package:learning_bird/app/theme/app_theme.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/course_file_parser.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';
import 'package:learning_bird/features/plans/domain/weekly_layout.dart';
import 'package:learning_bird/features/plans/presentation/course_import_page.dart';
import 'package:learning_bird/features/plans/presentation/plans_home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = File(
      'D:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      final loader = FontLoader(
        'MaterialIcons',
      )..addFont(Future.value(ByteData.sublistView(await icons.readAsBytes())));
      await loader.load();
    }
    if (File('C:/Windows/Fonts/msyh.ttc').existsSync()) {
      final font = FontLoader('TestChinese')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              await File('C:/Windows/Fonts/msyh.ttc').readAsBytes(),
            ),
          ),
        );
      await font.load();
    }
  });

  PlanListItem item(int id, DateTime time, int minutes) => PlanListItem(
    id: id,
    title: '课程$id',
    startsAt: time,
    estimatedMinutes: minutes,
    priority: 1,
    status: 'pending',
    repeat: PlanRepeat.none,
    targetPomodoros: 0,
    actualMinutes: 0,
  );
  test('重叠课程并列排布、跨午夜切片和跨周边界', () {
    final monday = DateTime(2026, 8, 31);
    final blocks = layoutWeek([
      item(1, DateTime(2026, 8, 31, 8), 100),
      item(2, DateTime(2026, 8, 31, 8, 30), 40),
      item(3, DateTime(2026, 9, 1, 23, 30), 60),
      item(4, DateTime(2026, 8, 30, 23, 30), 60),
    ], monday);
    final overlapping = blocks
        .where((b) => b.item.id == 1 || b.item.id == 2)
        .toList();
    expect(overlapping.map((b) => b.lane).toSet(), {0, 1});
    expect(overlapping.every((b) => b.laneCount == 2), isTrue);
    expect(blocks.where((b) => b.item.id == 3).length, 2);
    expect(blocks.singleWhere((b) => b.item.id == 4).startMinute, 0);
    expect(blocks.singleWhere((b) => b.item.id == 4).endMinute, 30);
  });

  testWidgets('手机周表、切周、日列表与课程详情均可用', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = PlansRepository(db);
    for (final (offset, title) in ['操作系统', '英语阅读', '机器学习'].indexed) {
      await repo.createPlan(
        PlanDraft(
          title: title,
          startsAt: DateTime(2026, 8, 31 + offset, 8 + offset * 2),
          estimatedMinutes: 100,
          priority: 1,
          targetPomodoros: 0,
          repeat: PlanRepeat.none,
          note: '[课表导入]\n老师：示例老师\n地点：博学楼411\n第1周 · 第1–2节',
        ),
      );
    }
    await repo.createPlan(
      PlanDraft(
        title: '高等数学',
        startsAt: DateTime(2026, 8, 31, 8, 30),
        estimatedMinutes: 60,
        priority: 1,
        targetPomodoros: 0,
        repeat: PlanRepeat.none,
        note: '[课表导入]\n老师：数学老师\n地点：致远楼201\n第1周 · 第2节',
      ),
    );
    final now = DateTime.now();
    await repo.createPlan(
      PlanDraft(
        title: '今日任务',
        startsAt: DateTime(now.year, now.month, now.day, 9),
        estimatedMinutes: 60,
        priority: 1,
        targetPomodoros: 0,
        repeat: PlanRepeat.none,
        note: '[课表导入]\n地点：今日自习室',
      ),
    );
    final screenshotKey = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedPlanDateProvider.overrideWith((ref) => DateTime(2026, 8, 31)),
          weeklyPlanViewProvider.overrideWith((ref) => true),
          planReminderRestoreProvider.overrideWith((ref) async {}),
        ],
        child: RepaintBoundary(
          key: screenshotKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(
                fontFamily: 'TestChinese',
              ),
            ),
            home: const PlansHomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('周规划表'), findsOneWidget);
    expect(find.text('2026/8/31 – 9/6'), findsOneWidget);
    expect(find.byKey(const ValueKey('week-plan-1-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('week-plan-4-0')), findsOneWidget);
    expect(find.text('博学楼411'), findsWidgets);
    expect(find.text('致远楼201'), findsOneWidget);
    expect(find.byKey(const ValueKey('week-horizontal')), findsNothing);
    expect(find.byKey(const ValueKey('week-vertical')), findsNothing);
    expect(find.text('周日\n9/6'), findsOneWidget);
    expect(
      tester.getBottomRight(find.text('周日\n9/6')).dx,
      lessThanOrEqualTo(390),
    );
    expect(
      tester
          .getBottomRight(find.byKey(const ValueKey('complete-week-grid')))
          .dy,
      lessThanOrEqualTo(844),
    );
    const imagePath = String.fromEnvironment('COURSE_SCREENSHOT');
    if (imagePath.isNotEmpty) {
      await tester.runAsync(() async {
        final boundary =
            screenshotKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(imagePath).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.byKey(const ValueKey('week-plan-4-0')));
    await tester.pumpAndSettle();
    expect(find.text('该时段有 2 个计划'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '操作系统'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '高等数学'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, '高等数学'));
    await tester.pumpAndSettle();
    expect(find.textContaining('数学老师'), findsWidgets);
    expect(find.textContaining('致远楼201'), findsWidgets);
    await tester.tapAt(const Offset(20, 30));
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const ValueKey('weekly-swipe-surface')),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('2026/9/7 – 9/13'), findsOneWidget);
    await tester.fling(
      find.byKey(const ValueKey('weekly-swipe-surface')),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('2026/8/31 – 9/6'), findsOneWidget);
    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('2026/9/7 – 9/13'), findsOneWidget);
    await tester.tap(find.byTooltip('上一周'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日列表'));
    await tester.pumpAndSettle();
    expect(find.text('今'), findsOneWidget);
    expect(find.byKey(const ValueKey('today-date-chip')), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const ValueKey('today-date-chip'))).dx,
      closeTo(195, 2),
    );
    final dateStrip = find.byKey(const ValueKey('plan-date-strip'));
    final dateScroll = tester.state<ScrollableState>(
      find.descendant(of: dateStrip, matching: find.byType(Scrollable)),
    );
    final initialDateOffset = dateScroll.position.pixels;
    expect(dateScroll.position.maxScrollExtent, greaterThan(initialDateOffset));
    await tester.drag(dateStrip, const Offset(-144, 0));
    await tester.pumpAndSettle();
    expect(dateScroll.position.pixels, greaterThan(initialDateOffset));
    expect(find.text('今日任务'), findsOneWidget);
    expect(find.text('今日自习室'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('真实路由可打开导入页，缺少日期时不保存，预览确认后才导入', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final sheet = CourseFileParser.parseRows('Sheet1', [
      ['课程名称', '星期', '开始节数', '结束节数', '老师', '地点', '周数'],
      ['操作系统', '1', '1', '2', '老师甲', '教室101', '1-3单'],
      ['综合设计', '', '', '', '', '', '17-18'],
    ])!;
    var broken = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          planReminderRestoreProvider.overrideWith((ref) async {}),
          courseFilePickerProvider.overrideWithValue(
            () async => PickedCourseFile('课程.xlsx', Uint8List(0)),
          ),
          courseParserProvider.overrideWithValue((_) async {
            if (broken) throw const FormatException('损坏文件');
            return [sheet];
          }),
        ],
        child: const LearningBirdApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('计划'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('导入课表'));
    await tester.pumpAndSettle();
    expect(find.text('导入课程表'), findsOneWidget);
    await tester.tap(find.text('选择课表文件'));
    await tester.pumpAndSettle();
    Future<void> tapVisible(Finder target, double delta) async {
      final importList = find.byKey(const ValueKey('course-import-list')).last;
      for (
        var attempt = 0;
        target.evaluate().isEmpty && attempt < 20;
        attempt++
      ) {
        await tester.drag(importList, Offset(0, -delta));
        await tester.pumpAndSettle();
      }
      expect(target, findsWidgets);
      final firstTarget = target.at(0);
      await tester.ensureVisible(firstTarget);
      await tester.pumpAndSettle();
      await tester.tap(firstTarget);
      await tester.pumpAndSettle();
    }

    await tapVisible(
      find.byKey(
        const ValueKey('generate-course-import-preview'),
        skipOffstage: false,
      ),
      300,
    );
    expect(await db.select(db.plans).get(), isEmpty);
    await tapVisible(
      find.byKey(
        const ValueKey('pick-course-semester-monday'),
        skipOffstage: false,
      ),
      -300,
    );
    final dateDialog = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(dateDialog.initialDate!.weekday, DateTime.monday);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tapVisible(
      find.byKey(
        const ValueKey('confirm-course-period-times'),
        skipOffstage: false,
      ),
      300,
    );
    await tapVisible(
      find.byKey(
        const ValueKey('confirm-course-warning-skip'),
        skipOffstage: false,
      ),
      250,
    );
    await tapVisible(
      find.byKey(
        const ValueKey('generate-course-import-preview'),
        skipOffstage: false,
      ),
      250,
    );
    expect(await db.select(db.plans).get(), isEmpty);
    await tapVisible(
      find.byKey(const ValueKey('confirm-course-import'), skipOffstage: false),
      300,
    );
    expect(await db.select(db.plans).get(), hasLength(2));
    await tapVisible(
      find.byKey(const ValueKey('return-to-weekly-plan'), skipOffstage: false),
      200,
    );
    expect(find.text('周规划表'), findsOneWidget);
    // A bad replacement cannot leave an earlier file eligible for import.
    await tester.tap(find.byTooltip('导入课表'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择课表文件'));
    await tester.pumpAndSettle();
    broken = true;
    await tester.tap(find.text('选择课表文件'));
    await tester.pumpAndSettle();
    expect(find.text('生成导入预览'), findsNothing);
    expect(await db.select(db.plans).get(), hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
