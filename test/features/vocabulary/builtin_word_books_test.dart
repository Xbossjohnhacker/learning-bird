import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/features/vocabulary/data/builtin_word_catalog.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/builtin_word_book.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

const fixtureBook = BuiltinWordBook(
  id: 'kaoyan',
  name: '考研英语',
  description: '测试词库',
  count: 2,
  sha256: '',
);
const fixtureRows = [
  WordImportRow(word: 'focus', meaning: '专注'),
  WordImportRow(word: 'persist', meaning: '坚持'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late VocabularyRepository repository;
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VocabularyRepository(database);
  });
  tearDown(() => database.close());

  test('三本真实离线资产校验、分类、全量入库及新词规则', () async {
    final catalog = BuiltinWordCatalog();
    final books = await catalog.loadCatalog();
    expect(books.map((book) => book.id), ['kaoyan', 'cet4', 'cet6']);
    expect(books.map((book) => book.count), [4801, 3849, 5805]);
    final allWords = <String>{};
    final wordSets = <String, Set<String>>{};
    for (final book in books) {
      final rows = await catalog.loadWords(book);
      final normalized = rows.map((row) => row.word.toLowerCase()).toSet();
      expect(normalized.length, book.count);
      expect(
        rows.every((row) => RegExp(r'[\u3400-\u9fff]').hasMatch(row.meaning)),
        isTrue,
      );
      wordSets[book.id] = normalized;
      allWords.addAll(normalized);
      final id = await repository.installBuiltinWordBook(book, rows);
      expect(await repository.watchBookWords(id).first, hasLength(book.count));
      final queue = await repository.loadStudyQueue(id);
      expect(queue, isNotEmpty);
      expect(
        queue.every(
          (word) => word.needsConfirmation && word.confirmationCount == 0,
        ),
        isTrue,
      );
    }
    expect(wordSets['cet6']!.containsAll(wordSets['cet4']!), isTrue);
    expect(
      await database.select(database.words).get(),
      hasLength(allWords.length),
    );
    expect(
      await database.select(database.wordBookItems).get(),
      hasLength(14455),
    );
    expect(await database.select(database.importRecords).get(), isEmpty);
    expect(await catalog.loadLicense(), contains('MIT License'));
  });

  test('损坏的词库校验值会被拒绝', () async {
    await expectLater(
      BuiltinWordCatalog().loadWords(fixtureBook),
      throwsFormatException,
    );
  });

  test('重复添加与并发添加只创建一本并保留认识进度', () async {
    final ids = await Future.wait([
      repository.installBuiltinWordBook(fixtureBook, fixtureRows),
      repository.installBuiltinWordBook(fixtureBook, fixtureRows),
    ]);
    expect(ids[0], ids[1]);
    final word = (await repository.loadStudyQueue(ids[0])).first;
    await repository.recordReview(word: word, rating: ReviewRating.remembered);
    expect(
      await repository.installBuiltinWordBook(fixtureBook, fixtureRows),
      ids[0],
    );
    expect(await database.select(database.wordBooks).get(), hasLength(1));
    expect(await database.select(database.wordBookItems).get(), hasLength(2));
    final queue = await repository.loadStudyQueue(ids[0]);
    expect(
      queue.singleWhere((item) => item.itemId == word.itemId).confirmationCount,
      1,
    );
    expect(await database.select(database.reviewRecords).get(), hasLength(1));
  });

  test('同名自建词书和已有自定义释义不被覆盖', () async {
    final manual = await repository.createWordBook('考研英语');
    await repository.importRows(
      wordBookId: manual,
      fileName: 'mine.csv',
      sourceType: 'csv',
      sourceFingerprint: 'mine',
      duplicateStrategy: DuplicateStrategy.skip,
      rows: const [WordImportRow(word: 'focus', meaning: '我的专属释义')],
    );
    final id = await repository.installBuiltinWordBook(
      fixtureBook,
      fixtureRows,
    );
    expect(id, isNot(manual));
    final rows = await repository.watchBookWords(id).first;
    expect(rows.singleWhere((row) => row.word == 'focus').meaning, '我的专属释义');
    expect(await database.select(database.words).get(), hasLength(2));
    expect(await repository.watchBookWords(manual).first, hasLength(1));
  });

  test('删除后可重新添加预置词书', () async {
    final id = await repository.installBuiltinWordBook(
      fixtureBook,
      fixtureRows,
    );
    await repository.deleteWordBook(id);
    final restored = await repository.installBuiltinWordBook(
      fixtureBook,
      fixtureRows,
    );
    expect(await repository.watchBookWords(restored).first, hasLength(2));
    expect(await database.select(database.wordBooks).get(), hasLength(1));
    expect(
      (await repository.loadStudyQueue(
        restored,
      )).every((word) => word.confirmationCount == 0),
      isTrue,
    );
  });

  test('无效数据不会创建空词书', () async {
    await expectLater(
      repository.installBuiltinWordBook(fixtureBook, []),
      throwsFormatException,
    );
    await expectLater(
      repository.installBuiltinWordBook(fixtureBook, [
        fixtureRows[0],
        fixtureRows[0],
      ]),
      throwsFormatException,
    );
    expect(await database.select(database.wordBooks).get(), isEmpty);
  });

  test('入库中途失败会整体回滚', () async {
    await database.customStatement('''
CREATE TRIGGER reject_builtin BEFORE INSERT ON word_book_items
BEGIN SELECT RAISE(ABORT, 'test failure'); END;
''');
    await expectLater(
      repository.installBuiltinWordBook(fixtureBook, fixtureRows),
      throwsA(isA<Exception>()),
    );
    expect(await database.select(database.wordBooks).get(), isEmpty);
    expect(await database.select(database.words).get(), isEmpty);
    expect(await database.select(database.wordBookItems).get(), isEmpty);
  });
}
