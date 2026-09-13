import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/vocabulary/domain/manual_word_validator.dart';

void main() {
  test('允许英文单词、缩写词形和复合词', () {
    for (final value in [
      'focus',
      ' Focus ',
      'I',
      'a',
      "can't",
      'can’t',
      'well-known',
      'mother-in-law',
    ]) {
      expect(ManualWordValidator.wordError(value), isNull, reason: value);
    }
    expect(ManualWordValidator.normalizeWord(' can’t '), "can't");
  });

  test('拒绝非英文、数字、多个词、异常符号及超长单词', () {
    for (final value in [
      '',
      '  ',
      '单词',
      '123',
      'word123',
      'hello world',
      'hello\nworld',
      '-word',
      'word-',
      'well--known',
      "can''t",
      'focus!',
      '🙂',
      'fo\u200Bcus',
      List.filled(81, 'a').join(),
    ]) {
      expect(ManualWordValidator.wordError(value), isNotNull, reason: value);
    }
    expect(ManualWordValidator.wordError(List.filled(80, 'a').join()), isNull);
  });

  test('允许带词性、标点、编号和换行的中文释义', () {
    for (final value in [
      '专注',
      ' n. 焦点；v. 专注 ',
      '1.专注\n2.集中',
      '专注于（focus on）',
      '𠮷',
    ]) {
      expect(ManualWordValidator.meaningError(value), isNull, reason: value);
    }
    expect(
      ManualWordValidator.meaningError(List.filled(500, '词').join()),
      isNull,
    );
  });

  test('拒绝无中文、乱码、不可见字符与超长意思', () {
    for (final value in [
      '',
      ' ',
      'focus',
      '123',
      '!!!',
      '🙂',
      '专\u200B注',
      '专注\u202E',
      '专注\u0000',
      '专注\t',
      '专注\uFFFD',
      List.filled(501, '词').join(),
    ]) {
      expect(ManualWordValidator.meaningError(value), isNotNull, reason: value);
    }
  });
}
