import 'dart:convert';

import '../domain/course_import.dart';
import 'course_file_parser.dart';

class CourseWebCell {
  const CourseWebCell({
    required this.row,
    required this.column,
    required this.rowSpan,
    required this.columnSpan,
    required this.text,
  });

  final int row;
  final int column;
  final int rowSpan;
  final int columnSpan;
  final String text;
}

abstract final class CourseWebTableParser {
  static const _metadataLabels =
      r'(?:课程名称|课程名|课程|任课教师姓名|任课教师|任课老师|授课教师|上课教师|教师姓名|教师|老师|上课地点|上课教室|教室名称|地点|教室|场地|上课周次|周次|周数|上课时间|时间|节次)';
  static final _weekPattern = RegExp(
    r'第?\s*\d{1,2}(?:\s*[-～~—–]\s*\d{1,2})?'
    r'(?:\s*[、,，;；]\s*\d{1,2}(?:\s*[-～~—–]\s*\d{1,2})?)*'
    r'\s*周(?:\s*[（(]?[单双]\s*周?[）)]?)?',
  );
  static final _compactPeriodPattern = RegExp(
    r'[（(]\s*\d{1,2}\s*(?:[-～~—–至]\s*\d{1,2}\s*)?节\s*[）)]',
  );

  static List<CourseSheet> parseExtractionResult(Object result) {
    dynamic decoded = result;
    for (var attempt = 0; attempt < 2 && decoded is String; attempt++) {
      try {
        decoded = jsonDecode(decoded);
      } on FormatException {
        break;
      }
    }
    if (decoded is! Map) {
      throw const FormatException('教务网页返回的数据无法识别');
    }
    final pageTitle = decoded['title']?.toString().trim();
    final rawTables = decoded['tables'];
    if (rawTables is! List || rawTables.isEmpty) {
      throw const FormatException('当前页面没有找到可读取的课表，请先进入“我的课表”或“课表查询”页面');
    }

    final sheets = <CourseSheet>[];
    for (var tableIndex = 0; tableIndex < rawTables.length; tableIndex++) {
      final rawTable = rawTables[tableIndex];
      if (rawTable is! Map) continue;
      final cells = _parseCells(rawTable['cells']);
      if (cells.isEmpty) continue;
      final tableName = rawTable['name']?.toString().trim();
      final name = tableName?.isNotEmpty == true
          ? tableName!
          : pageTitle?.isNotEmpty == true
          ? '$pageTitle · 表${tableIndex + 1}'
          : '网页课表 ${tableIndex + 1}';
      final rowSheet = CourseFileParser.parseRows(name, _toRows(cells));
      if (rowSheet != null) {
        sheets.add(rowSheet);
        continue;
      }
      final gridSheet = _parseGrid(name, cells);
      if (gridSheet != null) sheets.add(gridSheet);
    }
    if (sheets.isEmpty) {
      throw const FormatException(
        '找到了网页表格，但没有识别出课程。请确认当前页显示课程名称、星期、节次和周次；部分特殊教务系统暂不兼容',
      );
    }
    return sheets;
  }

  static List<CourseWebCell> _parseCells(dynamic rawCells) {
    if (rawCells is! List || rawCells.length > 4000) return const [];
    final result = <CourseWebCell>[];
    for (final raw in rawCells) {
      if (raw is! Map) continue;
      final row = (raw['row'] as num?)?.toInt();
      final column = (raw['column'] as num?)?.toInt();
      final rowSpan = (raw['rowSpan'] as num?)?.toInt() ?? 1;
      final columnSpan = (raw['columnSpan'] as num?)?.toInt() ?? 1;
      final text = raw['text']?.toString().trim() ?? '';
      if (row == null ||
          column == null ||
          row < 0 ||
          column < 0 ||
          rowSpan < 1 ||
          columnSpan < 1 ||
          rowSpan > 100 ||
          columnSpan > 20) {
        continue;
      }
      result.add(
        CourseWebCell(
          row: row,
          column: column,
          rowSpan: rowSpan,
          columnSpan: columnSpan,
          text: text,
        ),
      );
    }
    return result;
  }

  static List<List<String>> _toRows(List<CourseWebCell> cells) {
    final height = cells.fold<int>(
      0,
      (value, cell) => cell.row + 1 > value ? cell.row + 1 : value,
    );
    final width = cells.fold<int>(
      0,
      (value, cell) => cell.column + 1 > value ? cell.column + 1 : value,
    );
    return [
      for (var row = 0; row < height; row++)
        [
          for (var column = 0; column < width; column++)
            cells
                    .where((cell) => cell.row == row && cell.column == column)
                    .map((cell) => cell.text)
                    .firstOrNull ??
                '',
        ],
    ];
  }

