import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/course_import.dart';

class CourseImportPreview {
  const CourseImportPreview(
    this.pending,
    this.skipped,
    this.conflicts, {
    this.scheduleId,
  });
  final List<CourseOccurrence> pending;
  final int skipped, conflicts;
  final int? scheduleId;
}

class CourseImportRepository {
  CourseImportRepository(this.database);
  final AppDatabase database;

  String _hash(CourseOccurrence item) => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            item.course.title,
            item.course.teacher,
            item.course.location,
            item.startsAt.toIso8601String(),
            item.endsAt.toIso8601String(),
          ]),
        ),
      )
      .toString();

  String _scheduleKey(int scheduleId, CourseOccurrence item) =>
      'course_occurrence_schedule_${scheduleId}_${_hash(item)}';

  String _sourceKey(String sourceType, CourseOccurrence item) =>
      'course_occurrence_${sourceType}_${_hash(item)}';

  String _legacyKey(CourseOccurrence item) =>
      'course_occurrence_${_hash(item)}';

  Future<CourseImportPreview> preview(
    List<CourseOccurrence> items, {
    String sourceType = 'legacy',
    int? scheduleId,
  }) async {
    _sourceType(sourceType);
    if (items.isEmpty || items.length > 5000) {
      throw const FormatException('请先生成有效课程预览（最多 5000 次）');
    }
    final imported = await (database.select(
      database.appSettings,
    )..where((row) => row.key.like('course_occurrence_%'))).get();
    final keys = imported.map((row) => row.key).toSet();
    final schedule = scheduleId == null
        ? null
        : await _requireSchedule(scheduleId);
    final pending = <CourseOccurrence>[];
    final seenInFile = <String>{};
    var skipped = 0;
    for (final item in items) {
      if (item.course.title.trim().isEmpty ||
          item.course.title.length > 120 ||
          item.durationMinutes < 1 ||
          item.durationMinutes > 1440) {
        throw const FormatException('课程名称或时长无效');
      }
      final hash = _hash(item);
      final alreadyImported =
          schedule != null &&
          (keys.contains(_scheduleKey(schedule.id, item)) ||
              _matchesOldDedupKey(keys, schedule, item));
      if (alreadyImported || !seenInFile.add(hash)) {
        skipped++;
      } else {
        pending.add(item);
      }
    }
    if (pending.isEmpty) {
      return CourseImportPreview(pending, skipped, 0, scheduleId: schedule?.id);
    }
    final start = pending
        .map((p) => p.startsAt)
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .toUtc();
    final end = pending
        .map((p) => p.endsAt)
        .reduce((a, b) => a.isAfter(b) ? a : b)
        .toUtc();
    final scheduleFilter = schedule == null
        ? 'AND course_schedule_id IS NULL'
        : 'AND (course_schedule_id IS NULL OR course_schedule_id = ?)';
    final existing = await database
        .customSelect(
          '''
SELECT starts_at, estimated_minutes FROM plans
WHERE deleted_at IS NULL AND starts_at < ? AND starts_at + estimated_minutes * 60 > ?
$scheduleFilter
''',
          variables: [
            Variable.withDateTime(end),
            Variable.withDateTime(start),
            if (schedule != null) Variable.withInt(schedule.id),
          ],
        )
        .get();
    var conflicts = 0;
    for (var i = 0; i < pending.length; i++) {
      final item = pending[i];
      bool overlaps(DateTime a, DateTime b) =>
          item.startsAt.isBefore(b) && item.endsAt.isAfter(a);
      final occupied =
          existing.any((row) {
            final from = row.read<DateTime>('starts_at');
            return overlaps(
              from,
              from.add(Duration(minutes: row.read<int>('estimated_minutes'))),
            );
          }) ||
          pending.take(i).any((p) => overlaps(p.startsAt, p.endsAt));
      if (occupied) conflicts++;
    }
    return CourseImportPreview(
      pending,
      skipped,
      conflicts,
      scheduleId: schedule?.id,
    );
  }

  Future<CourseImportPreview> importCourses(
    List<CourseOccurrence> items, {
    bool acceptConflicts = false,
    String sourceType = 'legacy',
    String? scheduleName,
    int? scheduleId,
    bool createNewSchedule = false,
  }) {
    return database.transaction(() async {
      final normalizedSource = _sourceType(sourceType);
      final schedule = scheduleId != null
          ? await _requireSchedule(scheduleId)
          : createNewSchedule
          ? await _createSchedule(
              normalizedSource,
              _normalizeScheduleName(scheduleName),
            )
          : await _getDefaultOrCreateSchedule(
              normalizedSource,
              scheduleName == null
                  ? _defaultScheduleName(normalizedSource)
                  : _normalizeScheduleName(scheduleName),
            );
      final checked = await preview(
        items,
        sourceType: normalizedSource,
        scheduleId: schedule.id,
      );
      if (checked.conflicts > 0 && !acceptConflicts) {
        throw const FormatException('课程与已有计划时间重叠，请重新预览并确认保留冲突');
      }
      if (checked.pending.isEmpty) {
        return CourseImportPreview(
          checked.pending,
          checked.skipped,
          checked.conflicts,
          scheduleId: schedule.id,
        );
      }
      final category = await (database.select(
        database.categories,
      )..where((c) => c.name.equals('课程'))).getSingleOrNull();
      final categoryId =
          category?.id ??
          await database
              .into(database.categories)
              .insert(CategoriesCompanion.insert(name: '课程'));
      for (final item in checked.pending) {
        final id = await database
            .into(database.plans)
            .insert(
              PlansCompanion.insert(
                title: item.course.title,
                note: Value(item.note),
                categoryId: Value(categoryId),
                courseScheduleId: Value(schedule.id),
                startsAt: item.startsAt.toUtc(),
                estimatedMinutes: Value(item.durationMinutes),
                targetPomodoros: const Value(0),
              ),
            );
        const offsetMinutes = 10;
        await database
            .into(database.reminders)
            .insert(
              RemindersCompanion.insert(
                planId: id,
                triggerAt: item.startsAt
                    .subtract(const Duration(minutes: offsetMinutes))
                    .toUtc(),
                offsetMinutes: const Value(offsetMinutes),
                platformNotificationId: Value(200000 + id),
              ),
            );
        await database.putSetting(_scheduleKey(schedule.id, item), '$id');
      }
      await (database.update(
        database.courseSchedules,
      )..where((item) => item.id.equals(schedule.id))).write(
        CourseSchedulesCompanion(updatedAt: Value(DateTime.now().toUtc())),
      );
      return CourseImportPreview(
        checked.pending,
        checked.skipped,
        checked.conflicts,
        scheduleId: schedule.id,
      );
    });
  }

  bool _matchesOldDedupKey(
    Set<String> keys,
    CourseSchedule schedule,
    CourseOccurrence item,
  ) {
    // 1.0.0+12 及更早版本按来源去重。仅基础来源键代表旧课表，
    // 新建的多课表使用带冒号的唯一来源标识，不共享旧去重记录。
    if (schedule.sourceType.contains(':')) return false;
    final kind = scheduleSourceKind(schedule.sourceType);
    return keys.contains(_sourceKey(kind, item)) ||
        (kind == 'legacy' && keys.contains(_legacyKey(item)));
  }

  Future<CourseSchedule> _getDefaultOrCreateSchedule(
    String sourceType,
    String name,
  ) async {
    final schedules = await (database.select(
      database.courseSchedules,
    )..orderBy([(item) => OrderingTerm.desc(item.updatedAt)])).get();
    final existing = schedules
        .where((item) => scheduleSourceKind(item.sourceType) == sourceType)
        .firstOrNull;
    if (existing != null) return existing;
    return _createSchedule(sourceType, name);
  }

  Future<CourseSchedule> _createSchedule(String sourceType, String name) async {
    var attempt = 0;
    while (true) {
      final uniqueSource = attempt == 0
          ? sourceType
          : '$sourceType:${DateTime.now().microsecondsSinceEpoch}:$attempt';
      final existing =
          await (database.select(database.courseSchedules)
                ..where((item) => item.sourceType.equals(uniqueSource)))
              .getSingleOrNull();
      if (existing != null) {
        attempt++;
        continue;
      }
      final id = await database
          .into(database.courseSchedules)
          .insert(
            CourseSchedulesCompanion.insert(
              name: name,
              sourceType: uniqueSource,
            ),
          );
      return (database.select(
        database.courseSchedules,
      )..where((item) => item.id.equals(id))).getSingle();
    }
  }

  Future<CourseSchedule> _requireSchedule(int scheduleId) async {
    final schedule = await (database.select(
      database.courseSchedules,
    )..where((item) => item.id.equals(scheduleId))).getSingleOrNull();
    if (schedule == null) throw const FormatException('选择的课表不存在或已被删除');
    return schedule;
  }

  static String _sourceType(String sourceType) {
    if (sourceType == 'web' ||
        sourceType == 'excel' ||
        sourceType == 'legacy') {
      return sourceType;
    }
    throw const FormatException('未知课表来源');
  }

  static String scheduleSourceKind(String sourceType) =>
      sourceType.split(':').first;

  static String _normalizeScheduleName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty || name.length > 80) {
      throw const FormatException('课表名称应为 1–80 个字符');
    }
    return name;
  }

  static String _defaultScheduleName(String sourceType) => switch (sourceType) {
    'web' => '教务系统课表',
    'excel' => 'Excel课表',
    _ => '历史导入课表',
  };
}
