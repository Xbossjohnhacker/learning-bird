import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/backup/backup_repository.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/plans/data/course_file_parser.dart';
import 'package:learning_bird/features/plans/data/course_import_repository.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/course_import.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';

const headers = ['课程名称', '星期', '开始节数', '结束节数', '老师', '地点', '周数'];
CourseSheet fixture() => CourseFileParser.parseRows('课程', [
  headers,
  ['操作系统', '星期一', '1', '2', '老师甲', '教室101', '1-3单'],
  ['计算机网络', '2', '3', '4', '老师乙', '教室202', '2-4双'],
  ['综合设计', '', '', '', '老师丙', '无', '17-18'],
])!;

void main() {
  test('单双周、分段周次与边界校验', () {
    expect(CourseFileParser.parseWeeks('12-18双'), [12, 14, 16, 18]);
    expect(CourseFileParser.parseWeeks('3-17单'), [3, 5, 7, 9, 11, 13, 15, 17]);
    expect(CourseFileParser.parseWeeks('7-10、12、15-17'), [
      7,
      8,
      9,
      10,
      12,
      15,
      16,
      17,
    ]);
    expect(CourseFileParser.parseWeeks('第1-5周(单周)'), [1, 3, 5]);
    expect(CourseFileParser.parseWeeks('1,1,2'), [1, 2]);
    for (final value in ['', '0-3', '18-12', '1-54', '1-3未知', '2单']) {
      expect(() => CourseFileParser.parseWeeks(value), throwsFormatException);
    }
  });
  test('缺少排课信息不伪造星期，字段别名和重复表头', () {
    final sheet = fixture();
    expect(sheet.courses, hasLength(2));
    expect(sheet.warnings.single, contains('第 4 行 综合设计'));
    expect(
      CourseFileParser.parseRows('空表', [
        ['不是课表'],
      ]),
      isNull,
    );
    expect(
      () => CourseFileParser.parseRows('重复', [
        [...headers, '星期'],
      ]),
      throwsFormatException,
    );
    expect(CourseFileParser.parseWeekday('周日'), 7);
    expect(CourseFileParser.parseWeekday('8'), isNull);
  });

  test('常见教务表头可识别授课教师和上课教室', () {
    final sheet = CourseFileParser.parseRows('教务明细', [
      ['课程', '上课星期', '起始节次', '终止节次', '授课教师', '上课教室', '上课周次'],
      ['线性代数', '星期二', '3', '4', '陈老师', '致远楼205', '1-16周'],
    ])!;
    expect(sheet.courses.single.teacher, '陈老师');
    expect(sheet.courses.single.location, '致远楼205');
  });
  test('按学期第一周周一展开日期，禁止不完整或重叠节次', () {
    final sheet = fixture();
    final monday = DateTime(2026, 8, 31);
    final items = CourseExpansion.expand(
      sheet,
      monday,
      LessonPeriod.exampleTimes(),
    );
    expect(items, hasLength(4));
    expect(items.map((item) => item.startsAt), [
      DateTime(2026, 8, 31, 8),
      DateTime(2026, 9, 8, 10, 10),
      DateTime(2026, 9, 14, 8),
      DateTime(2026, 9, 22, 10, 10),
    ]);
    expect(items.first.durationMinutes, 100);
    expect(
      () => CourseExpansion.expand(
        sheet,
        DateTime(2026, 9, 1),
        LessonPeriod.exampleTimes(),
      ),
      throwsFormatException,
    );
    expect(
      () => CourseExpansion.expand(sheet, monday, [
        const LessonPeriod(1, 480, 525),
      ]),
      throwsFormatException,
    );
    expect(
      () => CourseExpansion.expand(sheet, monday, [
        const LessonPeriod(1, 480, 525),
        const LessonPeriod(2, 500, 545),
      ]),
      throwsFormatException,
    );
  });

  const realFile = String.fromEnvironment('COURSE_TEST_FILE');
  test(
    '用户原始课表解析与全学期144次排课',
    () async {
      final bytes = await File(realFile).readAsBytes();
      final sheets = CourseFileParser.parse(bytes);
      expect(sheets, hasLength(1));
      expect(sheets.single.courses, hasLength(14));
      expect(sheets.single.warnings, hasLength(1));
      expect(sheets.single.warnings.single, contains('计算机硬件系统综合设计'));
      final items = CourseExpansion.expand(
        sheets.single,
        DateTime(2026, 8, 31),
        LessonPeriod.exampleTimes(),
      );
      expect(items, hasLength(144));
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = CourseImportRepository(db);
      expect((await repo.preview(items)).conflicts, 0);
      expect((await repo.importCourses(items)).pending, hasLength(144));
      expect((await repo.importCourses(items)).skipped, 144);
    },
    skip: realFile.isEmpty ? '通过 COURSE_TEST_FILE 指定用户课表，不将个人数据复制到测试仓库' : false,
  );

  group('课程入库', () {
    late AppDatabase db;
    late CourseImportRepository repo;
    late List<CourseOccurrence> items;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = CourseImportRepository(db);
      items = CourseExpansion.expand(
        fixture(),
        DateTime(2026, 8, 31),
        LessonPeriod.exampleTimes(),
      );
    });
    tearDown(() => db.close());
    test('重复与并发导入去重，已完成和删除状态不被覆盖', () async {
      final results = await Future.wait([
        repo.importCourses(items),
        repo.importCourses(items),
      ]);
      expect(results.map((r) => r.pending.length).reduce((a, b) => a + b), 4);
      final plans = PlansRepository(db);
      final first =
          (await plans.watchPlansForDate(items.first.startsAt).first).single;
      await plans.completePlan(first, generateNext: false);
      expect((await repo.importCourses(items)).skipped, 4);
      expect(
        (await plans.watchPlansForDate(items.first.startsAt).first)
            .single
            .isCompleted,
        isTrue,
      );
      await plans.softDelete(first.id);
      expect((await repo.importCourses(items)).skipped, 4);
      expect(
        await plans.watchPlansForDate(items.first.startsAt).first,
        isEmpty,
      );
      final reminders = await db.select(db.reminders).get();
      expect(reminders, hasLength(4));
      expect(
        reminders.where((item) => item.status == 'cancelled'),
        hasLength(1),
      );
    });
    test('导入课程会建立提醒，弹窗数据包含课程地点且只领取一次', () async {
      await repo.importCourses(items);
      final plans = PlansRepository(db);
      final current = items.first.startsAt.subtract(const Duration(minutes: 9));

      final reminders = await plans.claimDuePopupReminders(now: current);
      expect(reminders, hasLength(1));
      expect(reminders.single.isCourse, isTrue);
      expect(reminders.single.title, '操作系统');
      expect(reminders.single.location, '教室101');
      expect(reminders.single.notificationId, 200001);
      expect(await plans.claimDuePopupReminders(now: current), isEmpty);
    });
    test('升级后会为已有未结束课程补建提醒且无需重新导入', () async {
      await repo.importCourses(items);
      await db.delete(db.reminders).go();
      final plans = PlansRepository(db);

      expect(await plans.ensureCourseReminders(now: DateTime(2026, 8, 30)), 4);
      expect(await db.select(db.reminders).get(), hasLength(4));
      expect(await plans.ensureCourseReminders(now: DateTime(2026, 8, 30)), 0);
    });
    test('冲突必须明确确认才保存，跨周查询不漏跨午夜计划', () async {
      final plans = PlansRepository(db);
      await plans.createPlan(
        PlanDraft(
          title: '周日跨夜',
          startsAt: DateTime(2026, 8, 30, 23, 30),
          estimatedMinutes: 600,
          priority: 1,
          targetPomodoros: 0,
          repeat: PlanRepeat.none,
        ),
      );
      expect((await repo.preview(items)).conflicts, 1);
      await expectLater(repo.importCourses(items), throwsFormatException);
      expect(await db.select(db.plans).get(), hasLength(1));
      await repo.importCourses(items, acceptConflicts: true);
      expect(
        await plans.watchPlansForWeek(DateTime(2026, 9, 2)).first,
        hasLength(2),
      );
      expect(
        await plans.watchPlansForWeek(DateTime(2026, 9, 7)).first,
        hasLength(1),
      );
    });
    test('中途写入失败会回滚计划、分类及去重标记', () async {
      await db.customStatement(
        "CREATE TRIGGER fail_import BEFORE INSERT ON plans WHEN NEW.title = '计算机网络' BEGIN SELECT RAISE(ABORT, 'test'); END;",
      );
      await expectLater(repo.importCourses(items), throwsA(isA<Exception>()));
      expect(await db.select(db.plans).get(), isEmpty);
      expect(await db.select(db.categories).get(), isEmpty);
      expect((await repo.preview(items)).pending, hasLength(4));
    });
    test('课程与去重标记随原有备份恢复', () async {
      await repo.importCourses(items);
      final backup = await BackupRepository(db).createBackup();
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = CourseImportRepository(db);
      await BackupRepository(db).restoreBackup(backup);
      expect((await repo.importCourses(items)).skipped, 4);
      expect(await db.select(db.plans).get(), hasLength(4));
    });
    test('网页与 Excel 课表独立去重且查询时只和普通计划叠加', () async {
      final webResult = await repo.importCourses(items, sourceType: 'web');
      expect(webResult.pending, hasLength(4));
      expect(
        (await repo.preview(items, sourceType: 'excel')).pending,
        hasLength(4),
      );
      final excelResult = await repo.importCourses(items, sourceType: 'excel');
      expect(excelResult.pending, hasLength(4));
      expect((await repo.importCourses(items, sourceType: 'web')).skipped, 4);

      final schedules = await db.select(db.courseSchedules).get();
      final web = schedules.singleWhere((item) => item.sourceType == 'web');
      final excel = schedules.singleWhere((item) => item.sourceType == 'excel');
      expect(await db.select(db.plans).get(), hasLength(8));

      final plans = PlansRepository(db);
      await plans.createPlan(
        PlanDraft(
          title: '普通学习计划',
          startsAt: items.first.startsAt,
          estimatedMinutes: 30,
          priority: 1,
          targetPomodoros: 0,
          repeat: PlanRepeat.none,
        ),
      );
      final selected = await plans
          .watchPlansForDate(
            items.first.startsAt,
            courseScheduleId: web.id,
            includeAllCourseSchedules: false,
          )
          .first;
      expect(selected.any((item) => item.title == '普通学习计划'), isTrue);
      expect(selected.any((item) => item.courseScheduleId == web.id), isTrue);
      expect(
        selected.any((item) => item.courseScheduleId == excel.id),
        isFalse,
      );
    });
    test('同一来源可新建多张课表，也可选择旧课表继续追加', () async {
      final autumn = await repo.importCourses(
        items,
        sourceType: 'web',
        scheduleName: '2026 秋季课表',
        createNewSchedule: true,
      );
      final postgraduate = await repo.importCourses(
        items,
        sourceType: 'web',
        scheduleName: '考研课表',
        createNewSchedule: true,
      );

      expect(autumn.scheduleId, isNot(postgraduate.scheduleId));
      expect(autumn.pending, hasLength(4));
      expect(postgraduate.pending, hasLength(4));
      expect(
        (await repo.preview(
          items,
          sourceType: 'web',
          scheduleId: autumn.scheduleId,
        )).skipped,
        4,
      );
      expect(
        (await repo.importCourses(
          items,
          sourceType: 'excel',
          scheduleId: autumn.scheduleId,
        )).skipped,
        4,
      );

      final schedules = await db.select(db.courseSchedules).get();
      expect(schedules, hasLength(2));
      expect(
        schedules.map((item) => item.name),
        containsAll(['2026 秋季课表', '考研课表']),
      );
      expect(await db.select(db.plans).get(), hasLength(8));
    });
    test('删除一张课表只清理该表课程和提醒', () async {
      final first = await repo.importCourses(
        items,
        sourceType: 'web',
        scheduleName: '待删除课表',
        createNewSchedule: true,
      );
      final second = await repo.importCourses(
        items,
        sourceType: 'excel',
        scheduleName: '保留课表',
        createNewSchedule: true,
      );
      final plans = PlansRepository(db);
      await plans.createPlan(
        PlanDraft(
          title: '保留的普通计划',
          startsAt: items.first.startsAt,
          estimatedMinutes: 30,
          priority: 1,
          targetPomodoros: 0,
          repeat: PlanRepeat.none,
        ),
      );

      final preview = await plans.courseScheduleDeleteInfo(first.scheduleId!);
      expect(preview.courseCount, 4);
      expect(preview.notificationIds, hasLength(4));
      final deleted = await plans.deleteCourseSchedule(first.scheduleId!);
      expect(deleted.courseCount, 4);

      final schedules = await db.select(db.courseSchedules).get();
      expect(schedules.single.id, second.scheduleId);
      final remainingPlans = await db.select(db.plans).get();
      expect(remainingPlans, hasLength(5));
      expect(remainingPlans.any((item) => item.title == '保留的普通计划'), isTrue);
      expect(
        remainingPlans.where(
          (item) => item.courseScheduleId == second.scheduleId,
        ),
        hasLength(4),
      );
      expect(await db.select(db.reminders).get(), hasLength(4));
    });
  });
}
