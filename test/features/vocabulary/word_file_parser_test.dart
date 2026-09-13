import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/vocabulary/data/word_file_parser.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

void main() {
  test('CSV 表头可自动映射并报告无效行', () {
    final bytes = Uint8List.fromList(
      utf8.encode(
        'word,meaning,phonetic,example\n'
        'persist,坚持,/pəˈsɪst/,Persist with your plan.\n'
        ',缺少单词,,\n',
      ),
    );

    final table = WordFileParser.parse(fileName: 'words.csv', bytes: bytes);
    final mapping = ImportFieldMapping.auto(table.headers);
    final result = table.mapRows(mapping!);

    expect(result.rows, hasLength(1));
    expect(result.rows.single.word, 'persist');
    expect(result.rows.single.meaning, '坚持');
    expect(result.errors, hasLength(1));
    expect(result.errors.single.sourceRow, 3);
  });

  test('不支持的扩展名会被拒绝', () {
    expect(
      () => WordFileParser.parse(fileName: 'words.txt', bytes: Uint8List(0)),
      throwsFormatException,
    );
  });
}
