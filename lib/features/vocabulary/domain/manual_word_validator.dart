/// Offline format checks only; this does not verify spelling or translation.
abstract final class ManualWordValidator {
  static const maxWordLength = 80;
  static const maxMeaningLength = 500;

  static String normalizeWord(String value) =>
      value.trim().replaceAll('’', "'").replaceAll('‘', "'");

  static String? wordError(String? value) {
    final word = normalizeWord(value ?? '');
    if (word.isEmpty) return '请输入单词';
    if (word.length > maxWordLength) return '单词最多填写 80 个字符';
    if (!RegExp(r"^[A-Za-z]+(?:[-'][A-Za-z]+)*$").hasMatch(word)) {
      return '请输入英文单词；仅支持字母及词内连字符、撇号';
    }
    return null;
  }

  static String? meaningError(String? value) {
    final raw = value ?? '';
    final meaning = raw.trim();
    if (meaning.isEmpty) return '请输入意思';
    if (meaning.runes.length > maxMeaningLength) return '意思最多填写 500 个字符';
    // Allow line breaks but reject invisible controls and direction overrides.
    if (RegExp(
          r'[\x00-\x09\x0B\x0C\x0E-\x1F\x7F-\x9F\u200B-\u200F\u202A-\u202E\u2060-\u206F\uFEFF]',
        ).hasMatch(raw) ||
        raw.contains('\uFFFD')) {
      return '意思含有不可见字符或乱码，请清理后重试';
    }
    if (!RegExp(
      r'[\u3400-\u9FFF\uF900-\uFAFF\u{20000}-\u{323AF}]',
      unicode: true,
    ).hasMatch(meaning)) {
      return '意思需包含中文释义，不能只填英文、数字或符号';
    }
    return null;
  }
}