  static CourseSheet? _parseGrid(String name, List<CourseWebCell> cells) {
    var headerRow = -1;
    var weekdayByColumn = <int, int>{};
    for (final row in cells.map((cell) => cell.row).toSet().toList()..sort()) {
      final found = <int, int>{};
      for (final cell in cells.where((cell) => cell.row == row)) {
        final weekday = _weekdayHeader(cell.text);
        if (weekday == null) continue;
        for (var offset = 0; offset < cell.columnSpan; offset++) {
          found[cell.column + offset] = weekday;
        }
      }
      if (found.length >= 2) {
        headerRow = row;
        weekdayByColumn = found;
        break;
      }
    }
    if (headerRow < 0) return null;

    final courses = <CourseEntry>[];
    final warnings = <String>[];
    final signatures = <String>{};
    final firstWeekdayColumn = weekdayByColumn.keys.reduce(
      (a, b) => a < b ? a : b,
    );
    for (final cell in cells.where(
      (cell) => cell.row > headerRow && cell.text.trim().isNotEmpty,
    )) {
      for (var offset = 0; offset < cell.columnSpan; offset++) {
        final weekday = weekdayByColumn[cell.column + offset];
        if (weekday == null || _weekdayHeader(cell.text) != null) continue;
        final period = _periodForRow(cells, cell.row, firstWeekdayColumn);
        if (period == null) {
          _addWarning(warnings, '网页表格第 ${cell.row + 1} 行无法识别上课节次');
          continue;
        }
        final details = _courseDetails(cell.text);
        if (details == null) {
          _addWarning(
            warnings,
            '网页表格第 ${cell.row + 1} 行“${_shortText(cell.text)}”缺少课程名称或周次',
          );
          continue;
        }
        final endPeriod = period.$2 > period.$1
            ? period.$2
            : period.$1 + cell.rowSpan - 1;
        if (period.$1 < 1 || endPeriod > 24) {
          _addWarning(warnings, '网页表格第 ${cell.row + 1} 行节次超出 1–24');
          continue;
        }
        final signature =
            '${details.$1}|$weekday|${period.$1}|$endPeriod|${details.$2.join(',')}';
        if (!signatures.add(signature)) continue;
        courses.add(
          CourseEntry(
            sourceRow: cell.row + 1,
            title: details.$1,
            weekday: weekday,
            startPeriod: period.$1,
            endPeriod: endPeriod,
            weeks: details.$2,
            weekText: details.$3,
            teacher: details.$4,
            location: details.$5,
          ),
        );
      }
    }
    if (courses.isEmpty && warnings.isEmpty) return null;
    return CourseSheet(name: name, courses: courses, warnings: warnings);
  }

