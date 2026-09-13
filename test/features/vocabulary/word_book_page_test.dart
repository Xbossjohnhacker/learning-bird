import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';
import 'package:learning_bird/features/vocabulary/presentation/word_book_page.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repository;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VocabularyRepository(db);
  });
  tearDown(() => db.close());

  Future<int> seedBook() async {
    final id = await repository.createWordBook('全部词汇');
    await repository.importRows(
      wordBookId: id,
      fileName: 'test.csv',
      sourceType: 'csv',
      sourceFingerprint: 'test',
      duplicateStrategy: DuplicateStrategy.skip,
      rows: List.generate(
        25,
        (index) => WordImportRow(
          word: 'word${index.toString().padLeft(3, '0')}',
          meaning: '释义 $index',
        ),
      ),
    );
    return id;
  }

  test('查看全书不限制20词，包含已学未到期、掌握和暂停的单词且不串书', () async {
    final id = await seedBook();
    final other = await repository.createWordBook('另一本');
    await repository.addWord(wordBookId: other, word: 'other', meaning: '其他');
    final queue = await repository.loadStudyQueue(id);
    expect(queue, hasLength(20));
    await repository.recordReview(
      word: queue.first,
      rating: ReviewRating.remembered,
    );
    await (db.update(
      db.wordBookItems,
    )..where((item) => item.id.equals(queue[1].itemId))).write(
      WordBookItemsCompanion(
        learningState: const Value('mastered'),
        suspendedAt: Value(DateTime.now()),
      ),
    );
    final all = await repository.watchBookWords(id).first;
    expect(all, hasLength(25));
    expect(all.first.word, 'word000');
    expect(all.last.word, 'word024');
    expect(all.map((word) => word.word), isNot(contains('other')));
    expect(await repository.watchBookWords(other).first, hasLength(1));
    await repository.deleteWordBook(id);
    expect(await repository.watchBookWords(id).first, isEmpty);
  });

  Future<void> mount(WidgetTester tester, int id) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: WordBookPage(bookId: id)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('空词书可查看，手动添加后列表和总数实时更新', (tester) async {
    final id = await repository.createWordBook('英语');
    await mount(tester, id);
    expect(find.text('全部单词 · 共 0 词'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.school_outlined),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('添加单词'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('manual-word')), 'focus');
    await tester.enterText(find.byKey(const ValueKey('manual-meaning')), '专注');
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    expect(find.text('全部单词 · 共 1 词'), findsOneWidget);
    expect(find.text('focus'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.school_outlined),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('全部单词可滚动到第25词，删除词书后不显示过期内容', (tester) async {
    final id = await seedBook();
    await mount(tester, id);
    expect(find.text('全部单词 · 共 25 词'), findsOneWidget);
    expect(find.text('word000'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('word024'), 300);
    expect(find.text('释义 24'), findsOneWidget);
    await repository.deleteWordBook(id);
    await tester.pumpAndSettle();
    expect(find.text('这本词书已不存在，请返回词书列表'), findsOneWidget);
    expect(find.text('添加单词'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
