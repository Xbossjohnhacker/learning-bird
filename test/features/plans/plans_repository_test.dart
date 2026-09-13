import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/plans/data/plans_repository.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';

void main() {
  late AppDatabase database;
  late PlansRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PlansRepository(database);
  });

  tearDown(() => database.close());

  test('创建计划会同时保存分类、重复规则和提醒', () async {
    final categoryId = await repository.createCategory('英语');
    final startsAt = DateTime.now().add(const Duration(days: 1));

    final result = await repository.createPlan(
      PlanDraft(
        title: '英语阅读训练',
        startsAt: startsAt,
        estimatedMinutes: 45,
        priority: 2,
        targetPomodoros: 2,
        repeat: PlanRepeat.daily,
        categoryId: categoryId,
        reminderOffsetMinutes: 10,
      ),
    );

    expect(result.reminderAt, startsAt.subtract(const Duration(minutes: 10)));
    final plans = await database.select(database.plans).get();
    final reminders = await database.select(database.reminders).get();
    expect(plans, hasLength(1));
    expect(plans.single.repeatRule, 'daily');
    expect(plans.single.categoryId, categoryId);
    expect(reminders, hasLength(1));
    expect(reminders.single.offsetMinutes, 10);
  });

  test('到时提醒只领取一次，过期或已结束的计划不会弹窗', () async {
    final now = DateTime(2026, 9, 2, 10);
    await repository.createPlan(
      PlanDraft(
        title: '英语阅读提醒',
        startsAt: now.add(const Duration(minutes: 5)),
        estimatedMinutes: 45,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.none,
        reminderOffsetMinutes: 10,
      ),
    );

    final first = await repository.claimDuePopupReminders(now: now);
    expect(first, hasLength(1));
    expect(first.single.title, '英语阅读提醒');
    expect(first.single.isCourse, isFalse);
    expect(first.single.notificationId, 100001);
    expect(await repository.claimDuePopupReminders(now: now), isEmpty);

    final reminders = await database.select(database.reminders).get();
    expect(reminders.single.status, 'sent');
  });

  test('完成重复计划会保存完成状态并生成下一次计划', () async {
    final startsAt = DateTime.now().add(const Duration(days: 1));
    await repository.createPlan(
      PlanDraft(
        title: '数学真题',
        startsAt: startsAt,
        estimatedMinutes: 60,
        priority: 1,
        targetPomodoros: 2,
        repeat: PlanRepeat.weekly,
        reminderOffsetMinutes: 30,
        linkedAppPackage: 'com.gotokeep.keep',
        linkedAppName: 'Keep',
      ),
    );
    final item = (await repository.watchPlansForDate(startsAt).first).single;

    final next = await repository.completePlan(item, generateNext: true);

    final plans = await database.select(database.plans).get();
    expect(plans, hasLength(2));
    expect(plans.first.status, 'completed');
    expect(next, isNotNull);
    expect(
      next!.startsAt,
      DateTime(
        startsAt.year,
        startsAt.month,
        startsAt.day + 7,
        startsAt.hour,
        startsAt.minute,
      ),
    );
    expect(await database.select(database.reminders).get(), hasLength(2));
    expect(plans.last.linkedAppPackage, 'com.gotokeep.keep');
    expect(plans.last.linkedAppName, 'Keep');
  });

  test('仅完成不会生成下一次计划', () async {
    final startsAt = DateTime.now().add(const Duration(days: 1));
    await repository.createPlan(
      PlanDraft(
        title: '政治错题',
        startsAt: startsAt,
        estimatedMinutes: 25,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.none,
      ),
    );
    final item = (await repository.watchPlansForDate(startsAt).first).single;

    final next = await repository.completePlan(item, generateNext: false);

    expect(next, isNull);
    expect(await database.select(database.plans).get(), hasLength(1));
  });

  test('已保存的每日计划可取消重复并保留当前计划', () async {
    final startsAt = DateTime.now().add(const Duration(days: 1));
    final created = await repository.createPlan(
      PlanDraft(
        title: '每日英语',
        startsAt: startsAt,
        estimatedMinutes: 25,
        priority: 1,
        targetPomodoros: 1,
        repeat: PlanRepeat.daily,
      ),
    );

    await repository.cancelRepeat(created.planId);
    final item = (await repository.watchPlansForDate(startsAt).first).single;
    expect(item.title, '每日英语');
    expect(item.repeat, PlanRepeat.none);
    expect(item.isCompleted, isFalse);
  });
}