  static int? _weekdayHeader(String source) {
    final text = source.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(?:星期|周)?[一二三四五六日天1-7]$').hasMatch(text)) {
      return null;
    }
    return CourseFileParser.parseWeekday(text);
  }

  static (int, int)? _periodForRow(
    List<CourseWebCell> cells,
    int row,
    int firstWeekdayColumn,
  ) {
    final labels = cells.where(
      (cell) =>
          cell.column < firstWeekdayColumn &&
          cell.row <= row &&
          row < cell.row + cell.rowSpan,
    );
    for (final cell in labels) {
      for (final line in cell.text.split(RegExp(r'[\n\r]+'))) {
        final text = line.trim();
        final match = RegExp(
          r'(?:第\s*)?(\d{1,2})(?:\s*[-～~—–至到]\s*(\d{1,2}))?\s*节',
        ).firstMatch(text);
        final compact =
            match ??
            RegExp(r'^(\d{1,2})(?:\s*[-～~—–]\s*(\d{1,2}))?$').firstMatch(text);
        if (compact == null) continue;
        final start = int.parse(compact[1]!);
        final end = int.parse(compact[2] ?? compact[1]!);
        if (start >= 1 && end >= start && end <= 24) return (start, end);
      }
    }
    return null;
  }

  static (String, List<int>, String, String, String)? _courseDetails(
    String source,
  ) {
    final text = source.replaceAll('\u00a0', ' ').trim();
    final weekMatch = _weekPattern.firstMatch(text);
    if (weekMatch == null) return null;
    final weekText = weekMatch.group(0)!.replaceAll(RegExp(r'\s+'), '');
    List<int> weeks;
    try {
      weeks = CourseFileParser.parseWeeks(weekText);
    } on FormatException {
      return null;
    }

    var teacher = _labelValue(text, const [
      '任课教师姓名',
      '任课教师',
      '任课老师',
      '授课教师',
      '上课教师',
      '教师姓名',
      '教师',
      '老师',
    ]);
    var location = _labelValue(text, const [
      '上课地点',
      '上课教室',
      '教室名称',
      '地点',
      '教室',
      '场地',
    ]);
    final lines = text
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    var title = _labelValue(text, const ['课程名称', '课程名', '课程']);
    var titleLine = -1;
    if (title.isNotEmpty) {
      title = title.replaceAll(_weekPattern, '').trim();
    }
    for (var index = 0; title.isEmpty && index < lines.length; index++) {
      final line = lines[index];
      final candidate = line
          .replaceAll(_weekPattern, '')
          .replaceAll(RegExp(r'^(?:课程名称|课程名|课程)\s*[:：]\s*'), '')
          .split(RegExp('$_metadataLabels\\s*[:：]'))
          .first
          .trim();
      if (candidate.isEmpty ||
          RegExp('^$_metadataLabels\\s*(?:[:：]|\$)').hasMatch(candidate) ||
          RegExp(r'^第?\d+(?:[-～~—–]\d+)?节$').hasMatch(candidate) ||
          RegExp(r'^\d{1,2}:\d{2}').hasMatch(candidate)) {
        continue;
      }
      title = candidate;
      titleLine = index;
      break;
    }
    final compact = _splitCompactCourseLine(title);
    if (compact != null) {
      title = compact.$1;
      if (location.isEmpty) location = compact.$2;
      if (teacher.isEmpty) teacher = compact.$3;
    }
    if (title.isEmpty || title.length > 120) return null;
    if (location.isEmpty) {
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (index != titleLine && _looksLikeLocation(line)) {
          location = line.replaceFirst(
            RegExp(r'^(?:上课地点|上课教室|教室名称|地点|教室|场地)\s*[:：]?\s*'),
            '',
          );
          break;
        }
      }
    }
    if (teacher.isEmpty) {
      for (var index = 0; index < lines.length; index++) {
        if (index == titleLine) continue;
        var candidate = lines[index]
            .replaceFirst(
              RegExp(r'^(?:任课教师姓名|任课教师|任课老师|授课教师|上课教师|教师姓名|教师|老师)\s*[:：]?\s*'),
              '',
            )
            .trim();
        if (_looksLikeTeacher(candidate, title: title, location: location)) {
          teacher = candidate;
          break;
        }
      }
    }
    return (title, weeks, weekText, teacher, location);
  }

  static (String, String, String)? _splitCompactCourseLine(String value) {
    final period = _compactPeriodPattern.firstMatch(value);
    if (period == null || period.start == 0) return null;
    final title = value.substring(0, period.start).trim();
    if (title.isEmpty) return null;
    var remainder = value
        .substring(period.end)
        .replaceAll(_weekPattern, '')
        .trim();
    remainder = remainder
        .replaceFirst(RegExp(r'(?:必修|选修|限选|任选|考查|考试|专业课|公共课|正常)+$'), '')
        .trim();
    if (remainder.isEmpty) return (title, '', '');

    final locationMatch = RegExp(
      r'^(.+?(?:教学楼|实验楼|实训楼|图书馆|体育馆|实验室|实训室|体育场|操场|场地|楼|馆)(?:[A-Za-z0-9-]{0,12}))',
    ).firstMatch(remainder);
    final fallbackLocation =
        locationMatch ?? RegExp(r'^(.+?校区|线上)').firstMatch(remainder);
    if (fallbackLocation == null) return (title, '', '');

    final location = fallbackLocation.group(1)!.trim();
    final possibleTeacher = remainder.substring(fallbackLocation.end).trim();
    final teacher =
        _looksLikeTeacher(possibleTeacher, title: title, location: location)
        ? possibleTeacher
        : '';
    return (title, location, teacher);
  }

  static String _labelValue(String text, List<String> labels) {
    for (final label in labels) {
      final explicit = RegExp(
        '(?:^|[\\s;；|])$label\\s*[:：]\\s*(.+?)'
        '(?=\\s+$_metadataLabels\\s*[:：]|[\\n\\r;；|]|\$)',
        multiLine: true,
      ).firstMatch(text);
      if (explicit != null && explicit[1]!.trim().isNotEmpty) {
        return explicit[1]!.trim();
      }
      final spaced = RegExp(
        '(?:^|[\\n\\r;；|])\\s*$label\\s+(.+?)'
        '(?=\\s+$_metadataLabels(?:\\s*[:：]|\\s+)|[\\n\\r;；|]|\$)',
        multiLine: true,
      ).firstMatch(text);
      if (spaced != null && spaced[1]!.trim().isNotEmpty) {
        return spaced[1]!.trim();
      }
    }
    return '';
  }

  static bool _looksLikeLocation(String value) {
    final text = value.trim();
    return text.isNotEmpty &&
        (text.contains(RegExp(r'(楼|教室|校区|馆|实验室|实训室|场地|体育场|操场|线上)')) ||
            RegExp(r'^[A-Za-z]{1,8}[- ]?\d{2,4}$').hasMatch(text));
  }

  static bool _looksLikeTeacher(
    String value, {
    required String title,
    required String location,
  }) {
    final text = value.trim();
    if (text.isEmpty ||
        text == title ||
        text == location ||
        text.length > 40 ||
        _weekPattern.hasMatch(text) ||
        _looksLikeLocation(text) ||
        RegExp(r'\d{1,2}:\d{2}|第?\d+(?:[-～~—–]\d+)?节').hasMatch(text) ||
        RegExp(
          r'^(?:必修|选修|专业课|公共课|正常|停课|未排|教学班.*|班级.*|课程代码.*)$',
        ).hasMatch(text)) {
      return false;
    }
    return RegExp(r'^[\u3400-\u9fffA-Za-z·•,，、\s()（）]{2,40}$').hasMatch(text);
  }

  static void _addWarning(List<String> warnings, String warning) {
    if (warnings.length < 30 && !warnings.contains(warning)) {
      warnings.add(warning);
    }
  }

  static String _shortText(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return compact.length <= 24 ? compact : '${compact.substring(0, 24)}…';
  }
}
