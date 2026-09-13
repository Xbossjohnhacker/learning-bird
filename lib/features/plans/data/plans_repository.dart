import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/plan_models.dart';

class PlansRepository {
  PlansRepository(this.database);

  final AppDatabase database;

  Stream<List<PlanListItem>> watchPlansForWeek(
    DateTime day, {
    int? courseScheduleId,
    bool includeAllCourseSchedules = true,
  }) {
    final monday = DateTime(day.year, day.month, day.day - day.weekday + 1);
    final end = DateTime(monday.year, monday.month, monday.day + 7);
    final scheduleFilter = includeAllCourseSchedules
        ? ''
        : courseScheduleId == null
        ? 'AND p.course_schedule_id IS NULL'
        : 'AND (p.course_schedule_id IS NULL OR p.course_schedule_id = ?)';
    return database
        .customSelect(
          '''
SELECT p.*, c.name AS category_name, r.id AS reminder_id,
       r.offset_minutes, r.platform_notification_id,
       cs.name AS course_schedule_name,
       cs.source_type AS course_schedule_source_type
FROM plans p
LEFT JOIN categories c ON c.id = p.category_id
LEFT JOIN reminders r ON r.plan_id = p.id AND r.status != 'cancelled'
LEFT JOIN course_schedules cs ON cs.id = p.course_schedule_id
WHERE p.deleted_at IS NULL AND p.starts_at < ? AND p.starts_at + p.estimated_minutes * 60 > ?
$scheduleFilter
ORDER BY p.starts_at, p.id
''',
          variables: [
            Variable.withDateTime(end.toUtc()),
            Variable.withDateTime(monday.toUtc()),
            if (!includeAllCourseSchedules && courseScheduleId != null)
              Variable.withInt(courseScheduleId),
          ],
          readsFrom: {
            database.plans,
            database.categories,
            database.reminders,
            database.courseSchedules,
          },
        )
        .watch()
        .map((rows) => rows.map(_readPlan).toList(growable: false));
  }

  Stream<List<PlanListItem>> watchPlansForDate(
    DateTime day, {
    int? courseScheduleId,
    bool includeAllCourseSchedules = true,
  }) {
    final start = DateTime(day.year, day.month, day.day).toUtc();
    final end = DateTime(day.year, day.month, day.day + 1).toUtc();
    final scheduleFilter = includeAllCourseSchedules
        ? ''
        : courseScheduleId == null
        ? 'AND p.course_schedule_id IS NULL'
        : 'AND (p.course_schedule_id IS NULL OR p.course_schedule_id = ?)';
    return database
        .customSelect(
          '''
SELECT p.*, c.name AS category_name,
       r.id AS reminder_id, r.offset_minutes,
       r.platform_notification_id,
       cs.name AS course_schedule_name,
       cs.source_type AS course_schedule_source_type
FROM plans p
LEFT JOIN categories c ON c.id = p.category_id
LEFT JOIN reminders r ON r.plan_id = p.id AND r.status != 'cancelled'
LEFT JOIN course_schedules cs ON cs.id = p.course_schedule_id
WHERE p.deleted_at IS NULL
  AND p.starts_at >= ?
  AND p.starts_at < ?
$scheduleFilter
ORDER BY p.status = 'completed', p.starts_at, p.priority DESC
''',
          variables: [
            Variable.withDateTime(start),
            Variable.withDateTime(end),
            if (!includeAllCourseSchedules && courseScheduleId != null)
              Variable.withInt(courseScheduleId),
          ],
          readsFrom: {
            database.plans,
            database.categories,
            database.reminders,
            database.courseSchedules,
          },
        )
        .watch()
        .map((rows) => rows.map(_readPlan).toList(growable: false));
  }

  Stream<List<CategoryOption>> watchCategories() {
    return (database.select(database.categories)..orderBy([
          (category) => OrderingTerm.asc(category.sortOrder),
          (category) => OrderingTerm.asc(category.name),
        ]))
        .watch()
        .map(
          (rows) => rows
              .map((row) => CategoryOption(id: row.id, name: row.name))
              .toList(growable: false),
        );
  }

