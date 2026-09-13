import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'excel_namespace_normalizer.dart';

import '../domain/word_import.dart';

class TabularWordData {
  const TabularWordData({required this.headers, required this.rows});

  final List<String> headers;
  final List<Map<String, String>> rows;

  ImportMappingResult mapRows(ImportFieldMapping mapping) {
    final valid = <WordImportRow>[];
    final errors = <ImportRowError>[];

    for (var index = 0; index < rows.length; index++) {
      final source = rows[index];
      final word = (source[mapping.word] ?? '').trim();
      final meaning = (source[mapping.meaning] ?? '').trim();
      if (word.isEmpty || meaning.isEmpty) {
        errors.add(
          ImportRowError(
            sourceRow: index + 2,
            message: word.isEmpty ? '缺少英文单词' : '缺少中文释义',
          ),
        );
        continue;
      }

      String? optional(String? header) {
        if (header == null) return null;
        final value = (source[header] ?? '').trim();
        return value.isEmpty ? null : value;
      }

      valid.add(
        WordImportRow(
          word: word,
          meaning: meaning,
          phonetic: optional(mapping.phonetic),
          example: optional(mapping.example),
          exampleTranslation: optional(mapping.exampleTranslation),
          phrase: optional(mapping.phrase),
          note: optional(mapping.note),
          tags: optional(mapping.tags),
        ),
      );
    }

    return ImportMappingResult(rows: valid, errors: errors);
  }
}

abstract final class WordFileParser {
  static TabularWordData parse({
    required String fileName,
    required Uint8List bytes,
  }) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'csv' => _parseCsv(bytes),
      'xlsx' => _parseExcel(bytes),
      _ => throw const FormatException('仅支持 .csv 和 .xlsx 文件'),
    };
  }

  static TabularWordData _parseCsv(Uint8List bytes) {
    final content = utf8.decode(bytes).replaceFirst('\ufeff', '');
    final decoded = csv.decode(content);
    return _fromMatrix(decoded);
  }

  static TabularWordData _parseExcel(Uint8List bytes) {
    final workbook = Excel.decodeBytes(normalizeExcelNamespaces(bytes));
    if (workbook.tables.isEmpty) {
      throw const FormatException('Excel 中没有工作表');
    }
    final sheet = workbook.tables.values.first;

    final matrix = sheet.rows
        .map((row) => row.map(_cellText).toList(growable: false))
        .toList(growable: false);
    return _fromMatrix(matrix);
  }

  static TabularWordData _fromMatrix(List<List<dynamic>> matrix) {
    if (matrix.length < 2) {
      throw const FormatException('文件至少需要表头和一行数据');
    }
    final headers = matrix.first
        .map((value) => value.toString().trim())
        .toList(growable: false);
    if (headers.any((header) => header.isEmpty)) {
      throw const FormatException('表头不能为空');
    }
    if (headers.map((header) => header.toLowerCase()).toSet().length !=
        headers.length) {
      throw const FormatException('表头不能重复，请为每一列设置不同名称');
    }

    final rows = <Map<String, String>>[];
    for (final source in matrix.skip(1)) {
      if (source.every((value) => value.toString().trim().isEmpty)) continue;
      final row = <String, String>{};
      for (var column = 0; column < headers.length; column++) {
        row[headers[column]] = column < source.length
            ? source[column].toString()
            : '';
      }
      rows.add(row);
    }
    if (rows.isEmpty) {
      throw const FormatException('表头下至少需要一行单词数据');
    }
    return TabularWordData(headers: headers, rows: rows);
  }

  static String _cellText(Data? cell) {
    final value = cell?.value;
    return switch (value) {
      null => '',
      TextCellValue() => value.value.toString(),
      FormulaCellValue() => value.formula.toString(),
      IntCellValue() => value.value.toString(),
      DoubleCellValue() => value.value.toString(),
      BoolCellValue() => value.value.toString(),
      DateCellValue() => value.asDateTimeLocal().toIso8601String(),
      TimeCellValue() => value.asDuration().toString(),
      DateTimeCellValue() => value.asDateTimeLocal().toIso8601String(),
    };
  }
}
