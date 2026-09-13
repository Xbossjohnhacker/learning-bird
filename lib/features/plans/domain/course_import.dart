class CourseEntry {
  const CourseEntry({
    required this.sourceRow,
    required this.title,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
    required this.weeks,
    required this.weekText,
    required this.teacher,
    required this.location,
  });
  final int sourceRow;
  final String title, weekText, teacher, location;
  final int weekday, startPeriod, endPeriod;
  final List<int> weeks;
}

class CourseSheet {
  const CourseSheet({
    required this.name,
    required this.courses,
    required this.warnings,
  });
  final String name;
  final List<CourseEntry> courses;
  final List<String> warnings;
}

class LessonPeriod {
  const LessonPeriod(this.number, this.startMinute, this.endMinute);
  final int number, startMinute, endMinute;
  static List<LessonPeriod> exampleTimes() => [
    for (final (index, start) in [
      480,
      535,
      610,
      665,
      840,
      895,
      960,
      1015,
      1140,
      1195,
      1250,
      1305,
    ].indexed)
      LessonPeriod(index + 1, start, start + 45),
  ];
  static String timeText(int minute) =>
      '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
}

class CourseOccurrence {
  const CourseOccurrence({
    required this.course,
    required this.week,
    required this.startsAt,
    required this.endsAt,
  });
  final CourseEntry course;
  final int week;
  final DateTime startsAt, endsAt;
  int get durationMinutes => endsAt.difference(startsAt).inMinutes;
  String get note =>
      '[课表导入]\n老师：${course.teacher.isEmpty ? '未填写' : course.teacher}\n地点：${course.location.isEmpty ? '未填写' : course.location}\n第 $week 周 · 第 ${course.startPeriod}–${course.endPeriod} 节\n原周次：${course.weekText}';
}

abstract final class CourseExpansion {
  static List<CourseOccurrence> expand(
    CourseSheet sheet,
    DateTime firstMonday,
    List<LessonPeriod> periods,
  ) {
    if (firstMonday.weekday != DateTime.monday) {
      throw const FormatException('第一周开始日期必须是星期一');
    }
    if (sheet.courses.isEmpty) throw const FormatException('没有可导入的课程');
    final sorted = [...periods]..sort((a, b) => a.number.compareTo(b.number));
    for (var i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      if (p.number < 1 ||
          p.number > 24 ||
          p.startMinute < 0 ||
          p.endMinute > 1440 ||
          p.startMinute >= p.endMinute ||
          (i > 0 &&
              (p.number == sorted[i - 1].number ||
                  p.startMinute < sorted[i - 1].endMinute))) {
        throw const FormatException('节次时间有重复、重叠或先后顺序错误，请检查');
      }
    }
    final byNumber = {for (final p in periods) p.number: p};
    final result = <CourseOccurrence>[];
    for (final course in sheet.courses) {
      if (course.weekday < 1 ||
          course.weekday > 7 ||
          course.startPeriod > course.endPeriod ||
          course.weeks.isEmpty) {
        throw const FormatException('课程排课信息不完整');
      }
      for (var p = course.startPeriod; p <= course.endPeriod; p++) {
        if (!byNumber.containsKey(p)) throw FormatException('请补充第 $p 节的时间');
      }
      for (final week in course.weeks.toSet()) {
        if (week < 1 || week > 53) throw const FormatException('周次必须在 1–53 之间');
        final day = DateTime(
          firstMonday.year,
          firstMonday.month,
          firstMonday.day + (week - 1) * 7 + course.weekday - 1,
        );
        final start = byNumber[course.startPeriod]!.startMinute;
        final end = byNumber[course.endPeriod]!.endMinute;
        result.add(
          CourseOccurrence(
            course: course,
            week: week,
            startsAt: DateTime(
              day.year,
              day.month,
              day.day,
              start ~/ 60,
              start % 60,
            ),
            endsAt: DateTime(day.year, day.month, day.day, end ~/ 60, end % 60),
          ),
        );
      }
    }
    if (result.length > 5000) throw const FormatException('单次最多导入 5000 次课程');
    result.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return result;
  }
}