  Stream<List<CourseScheduleOption>> watchCourseSchedules() {
    return (database.select(
      database.courseSchedules,
    )..orderBy([(item) => OrderingTerm.desc(item.updatedAt)])).watch().map(
      (rows) => rows
          .map(
            (row) => CourseScheduleOption(
              id: row.id,
              name: row.name,
              sourceType: row.sourceType,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<CourseScheduleDeleteInfo> courseScheduleDeleteInfo(int id) {
    return _courseScheduleDeleteInfo(id);
  }

  Future<CourseScheduleDeleteInfo> deleteCourseSchedule(int id) {
    return database.transaction(() async {
      final info = await _courseScheduleDeleteInfo(id);
      await (database.delete(
        database.courseSchedules,
      )..where((item) => item.id.equals(id))).go();
      return info;
    });
  }

  Future<CourseScheduleDeleteInfo> _courseScheduleDeleteInfo(int id) async {
    final exists = await (database.select(
      database.courseSchedules,
    )..where((item) => item.id.equals(id))).getSingleOrNull();
    if (exists == null) throw const FormatException('课表不存在或已被删除');
    final rows = await database
        .customSelect(
          '''
SELECT p.id, r.platform_notification_id
FROM plans p
LEFT JOIN reminders r ON r.plan_id = p.id
WHERE p.course_schedule_id = ?
''',
          variables: [Variable.withInt(id)],
          readsFrom: {database.plans, database.reminders},
        )
        .get();
    final courseIds = <int>{};
    final notificationIds = <int>{};
    for (final row in rows) {
      courseIds.add(row.read<int>('id'));
      final notificationId = row.readNullable<int>('platform_notification_id');
      if (notificationId != null) notificationIds.add(notificationId);
    }
    return CourseScheduleDeleteInfo(
      courseCount: courseIds.length,
      notificationIds: notificationIds.toList(growable: false),
    );
  }

  Future<int> createCategory(String name) async {
    final normalized = name.trim();
    final existing = await (database.select(
      database.categories,
    )..where((category) => category.name.equals(normalized))).getSingleOrNull();
    if (existing != null) return existing.id;
    return database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(name: normalized));
  }

  Future<PlanMutationResult> createPlan(PlanDraft draft) {
    return database.transaction(() async {
      final startsAt = draft.startsAt.toUtc();
      final planId = await database
          .into(database.plans)
          .insert(
            PlansCompanion.insert(
              categoryId: Value(draft.categoryId),
              wordBookId: Value(draft.wordBookId),
              linkedAppPackage: Value(_nullable(draft.linkedAppPackage)),
              linkedAppName: Value(_nullable(draft.linkedAppName)),
              title: draft.title.trim(),
              note: Value(_nullable(draft.note)),
              startsAt: startsAt,
              estimatedMinutes: Value(draft.estimatedMinutes),
              priority: Value(draft.priority),
              repeatRule: Value(draft.repeat.storageValue),
              instanceDate: Value(_dateKey(draft.startsAt)),
              targetPomodoros: Value(draft.targetPomodoros),
            ),
          );
      return _createReminder(
        planId: planId,
        title: draft.title.trim(),
        startsAt: startsAt,
        offsetMinutes: draft.reminderOffsetMinutes,
      );
    });
  }

  Future<void> startPlan(int id) {
    return (database.update(
      database.plans,
    )..where((plan) => plan.id.equals(id))).write(
      PlansCompanion(
        status: const Value('in_progress'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> cancelRepeat(int id) {
    return (database.update(
      database.plans,
    )..where((plan) => plan.id.equals(id))).write(
      PlansCompanion(
        repeatRule: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<PlanMutationResult?> completePlan(
    PlanListItem item, {
    required bool generateNext,
  }) {
    return database.transaction(() async {
      final now = DateTime.now().toUtc();
      await (database.update(
        database.plans,
      )..where((plan) => plan.id.equals(item.id))).write(
        PlansCompanion(
          status: const Value('completed'),
          completedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await (database.update(
        database.reminders,
      )..where((reminder) => reminder.planId.equals(item.id))).write(
        RemindersCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(now),
        ),
      );

      if (!generateNext) return null;
      final nextLocal =
          item.repeat.nextOccurrence(item.startsAt) ??
          DateTime(
            item.startsAt.year,
            item.startsAt.month,
            item.startsAt.day + 1,
            item.startsAt.hour,
            item.startsAt.minute,
          );
      final nextUtc = nextLocal.toUtc();
      final newPlanId = await database
          .into(database.plans)
          .insert(
            PlansCompanion.insert(
              templateId: Value(item.id),
              categoryId: Value(item.categoryId),
              wordBookId: Value(item.wordBookId),
              courseScheduleId: Value(item.courseScheduleId),
              linkedAppPackage: Value(item.linkedAppPackage),
              linkedAppName: Value(item.linkedAppName),
              title: item.title,
              note: Value(_nullable(item.note)),
              startsAt: nextUtc,
              estimatedMinutes: Value(item.estimatedMinutes),
              priority: Value(item.priority),
              repeatRule: Value(item.repeat.storageValue),
              instanceDate: Value(_dateKey(nextLocal)),
              targetPomodoros: Value(item.targetPomodoros),
            ),
          );
      return _createReminder(
        planId: newPlanId,
        title: item.title,
        startsAt: nextUtc,
        offsetMinutes: item.reminderOffsetMinutes,
      );
    });
  }

  Future<void> softDelete(int id) {
    final now = DateTime.now().toUtc();
    return database.transaction(() async {
      await (database.update(database.plans)
            ..where((plan) => plan.id.equals(id)))
          .write(PlansCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (database.update(
        database.reminders,
      )..where((reminder) => reminder.planId.equals(id))).write(
        RemindersCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<List<PlanMutationResult>> loadPendingReminders() async {
    await ensureCourseReminders();
    final rows = await database
        .customSelect(
          '''
SELECT p.id, p.title, p.starts_at, r.trigger_at,
       r.platform_notification_id
FROM reminders r
JOIN plans p ON p.id = r.plan_id
WHERE r.status = 'pending'
  AND p.deleted_at IS NULL
  AND p.status != 'completed'
  AND r.trigger_at > ?
ORDER BY r.trigger_at
LIMIT 50
''',
          variables: [Variable.withDateTime(DateTime.now().toUtc())],
          readsFrom: {database.plans, database.reminders},
        )
        .get();
    return rows
        .map(
          (row) => PlanMutationResult(
            planId: row.read<int>('id'),
            title: row.read<String>('title'),
            startsAt: row.read<DateTime>('starts_at').toLocal(),
            notificationId: row.readNullable<int>('platform_notification_id'),
            reminderAt: row.read<DateTime>('trigger_at').toLocal(),
          ),
        )
        .toList(growable: false);
  }

  Future<int> ensureCourseReminders({DateTime? now}) {
    return database.transaction(() async {
      final current = (now ?? DateTime.now()).toUtc();
      final rows = await database
          .customSelect(
            '''
SELECT p.id, p.starts_at
FROM plans p
JOIN categories c ON c.id = p.category_id
WHERE c.name = '课程'
  AND p.deleted_at IS NULL
  AND p.status NOT IN ('completed', 'cancelled')
  AND p.starts_at + p.estimated_minutes * 60 >= ?
  AND NOT EXISTS (
    SELECT 1 FROM reminders r WHERE r.plan_id = p.id
  )
ORDER BY p.starts_at
''',
            variables: [Variable.withDateTime(current)],
            readsFrom: {
              database.plans,
              database.categories,
              database.reminders,
            },
          )
          .get();
      for (final row in rows) {
        final planId = row.read<int>('id');
        final startsAt = row.read<DateTime>('starts_at');
        await database
            .into(database.reminders)
            .insert(
              RemindersCompanion.insert(
                planId: planId,
                triggerAt: startsAt.subtract(const Duration(minutes: 10)),
                offsetMinutes: const Value(10),
                platformNotificationId: Value(200000 + planId),
              ),
            );
      }
      return rows.length;
    });
  }

  Future<List<DuePlanReminder>> claimDuePopupReminders({DateTime? now}) {
    return database.transaction(() async {
      final current = (now ?? DateTime.now()).toUtc();
      final staleBefore = current.subtract(const Duration(days: 1));
      await database.customUpdate(
        '''
UPDATE reminders
SET status = 'sent', updated_at = ?
WHERE status = 'pending' AND trigger_at < ?
''',
        variables: [
          Variable.withDateTime(current),
          Variable.withDateTime(staleBefore),
        ],
        updates: {database.reminders},
      );
      final rows = await database
          .customSelect(
            '''
SELECT r.id AS reminder_id, p.id AS plan_id, p.title, p.note,
       p.starts_at, p.estimated_minutes, r.platform_notification_id,
       c.name AS category_name
FROM reminders r
JOIN plans p ON p.id = r.plan_id
LEFT JOIN categories c ON c.id = p.category_id
WHERE r.status = 'pending'
  AND r.trigger_at <= ?
  AND r.trigger_at >= ?
  AND p.deleted_at IS NULL
  AND p.status NOT IN ('completed', 'cancelled')
  AND p.starts_at + p.estimated_minutes * 60 >= ?
ORDER BY r.trigger_at, r.id
''',
            variables: [
              Variable.withDateTime(current),
              Variable.withDateTime(staleBefore),
              Variable.withDateTime(current),
            ],
            readsFrom: {
              database.reminders,
              database.plans,
              database.categories,
            },
          )
          .get();
      if (rows.isEmpty) return const <DuePlanReminder>[];
      final ids = rows.map((row) => row.read<int>('reminder_id')).toList();
      await (database.update(
        database.reminders,
      )..where((row) => row.id.isIn(ids))).write(
        RemindersCompanion(
          status: const Value('sent'),
          updatedAt: Value(current),
        ),
      );
      return rows
          .map((row) {
            final category = row.readNullable<String>('category_name');
            final note = row.readNullable<String>('note');
            return DuePlanReminder(
              reminderId: row.read<int>('reminder_id'),
              planId: row.read<int>('plan_id'),
              title: row.read<String>('title'),
              startsAt: row.read<DateTime>('starts_at').toLocal(),
              isCourse: category == '课程',
              notificationId: row.readNullable<int>('platform_notification_id'),
              location: planLocationFromNote(note),
            );
          })
          .toList(growable: false);
    });
  }

  Future<PlanMutationResult> _createReminder({
    required int planId,
    required String title,
    required DateTime startsAt,
    required int? offsetMinutes,
  }) async {
    if (offsetMinutes == null) {
      return PlanMutationResult(
        planId: planId,
        title: title,
        startsAt: startsAt.toLocal(),
      );
    }
    final notificationId = 100000 + planId;
    final triggerAt = startsAt.subtract(Duration(minutes: offsetMinutes));
    await database
        .into(database.reminders)
        .insert(
          RemindersCompanion.insert(
            planId: planId,
            triggerAt: triggerAt,
            offsetMinutes: Value(offsetMinutes),
            platformNotificationId: Value(notificationId),
          ),
        );
    return PlanMutationResult(
      planId: planId,
      title: title,
      startsAt: startsAt.toLocal(),
      notificationId: notificationId,
      reminderAt: triggerAt.toLocal(),
    );
  }

  PlanListItem _readPlan(QueryRow row) {
    return PlanListItem(
      id: row.read<int>('id'),
      title: row.read<String>('title'),
      note: row.readNullable<String>('note'),
      startsAt: row.read<DateTime>('starts_at').toLocal(),
      estimatedMinutes: row.read<int>('estimated_minutes'),
      priority: row.read<int>('priority'),
      status: row.read<String>('status'),
      repeat: PlanRepeat.fromStorage(row.readNullable<String>('repeat_rule')),
      targetPomodoros: row.read<int>('target_pomodoros'),
      actualMinutes: row.read<int>('actual_minutes'),
      categoryId: row.readNullable<int>('category_id'),
      categoryName: row.readNullable<String>('category_name'),
      wordBookId: row.readNullable<int>('word_book_id'),
      reminderId: row.readNullable<int>('reminder_id'),
      reminderOffsetMinutes: row.readNullable<int>('offset_minutes'),
      notificationId: row.readNullable<int>('platform_notification_id'),
      linkedAppPackage: row.readNullable<String>('linked_app_package'),
      linkedAppName: row.readNullable<String>('linked_app_name'),
      courseScheduleId: row.readNullable<int>('course_schedule_id'),
      courseScheduleName: row.readNullable<String>('course_schedule_name'),
      courseScheduleSourceType: row.readNullable<String>(
        'course_schedule_source_type',
      ),
    );
  }

  static String? _nullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
