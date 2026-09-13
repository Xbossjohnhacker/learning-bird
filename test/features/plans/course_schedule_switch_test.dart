import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/data/course_import_repository.dart';
import 'package:learning_bird/features/plans/data/plans_providers.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/course_import.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';
import 'package:learning_bird/features/plans/presentation/plans_home_page.dart';

void main() {
  testWidgets('网页和 Excel 课表可切换且普通计划始终叠加', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final date = DateTime(2026, 9, 7, 8);
    final importer = CourseImportRepository(database);
    final webResult = await importer.importCourses([
      _occurrence('网页课程', date),
    ], sourceType: 'web');
    final excelResult = await importer.importCourses([
      _occurrence('Excel课程', date),
    ], sourceType: 'excel');
    await PlansRepository(database).createPlan(
      PlanDraft(
        title: '普通计划',
        startsAt: date,
        estimatedMinutes: 30,
        priority: 1,
        targetPomodoros: 0,
        repeat: PlanRepeat.none,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          selectedPlanDateProvider.overrideWith((ref) => date),
          selectedCourseScheduleIdProvider.overrideWith(
            (ref) => webResult.scheduleId!,
          ),
          weeklyPlanViewProvider.overrideWith((ref) => false),
          planReminderRestoreProvider.overrideWith((ref) async {}),
        ],
        child: const MaterialApp(home: PlansHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('计划 + 教务系统课表'), findsOneWidget);
    expect(find.text('计划 + Excel课表'), findsOneWidget);
    expect(find.text('网页课程'), findsOneWidget);
    expect(find.text('普通计划'), findsOneWidget);
    expect(find.text('Excel课程'), findsNothing);

    await tester.tap(find.text('计划 + Excel课表'));
    await tester.pumpAndSettle();
    expect(excelResult.scheduleId, isNot(webResult.scheduleId));
    expect(find.text('网页课程'), findsNothing);
    expect(find.text('Excel课程'), findsOneWidget);
    expect(find.text('普通计划'), findsOneWidget);

    await tester.tap(find.byTooltip('选择和管理课表'));
    await tester.pumpAndSettle();
    expect(find.text('选择和管理课表'), findsOneWidget);
    expect(find.text('仅显示普通计划'), findsOneWidget);
    await tester.tap(
      find.byKey(ValueKey('select-course-schedule-${webResult.scheduleId}')),
    );
    await tester.pumpAndSettle();
    expect(find.text('网页课程'), findsOneWidget);
    expect(find.text('Excel课程'), findsNothing);

    await tester.tap(find.byTooltip('选择和管理课表'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除 教务系统课表'));
    await tester.pumpAndSettle();
    expect(find.text('删除课表？'), findsOneWidget);
    expect(find.textContaining('其中 1 条课程'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await database.select(database.courseSchedules).get(), hasLength(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

CourseOccurrence _occurrence(String title, DateTime startsAt) {
  final course = CourseEntry(
    sourceRow: 2,
    title: title,
    weekday: startsAt.weekday,
    startPeriod: 1,
    endPeriod: 2,
    weeks: const [1],
    weekText: '1周',
    teacher: '测试老师',
    location: '测试教室',
  );
  return CourseOccurrence(
    course: course,
    week: 1,
    startsAt: startsAt,
    endsAt: startsAt.add(const Duration(minutes: 90)),
  );
}
