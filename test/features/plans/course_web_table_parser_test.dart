import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/plans/data/course_web_table_parser.dart';

void main() {
  test('读取逐行课程明细网页表格', () {
    final result = CourseWebTableParser.parseExtractionResult(
      jsonEncode({
        'title': '教务系统',
        'tables': [
          {
            'name': '课程明细',
            'cells': _cells([
              ['课程名称', '星期', '开始节数', '结束节数', '老师', '地点', '周数'],
              ['大学英语', '星期三', '3', '4', '李老师', '教一205', '1-16周'],
            ]),
          },
        ],
      }),
    );

    expect(result, hasLength(1));
    expect(result.single.courses.single.title, '大学英语');
    expect(result.single.courses.single.weekday, 3);
    expect(result.single.courses.single.location, '教一205');
    expect(result.single.courses.single.weeks, hasLength(16));
  });

  test('读取星期网格网页课表并识别合并节次', () {
    final result = CourseWebTableParser.parseExtractionResult(
      jsonEncode({
        'title': '学生课表',
        'tables': [
          {
            'cells': [
              _cell(0, 0, '节次'),
              _cell(0, 1, '星期一'),
              _cell(0, 2, '星期二'),
              _cell(1, 0, '第1节'),
              _cell(2, 0, '第2节'),
              _cell(1, 1, '高等数学\n1-16周\n教师：张老师\n地点：教学楼101', rowSpan: 2),
            ],
          },
        ],
      }),
    );

    final course = result.single.courses.single;
    expect(course.title, '高等数学');
    expect(course.weekday, 1);
    expect(course.startPeriod, 1);
    expect(course.endPeriod, 2);
    expect(course.teacher, '张老师');
    expect(course.location, '教学楼101');
  });

  test('单行标签内容可分割课程、教师与上课地点', () {
    final result = CourseWebTableParser.parseExtractionResult(
      jsonEncode({
        'title': '正方教务系统',
        'tables': [
          {
            'cells': [
              _cell(0, 0, '节次'),
              _cell(0, 1, '星期一'),
              _cell(0, 2, '星期二'),
              _cell(1, 0, '1-2节'),
              _cell(1, 1, '课程名称：数据结构 教师：王小明 上课地点：博学楼B201 周次：1-16周'),
            ],
          },
        ],
      }),
    );

    final course = result.single.courses.single;
    expect(course.title, '数据结构');
    expect(course.teacher, '王小明');
    expect(course.location, '博学楼B201');
  });

  test('无标签换行内容按课程、教师、周次、教室顺序识别', () {
    final result = CourseWebTableParser.parseExtractionResult(
      jsonEncode({
        'title': '学生课表',
        'tables': [
          {
            'cells': [
              _cell(0, 0, '节次'),
              _cell(0, 1, '周一'),
              _cell(0, 2, '周二'),
              _cell(1, 0, '第3-4节'),
              _cell(1, 1, '操作系统\n李华、赵明\n1-8周\n东区第二教学楼301'),
            ],
          },
        ],
      }),
    );

    final course = result.single.courses.single;
    expect(course.title, '操作系统');
    expect(course.teacher, '李华、赵明');
    expect(course.location, '东区第二教学楼301');
  });

  test('无标签紧凑内容可拆分课程、节次、校区教室、教师和课程类型', () {
    final result = CourseWebTableParser.parseExtractionResult(
      jsonEncode({
        'title': '学生课表',
        'tables': [
          {
            'cells': [
              _cell(0, 0, '节次'),
              _cell(0, 1, '星期一'),
              _cell(0, 2, '星期二'),
              _cell(1, 0, '第5-6节'),
              _cell(1, 1, '机器学习★(5-6节)东校区博学楼222喻莎选修\n3-18周'),
            ],
          },
        ],
      }),
    );

    final course = result.single.courses.single;
    expect(course.title, '机器学习★');
    expect(course.startPeriod, 5);
    expect(course.endPeriod, 6);
    expect(course.teacher, '喻莎');
    expect(course.location, '东校区博学楼222');
    expect(course.weeks, hasLength(16));
  });

  test('没有网页表格时给出明确提示', () {
    expect(
      () => CourseWebTableParser.parseExtractionResult(
        jsonEncode({'title': '首页', 'tables': []}),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('没有找到可读取的课表'),
        ),
      ),
    );
  });
}

List<Map<String, Object>> _cells(List<List<String>> rows) => [
  for (var row = 0; row < rows.length; row++)
    for (var column = 0; column < rows[row].length; column++)
      _cell(row, column, rows[row][column]),
];

Map<String, Object> _cell(
  int row,
  int column,
  String text, {
  int rowSpan = 1,
  int columnSpan = 1,
}) => {
  'row': row,
  'column': column,
  'rowSpan': rowSpan,
  'columnSpan': columnSpan,
  'text': text,
};
