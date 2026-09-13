import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/builtin_word_book.dart';
import '../domain/word_import.dart';

class BuiltinWordCatalog {
  BuiltinWordCatalog({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;

  Future<List<BuiltinWordBook>> loadCatalog() async {
    final data =
        jsonDecode(await _bundle.loadString('assets/wordbooks/catalog.json'))
            as Map<String, dynamic>;
    if (data['version'] != 1) throw const FormatException('不支持的内置词库版本');
    return (data['books'] as List)
        .map((raw) {
          final item = raw as Map<String, dynamic>;
          final id = item['id'] as String;
          if (!['kaoyan', 'cet4', 'cet6'].contains(id)) {
            throw const FormatException('未知的内置词书');
          }
          return BuiltinWordBook(
            id: id,
            name: item['name'] as String,
            description: item['description'] as String,
            count: item['count'] as int,
            sha256: item['sha256'] as String,
          );
        })
        .toList(growable: false);
  }

  Future<List<WordImportRow>> loadWords(BuiltinWordBook book) async {
    final source = await _bundle.loadString(book.assetPath);
    if (sha256.convert(utf8.encode(source)).toString() != book.sha256) {
      throw const FormatException('内置词库校验失败，请重新安装应用');
    }
    final rows = await compute(_parseRows, source);
    if (rows.length != book.count || rows.isEmpty) {
      throw const FormatException('内置词库数量不符');
    }
    return rows;
  }

  Future<String> loadLicense() =>
      _bundle.loadString('assets/wordbooks/ECDICT-LICENSE.txt');
}

List<WordImportRow> _parseRows(String source) {
  final seen = <String>{};
  return (jsonDecode(source) as List)
      .map((raw) {
        final row = raw as Map<String, dynamic>;
        final word = (row['word'] as String).trim();
        final meaning = (row['meaning'] as String).trim();
        if (word.isEmpty ||
            word.length > 120 ||
            meaning.isEmpty ||
            !seen.add(word.toLowerCase())) {
          throw const FormatException('内置词库存在无效或重复词条');
        }
        return WordImportRow(word: word, meaning: meaning);
      })
      .toList(growable: false);
}
