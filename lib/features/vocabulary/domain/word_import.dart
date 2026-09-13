enum DuplicateStrategy { skip, overwrite }

extension DuplicateStrategyLabel on DuplicateStrategy {
  String get label => switch (this) {
    DuplicateStrategy.skip => '跳过词书内重复项',
    DuplicateStrategy.overwrite => '用新内容覆盖',
  };
}

class WordImportRow {
  const WordImportRow({
    required this.word,
    required this.meaning,
    this.phonetic,
    this.example,
    this.exampleTranslation,
    this.phrase,
    this.note,
    this.tags,
  });

  final String word;
  final String meaning;
  final String? phonetic;
  final String? example;
  final String? exampleTranslation;
  final String? phrase;
  final String? note;
  final String? tags;
}

class ImportRowError {
  const ImportRowError({required this.sourceRow, required this.message});

  final int sourceRow;
  final String message;
}

class ImportMappingResult {
  const ImportMappingResult({required this.rows, required this.errors});

  final List<WordImportRow> rows;
  final List<ImportRowError> errors;
}

class ImportFieldMapping {
  const ImportFieldMapping({
    required this.word,
    required this.meaning,
    this.phonetic,
    this.example,
    this.exampleTranslation,
    this.phrase,
    this.note,
    this.tags,
  });

  final String word;
  final String meaning;
  final String? phonetic;
  final String? example;
  final String? exampleTranslation;
  final String? phrase;
  final String? note;
  final String? tags;

  static ImportFieldMapping? auto(List<String> headers) {
    String? find(List<String> candidates) {
      for (final header in headers) {
        final normalized = header.trim().toLowerCase();
        if (candidates.contains(normalized)) {
          return header;
        }
      }
      return null;
    }

    final word = find(['word', '单词', '英文']);
    final meaning = find(['meaning', '意思', '释义', '中文释义', '中文']);
    if (word == null || meaning == null) {
      return null;
    }

    return ImportFieldMapping(
      word: word,
      meaning: meaning,
      phonetic: find(['phonetic', '音标']),
      example: find(['example', '例句']),
      exampleTranslation: find(['example_translation', '例句翻译']),
      phrase: find(['phrase', '短语']),
      note: find(['note', '笔记']),
      tags: find(['tags', '标签']),
    );
  }

  ImportFieldMapping copyWith({
    String? word,
    String? meaning,
    String? phonetic,
    String? example,
  }) {
    return ImportFieldMapping(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      phonetic: phonetic ?? this.phonetic,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation,
      phrase: phrase,
      note: note,
      tags: tags,
    );
  }
}

class ImportBatchResult {
  const ImportBatchResult({
    required this.batchUuid,
    required this.successCount,
    required this.skippedCount,
    required this.failedCount,
  });

  final String batchUuid;
  final int successCount;
  final int skippedCount;
  final int failedCount;
}
