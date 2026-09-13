enum VocabularyTestMode { wordToMeaning, meaningRecall, spelling }

extension VocabularyTestModeInfo on VocabularyTestMode {
  String get routeName => switch (this) {
    VocabularyTestMode.wordToMeaning => 'word-meaning',
    VocabularyTestMode.meaningRecall => 'meaning-recall',
    VocabularyTestMode.spelling => 'spelling',
  };

  String get title => switch (this) {
    VocabularyTestMode.wordToMeaning => '看词选义',
    VocabularyTestMode.meaningRecall => '看义回忆单词',
    VocabularyTestMode.spelling => '单词拼写',
  };

  String get description => switch (this) {
    VocabularyTestMode.wordToMeaning => '查看英文，从多个释义中选择正确答案',
    VocabularyTestMode.meaningRecall => '查看释义，在心中回忆后自行确认',
    VocabularyTestMode.spelling => '根据释义完整输入英文单词',
  };

  static VocabularyTestMode? fromRoute(String value) {
    for (final mode in VocabularyTestMode.values) {
      if (mode.routeName == value) return mode;
    }
    return null;
  }
}
