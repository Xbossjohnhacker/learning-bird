import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/course_file_parser.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/domain/course_import.dart';
import 'package:learning_bird/features/plans/presentation/course_import_page.dart';

void main() {
  testWidgets('教务系统引导补全 https 并通过外部浏览器打开', (tester) async {
    Uri? launchedUri;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseSystemBrowserLauncherProvider.overrideWithValue((uri) async {
            launchedUri = uri;
            return true;
          }),
        ],
        child: const MaterialApp(home: CourseImportPage()),
      ),
    );

    expect(find.text('从教务系统直接读取'), findsOneWidget);
    await tester.tap(find.text('从教务系统直接读取'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('course-system-url-field')),
      'jw.example.edu.cn',
    );
    await tester.tap(find.text('在系统浏览器导出 Excel'));
    await tester.pumpAndSettle();

    expect(launchedUri, Uri.parse('https://jw.example.edu.cn'));
    expect(find.textContaining('已打开浏览器'), findsOneWidget);
  });

  testWidgets('教务系统引导拒绝非网页协议', (tester) async {
    var launchCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseSystemBrowserLauncherProvider.overrideWithValue((uri) async {
            launchCount++;
            return true;
          }),
        ],
        child: const MaterialApp(home: CourseImportPage()),
      ),
    );

    await tester.tap(find.text('从教务系统直接读取'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('course-system-url-field')),
      'javascript:alert(1)',
    );
    await tester.tap(find.text('进入教务系统并读取课表'));
    await tester.pumpAndSettle();

    expect(launchCount, 0);
    expect(find.text('请输入正确的 http 或 https 教务系统网址'), findsOneWidget);
  });

  testWidgets('网页读取结果接入原有课表预览流程且保留 Excel 入口', (tester) async {
    Uri? openedUri;
    final sheet = CourseSheet(
      name: '网页课表',
      courses: [
        CourseEntry(
          sourceRow: 2,
          title: '高等数学',
          weekday: 1,
          startPeriod: 1,
          endPeriod: 2,
          weeks: const [1, 2],
          weekText: '1-2周',
          teacher: '张老师',
          location: '教学楼101',
        ),
      ],
      warnings: const [],
    );
    final secondarySheet = CourseSheet(
      name: '网页中的第二张表',
      courses: [
        CourseEntry(
          sourceRow: 2,
          title: '不应使用的课程',
          weekday: 2,
          startPeriod: 3,
          endPeriod: 4,
          weeks: const [1],
          weekText: '1周',
          teacher: '李老师',
          location: '教学楼202',
        ),
      ],
      warnings: const [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseSystemReaderProvider.overrideWithValue((context, uri) async {
            openedUri = uri;
            return [sheet, secondarySheet];
          }),
          courseSchedulesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: CourseImportPage()),
      ),
    );

    await tester.tap(find.text('从教务系统直接读取'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('course-system-url-field')),
      'https://jw.example.edu.cn/kb',
    );
    final readButton = find.text('进入教务系统并读取课表');
    await tester.ensureVisible(readButton);
    await tester.tap(readButton);
    await tester.pumpAndSettle();

    expect(openedUri, Uri.parse('https://jw.example.edu.cn/kb'));
    expect(find.text('教务系统网页课表'), findsOneWidget);
    await tester.tap(find.text('从教务系统直接读取'));
    await tester.pumpAndSettle();
    expect(
      find.text('识别 1 条可排课记录，0 条需补充或修正', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('使用首张有效课表', skipOffstage: false), findsOneWidget);
    expect(find.text('网页课表', skipOffstage: false), findsWidgets);
    expect(find.text('网页中的第二张表', skipOffstage: false), findsNothing);
    expect(find.text('不应使用的课程', skipOffstage: false), findsNothing);
    expect(find.text('Excel页签（工作表）', skipOffstage: false), findsNothing);
    expect(find.text('选择课表文件', skipOffstage: false), findsOneWidget);
  });

  testWidgets('导入时可新建课表或选择已有课表', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.courseSchedules)
        .insert(
          CourseSchedulesCompanion.insert(
            name: '2026 春季旧课表',
            sourceType: 'excel',
          ),
        );
    final sheet = CourseFileParser.parseRows('课程', [
      ['课程名称', '星期', '开始节数', '结束节数', '老师', '地点', '周数'],
      ['高等数学', '1', '1', '2', '张老师', '教学楼101', '1-2'],
    ])!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          courseFilePickerProvider.overrideWithValue(
            () async => PickedCourseFile('2026秋季.xlsx', Uint8List(0)),
          ),
          courseParserProvider.overrideWithValue((_) async => [sheet]),
        ],
        child: const MaterialApp(home: CourseImportPage()),
      ),
    );
    await tester.tap(find.text('选择课表文件'));
    await tester.pumpAndSettle();

    expect(find.text('保存到哪张课表'), findsOneWidget);
    expect(find.text('新建课表'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('new-course-schedule-name')),
          )
          .controller!
          .text,
      '2026秋季',
    );

    await tester.tap(find.text('新建课表'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026 春季旧课表').last);
    await tester.pumpAndSettle();
    expect(find.text('2026 春季旧课表'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('new-course-schedule-name')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
