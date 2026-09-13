import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('Schema v1 可初始化并读写设置', () async {
    expect(await database.ping(), isTrue);

    await database.putSetting('theme_mode', 'dark');

    expect(await database.readSetting('theme_mode'), 'dark');
  });

  test('同一词书不会产生重复单词关系', () async {
    final bookId = await database
        .into(database.wordBooks)
        .insert(WordBooksCompanion.insert(name: '考研核心词'));
    final wordId = await database
        .into(database.words)
        .insert(
          WordsCompanion.insert(
            word: 'persevere',
            normalizedWord: 'persevere',
            meaning: '坚持',
          ),
        );

    await database
        .into(database.wordBookItems)
        .insert(
          WordBookItemsCompanion.insert(wordBookId: bookId, wordId: wordId),
        );

    expect(
      () => database
          .into(database.wordBookItems)
          .insert(
            WordBookItemsCompanion.insert(wordBookId: bookId, wordId: wordId),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('相同文件指纹可以保存为两个独立导入批次', () async {
    final bookId = await database
        .into(database.wordBooks)
        .insert(WordBooksCompanion.insert(name: '考研核心词'));
    final now = DateTime.utc(2026, 8, 26);

    for (var batch = 1; batch <= 2; batch++) {
      await database
          .into(database.importRecords)
          .insert(
            ImportRecordsCompanion.insert(
              batchUuid: 'batch-$batch',
              fileName: 'vocabulary.xlsx',
              sourceFingerprint: const Value('same-file-fingerprint'),
              sourceType: 'xlsx',
              targetWordBookId: bookId,
              startedAt: now.add(Duration(minutes: batch)),
              status: const Value('completed'),
              successCount: const Value(100),
            ),
          );
    }

    final records = await database.select(database.importRecords).get();

    expect(records, hasLength(2));
    expect(records.map((record) => record.batchUuid), {'batch-1', 'batch-2'});
  });
}
