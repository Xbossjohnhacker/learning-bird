import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/presentation/vocabulary_home_page.dart';
import 'package:learning_bird/features/vocabulary/presentation/import/word_import_page.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VocabularyRepository(db);
  });
  tearDown(() => db.close());

  test('手动添加去空格、建立新词并进入学习队列，不伪造导入批次', () async {
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: ' Focus ', meaning: ' 专注 ');
    final word = (await repository.loadStudyQueue(id)).single;
    expect(word.word, 'Focus');
    expect(word.meaning, '专注');
    expect((await db.select(db.words).getSingle()).normalizedWord, 'focus');
    expect(await db.select(db.importRecords).get(), isEmpty);
    expect((await repository.watchWordBooks().first).single.newCount, 1);
  });

  test('同词书重复添加不覆盖原意思和学习进度', () async {
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    final before = await db.select(db.wordBookItems).getSingle();
    await expectLater(
      repository.addWord(wordBookId: id, word: ' FOCUS ', meaning: '焦点'),
      throwsFormatException,
    );
    expect(await db.select(db.wordBookItems).getSingle(), before);
    expect((await db.select(db.words).getSingle()).meaning, '专注');
  });

  test('跨词书复用同意思单词，拒绝静默更改其他词书的意思', () async {
    final first = await repository.createWordBook('第一本');
    final second = await repository.createWordBook('第二本');
    await repository.addWord(wordBookId: first, word: 'focus', meaning: '专注');
    await expectLater(
      repository.addWord(wordBookId: second, word: 'focus', meaning: '焦点'),
      throwsFormatException,
    );
    expect(await repository.loadStudyQueue(second), isEmpty);
    await repository.addWord(wordBookId: second, word: 'FOCUS', meaning: '专注');
    expect(await db.select(db.words).get(), hasLength(1));
    expect(await db.select(db.wordBookItems).get(), hasLength(2));
  });

  test('空输入与已删除词书不产生孤立数据', () async {
    final id = await repository.createWordBook('英语');
    await expectLater(
      repository.addWord(wordBookId: id, word: ' ', meaning: '意思'),
      throwsFormatException,
    );
    await expectLater(
      repository.addWord(wordBookId: id, word: 'word', meaning: ' '),
      throwsFormatException,
    );
    await repository.deleteWordBook(id);
    await expectLater(
      repository.addWord(wordBookId: id, word: 'focus', meaning: '专注'),
      throwsFormatException,
    );
    expect(await db.select(db.words).get(), isEmpty);
    expect(await db.select(db.wordBookItems).get(), isEmpty);
  });

  test('保存层拒绝不合格输入，弯撇号统一后仍检测重复', () async {
    final id = await repository.createWordBook('英语');
    for (final pair in [
      ['中文', '意思'],
      ['word123', '意思'],
      ['focus', 'focus'],
      ['focus', '123'],
      ['focus', '专注\u200B'],
    ]) {
      await expectLater(
        repository.addWord(wordBookId: id, word: pair[0], meaning: pair[1]),
        throwsFormatException,
      );
    }
    expect(await db.select(db.words).get(), isEmpty);
    expect(await db.select(db.wordBookItems).get(), isEmpty);
    await repository.addWord(wordBookId: id, word: 'can’t', meaning: '不能');
    expect((await db.select(db.words).getSingle()).word, "can't");
    await expectLater(
      repository.addWord(wordBookId: id, word: "can't", meaning: '不能'),
      throwsFormatException,
    );
    expect(await db.select(db.wordBookItems).get(), hasLength(1));
  });

  Future<void> mount(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(find.byKey(const ValueKey('manual-word')), 'focus');
    await tester.enterText(find.byKey(const ValueKey('manual-meaning')), '专注');
  }

  testWidgets('手机宽度下添加入口可用，校验空输入并保存刷新词数', (tester) async {
    final id = await repository.createWordBook('测试词书');
    await mount(tester, const VocabularyHomePage());
    await tester.tap(find.text('添加单词'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(find.text('请输入单词'), findsOneWidget);
    expect(find.text('请输入意思'), findsOneWidget);
    await fill(tester);
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('共 1 词'), findsOneWidget);
    expect(await repository.loadStudyQueue(id), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('取消不写入，重复添加时弹窗保留输入并提示', (tester) async {
    final id = await repository.createWordBook('测试词书');
    await mount(tester, const VocabularyHomePage());
    await tester.tap(find.text('添加单词'));
    await tester.pumpAndSettle();
    await fill(tester);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(await db.select(db.words).get(), isEmpty);
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加单词'));
    await tester.pumpAndSettle();
    await fill(tester);
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(find.text('这本词书中已有该单词，无需重复添加'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(await db.select(db.wordBookItems).get(), hasLength(1));
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('不合格单词与翻译即时提示，修改后可保存且不丢失输入', (tester) async {
    await repository.createWordBook('英语');
    await mount(tester, const VocabularyHomePage());
    await tester.tap(find.text('添加单词'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('manual-word')),
      'word123',
    );
    await tester.enterText(find.byKey(const ValueKey('manual-meaning')), '123');
    await tester.pumpAndSettle();
    expect(find.text('请输入英文单词；仅支持字母及词内连字符、撇号'), findsOneWidget);
    expect(find.text('意思需包含中文释义，不能只填英文、数字或符号'), findsOneWidget);
    await tester.ensureVisible(find.text('添加'));
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(await db.select(db.words).get(), isEmpty);
    expect(find.text('word123'), findsOneWidget);
    await fill(tester);
    await tester.pumpAndSettle();
    expect(find.text('请输入英文单词；仅支持字母及词内连字符、撇号'), findsNothing);
    await tester.ensureVisible(find.text('添加'));
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect((await db.select(db.words).getSingle()).meaning, '专注');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('导入格式示例只有单词和意思两列', (tester) async {
    await repository.createWordBook('英语');
    await mount(tester, const WordImportPage());
    final table = tester.widget<DataTable>(find.byType(DataTable));
    expect(table.columns, hasLength(2));
    expect(find.text('只需要两列：单词、意思'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
