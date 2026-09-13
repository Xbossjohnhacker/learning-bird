import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../vocabulary/data/excel_namespace_normalizer.dart';
import '../domain/course_import.dart';

abstract final class CourseFileParser {
  static List<CourseSheet> parse(Uint8List bytes) {
    if (bytes.length > 10 * 1024 * 1024) {
      throw const FormatException('课表文件不能超过 10 MB');
    }
    final excel = Excel.decodeBytes(normalizeExcelNamespaces(bytes));
    final sheets = <CourseSheet>[];
    for (final entry in excel.tables.entries) {
      final rows = entry.value.rows
          .map(
            (row) => row
                .map((cell) => cell?.value?.toString().trim() ?? '')
                .toList(),
          )
          .toList();
      final sheet = parseRows(entry.key, rows);
      if (sheet != null) sheets.add(sheet);
    }
    if (sheets.isEmpty) {
      throw const FormatException(
        '未找到课表表头：课程名称、星期、开始节数、结束节数、周数。请使用逐行列出课程的 .xlsx 文件',
      );
    }
    return sheets;
  }

  static CourseSheet? parseRows(String name, List<List<String>> rows) {
    String canonical(String text) =>
        switch (text.replaceAll(RegExp(r'\s+'), '')) {
          '课程名' || '课程' => '课程名称',
          '星期几' || '周几' || '上课星期' => '星期',
          '开始节次' || '起始节次' || '起始节数' || '开始节' || '起始节' => '开始节数',
          '结束节次' || '终止节次' || '终止节数' || '结束节' || '终止节' => '结束节数',
          '周次' || '上课周次' => '周数',
          '教师' ||
          '任课教师' ||
          '任课老师' ||
          '授课教师' ||
          '上课教师' ||
          '教师姓名' ||
          '任课教师姓名' => '老师',
          '教室' || '上课地点' || '上课教室' || '教室名称' || '场地' => '地点',
          final text => text,
        };
    const required = ['课程名称', '星期', '开始节数', '结束节数', '周数'];
    for (
      var headerRow = 0;
      headerRow < rows.length && headerRow < 20;
      headerRow++
    ) {
      final headers = rows[headerRow].map(canonical).toList();
      if (!required.every(headers.contains)) continue;
      if (required.any(
        (key) => headers.where((header) => header == key).length != 1,
      )) {
        throw const FormatException('课表必要列存在重复表头');
      }
      final courses = <CourseEntry>[];
      final warnings = <String>[];
      if (rows.length > 2001) throw const FormatException('课表最多支持 2000 行');
      for (var index = headerRow + 1; index < rows.length; index++) {
        final row = rows[index];
        if (row.every((cell) => cell.trim().isEmpty)) continue;
        String get(String key) {
          final i = headers.indexOf(key);
          return i >= 0 && i < row.length ? row[i].trim() : '';
        }

        final title = get('课程名称');
        try {
          if (title.isEmpty || title.length > 120) {
            throw const FormatException('课程名称为空或超过 120 字符');
          }
          final weekday = parseWeekday(get('星期'));
          final start = int.tryParse(get('开始节数'));
          final end = int.tryParse(get('结束节数'));
          if (weekday == null || start == null || end == null) {
            throw const FormatException('缺少或无法识别星期、开始节数、结束节数，请补充排课信息');
          }
          if (start < 1 || end > 24 || end < start) {
            throw const FormatException('节数应在 1–24 内，结束节数不能早于开始');
          }
          final weeks = parseWeeks(get('周数'));
          courses.add(
            CourseEntry(
              sourceRow: index + 1,
              title: title,
              weekday: weekday,
              startPeriod: start,
              endPeriod: end,
              weeks: weeks,
              weekText: get('周数'),
              teacher: get('老师'),
              location: get('地点'),
            ),
          );
        } on FormatException catch (error) {
          warnings.add('第 ${index + 1} 行 $title：${error.message}');
        }
      }
      return CourseSheet(name: name, courses: courses, warnings: warnings);
    }
    return null;
  }

  static int? parseWeekday(String source) {
    final text = source
        .replaceAll(RegExp(r'\s+'), '')
        .replaceFirst(RegExp(r'^(星期|周)'), '');
    final value =
        int.tryParse(text) ??
        const {
          '一': 1,
          '二': 2,
          '三': 3,
          '四': 4,
          '五': 5,
          '六': 6,
          '日': 7,
          '天': 7,
        }[text];
    return value != null && value >= 1 && value <= 7 ? value : null;
  }

  static List<int> parseWeeks(String source) {
    final text = source
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp('[～~—–]'), '-');
    final result = <int>{};
    for (final part in text.split(RegExp('[、,，;；]'))) {
      final match = RegExp(
        r'^第?(\d+)(?:-(\d+))?周?(?:[（(]?([单双])周?[）)]?)?$',
      ).firstMatch(part);
      if (match == null) {
        throw FormatException('无法识别周数“$source”，示例：1-16、3-17单、7-10、12、15-17');
      }
      final first = int.parse(match[1]!);
      final last = int.parse(match[2] ?? match[1]!);
      if (first < 1 || last > 53 || last < first) {
        throw const FormatException('周数应在 1–53 内且范围不能倒序');
      }
      for (var week = first; week <= last; week++) {
        if (match[3] == '单' && week.isEven || match[3] == '双' && week.isOdd) {
          continue;
        }
        result.add(week);
      }
    }
    if (result.isEmpty) throw const FormatException('该周数范围没有可排课周次');
    return result.toList()..sort();
  }
}
