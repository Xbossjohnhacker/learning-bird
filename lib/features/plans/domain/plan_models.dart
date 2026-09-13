enum PlanRepeat {
  none,
  daily,
  weekly,
  monthly;

  String? get storageValue => switch (this) {
    PlanRepeat.none => null,
    PlanRepeat.daily => 'daily',
    PlanRepeat.weekly => 'weekly',
    PlanRepeat.monthly => 'monthly',
  };

  String get label => switch (this) {
    PlanRepeat.none => '不重复',
    PlanRepeat.daily => '每天',
    PlanRepeat.weekly => '每周',
    PlanRepeat.monthly => '每月',
  };

  static PlanRepeat fromStorage(String? value) {
    return PlanRepeat.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => PlanRepeat.none,
    );
  }

  DateTime? nextOccurrence(DateTime current) {
    return switch (this) {
      PlanRepeat.none => null,
      PlanRepeat.daily => DateTime(
        current.year,
        current.month,
        current.day + 1,
        current.hour,
        current.minute,
      ),
      PlanRepeat.weekly => DateTime(
        current.year,
        current.month,
        current.day + 7,
        current.hour,
        current.minute,
      ),
      PlanRepeat.monthly => _nextMonth(current),
    };
  }

  static DateTime _nextMonth(DateTime current) {
    final firstOfFollowingMonth = DateTime(current.year, current.month + 2);
    final lastDayOfNextMonth = firstOfFollowingMonth
        .subtract(const Duration(days: 1))
        .day;
    return DateTime(
      current.year,
      current.month + 1,
      current.day.clamp(1, lastDayOfNextMonth),
      current.hour,
      current.minute,
    );
  }
}

class PlanDraft {
  const PlanDraft({
    required this.title,
    required this.startsAt,
    required this.estimatedMinutes,
    required this.priority,
    required this.targetPomodoros,
    required this.repeat,
    this.note,
    this.categoryId,
    this.wordBookId,
    this.reminderOffsetMinutes,
    this.linkedAppPackage,
    this.linkedAppName,
  });

  final String title;
  final String? note;
  final DateTime startsAt;
  final int estimatedMinutes;
  final int priority;
  final int targetPomodoros;
  final PlanRepeat repeat;
  final int? categoryId;
  final int? wordBookId;
  final int? reminderOffsetMinutes;
  final String? linkedAppPackage;
  final String? linkedAppName;
}

class CourseScheduleOption {
  const CourseScheduleOption({
    required this.id,
    required this.name,
    required this.sourceType,
  });

  final int id;
  final String name;
  final String sourceType;

  String get sourceKind => sourceType.split(':').first;
}

class CourseScheduleDeleteInfo {
  const CourseScheduleDeleteInfo({
    required this.courseCount,
    required this.notificationIds,
  });

  final int courseCount;
  final List<int> notificationIds;
}

class PlanListItem {
  const PlanListItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.estimatedMinutes,
    required this.priority,
    required this.status,
    required this.repeat,
    required this.targetPomodoros,
    required this.actualMinutes,
    this.note,
    this.categoryId,
    this.categoryName,
    this.wordBookId,
    this.reminderId,
    this.reminderOffsetMinutes,
    this.notificationId,
    this.linkedAppPackage,
    this.linkedAppName,
    this.courseScheduleId,
    this.courseScheduleName,
    this.courseScheduleSourceType,
  });

  final int id;
  final String title;
  final String? note;
  final DateTime startsAt;
  final int estimatedMinutes;
  final int priority;
  final String status;
  final PlanRepeat repeat;
  final int targetPomodoros;
  final int actualMinutes;
  final int? categoryId;
  final String? categoryName;
  final int? wordBookId;
  final int? reminderId;
  final int? reminderOffsetMinutes;
  final int? notificationId;
  final String? linkedAppPackage;
  final String? linkedAppName;
  final int? courseScheduleId;
  final String? courseScheduleName;
  final String? courseScheduleSourceType;

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
}

String? planLocationFromNote(String? note) {
  if (note == null) return null;
  final match = RegExp(
    r'(?:^|\n)地点[：:]\s*([^\n]+)',
    multiLine: true,
  ).firstMatch(note);
  final location = match?.group(1)?.trim();
  return location == null || location.isEmpty ? null : location;
}

class PlanMutationResult {
  const PlanMutationResult({
    required this.planId,
    required this.title,
    required this.startsAt,
    this.notificationId,
    this.reminderAt,
  });

  final int planId;
  final String title;
  final DateTime startsAt;
  final int? notificationId;
  final DateTime? reminderAt;
}

class DuePlanReminder {
  const DuePlanReminder({
    required this.reminderId,
    required this.planId,
    required this.title,
    required this.startsAt,
    required this.isCourse,
    this.notificationId,
    this.location,
  });

  final int reminderId;
  final int planId;
  final String title;
  final DateTime startsAt;
  final bool isCourse;
  final int? notificationId;
  final String? location;
}

class CategoryOption {
  const CategoryOption({required this.id, required this.name});

  final int id;
  final String name;
}
