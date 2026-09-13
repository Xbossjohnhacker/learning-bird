import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/release_info.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/plans/presentation/editor/plan_editor_page.dart';
import 'package:learning_bird/features/vocabulary/data/excel_namespace_normalizer.dart';
import 'package:learning_bird/features/vocabulary/data/word_file_parser.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

void main() {
  test('正式发布版本号与安装包声明一致', () {
    final source = File('pubspec.yaml').readAsStringSync();
    expect(
      source,
      contains('version: ${ReleaseInfo.version}+${ReleaseInfo.buildNumber}'),
    );
  });

  for (final source in [
    'word,word\nfocus,专注\n',
    'word, Word \nfocus,专注\n',
    'word,meaning\n,\n',
  ]) {
    test('拒绝重复表头或空数据：${source.split('\n').first}', () {
      expect(
        () => WordFileParser.parse(
          fileName: 'invalid.csv',
          bytes: Uint8List.fromList(utf8.encode(source)),
        ),
        throwsFormatException,
      );
    });
  }

  test('拒绝非 UTF-8 CSV，避免乱码数据入库', () {
    expect(
      () => WordFileParser.parse(
        fileName: 'invalid.csv',
        bytes: Uint8List.fromList([0xff, 0xfe, 0x80]),
      ),
      throwsFormatException,
    );
  });

  test('交付的 Excel 模板可被实际导入器完整识别', () {
    final table = WordFileParser.parse(
      fileName: 'word-import-template.xlsx',
      bytes: File('docs/templates/word-import-template.xlsx').readAsBytesSync(),
    );
    final mapping = ImportFieldMapping.auto(table.headers);
    expect(table.headers, ['单词', '意思']);
    expect(mapping, isNotNull);
    final result = table.mapRows(mapping!);
    expect(result.errors, isEmpty);
    expect(result.rows, hasLength(2));
    expect(result.rows.first.word, 'persist');
    expect(result.rows.first.meaning, '坚持');
    expect(result.rows.first.exampleTranslation, isNull);
    expect(result.rows.first.tags, isNull);
  });

  test('普通 Excel 文件仍可导入，XML 前缀样式的单元格文本不会被改写', () {
    final workbook = Excel.createExcel();
    workbook.tables.values.first.appendRow([
      TextCellValue('word'),
      TextCellValue('meaning'),
      TextCellValue('note'),
    ]);
    workbook.tables.values.first.appendRow([
      TextCellValue('focus'),
      TextCellValue('专注'),
      TextCellValue('x:原始文本'),
    ]);
    final table = WordFileParser.parse(
      fileName: 'ordinary.xlsx',
      bytes: Uint8List.fromList(workbook.encode()!),
    );
    final result = table.mapRows(ImportFieldMapping.auto(table.headers)!);
    expect(result.errors, isEmpty);
    expect(result.rows.single.note, 'x:原始文本');
  });

  test('Excel 兼容转换重复执行不会继续改变文件内容', () {
    final bytes = File(
      'docs/templates/word-import-template.xlsx',
    ).readAsBytesSync();
    final normalized = normalizeExcelNamespaces(bytes);
    expect(normalizeExcelNamespaces(normalized), orderedEquals(normalized));
  });

  testWidgets('新建分类确认与关闭动画不会提前释放输入框', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: PlanEditorPage(initialDate: DateTime.now())),
      ),
    );
    await tester.pumpAndSettle();
    final addCategory = find.byTooltip('新建分类');
    await tester.ensureVisible(addCategory);
    await tester.pumpAndSettle();
    await tester.tap(addCategory);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '英语专项',
    );
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final categories = await database.select(database.categories).get();
    expect(categories.map((category) => category.name), contains('英语专项'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
