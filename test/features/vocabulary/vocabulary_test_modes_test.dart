import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/vocabulary_test_mode.dart';
import 'package:learning_bird/features/vocabulary/presentation/tests/vocabulary_test_center_page.dart';
import 'package:learning_bird/features/vocabulary/presentation/tests/vocabulary_test_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  test('测试队列可抽取未到期单词且不受每日目标限制', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('测试词书');
    for (final word in ['focus', 'persist', 'derive']) {
      await repository.addWord(wordBookId: bookId, word: word, meaning: '中文释义');
    }
    await repository.saveDailyGoal(bookId, 1);
    expect(await repository.loadTestQueue(bookId), hasLength(3));
    expect(
      () => repository.loadTestQueue(bookId, limit: 101),
      throwsA(isA<FormatException>()),
    );
  });

  testWidgets('测试中心展示三种计划书模式和词书选择', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('考研英语');
    await repository.addWord(wordBookId: bookId, word: 'focus', meaning: '专注');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: VocabularyTestCenterPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('考研英语'), findsOneWidget);
    expect(find.text('看词选义'), findsOneWidget);
    expect(find.text('看义回忆单词'), findsOneWidget);
    expect(find.text('单词拼写'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('看词选义答错自动进入错词本', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('四级词书');
    await repository.addWord(wordBookId: bookId, word: 'focus', meaning: '专注');
    await repository.addWord(
      wordBookId: bookId,
      word: 'persist',
      meaning: '坚持',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: VocabularyTestPage(
            wordBookId: bookId,
            mode: VocabularyTestMode.wordToMeaning,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final focusIsPrompt = find.text('focus').evaluate().isNotEmpty;
    await tester.tap(find.text(focusIsPrompt ? '坚持' : '专注'));
    await tester.pumpAndSettle();
    expect(find.text('已加入错词本'), findsOneWidget);
    expect(await repository.watchMistakeWords().first, hasLength(1));
    expect((await repository.loadDailyProgress(bookId)).completed, 0);
    await unmount(tester);
  });

  testWidgets('看义回忆答对不提前改变复习记录', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('六级词书');
    await repository.addWord(
      wordBookId: bookId,
      word: 'derive',
      meaning: '获得；源自',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: VocabularyTestPage(
            wordBookId: bookId,
            mode: VocabularyTestMode.meaningRecall,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reveal-recall-answer')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('想起来了'));
    await tester.pumpAndSettle();
    expect(find.text('回答正确'), findsOneWidget);
    expect(await database.select(database.reviewRecords).get(), isEmpty);
    expect(await repository.watchMistakeWords().first, isEmpty);
    await unmount(tester);
  });

  testWidgets('拼写空输入提示，大小写不同仍判定正确', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('拼写词书');
    await repository.addWord(wordBookId: bookId, word: 'Focus', meaning: '专注');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: VocabularyTestPage(
            wordBookId: bookId,
            mode: VocabularyTestMode.spelling,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('submit-spelling')));
    await tester.pumpAndSettle();
    expect(find.text('请先输入英文单词'), findsOneWidget);
    expect(await database.select(database.reviewRecords).get(), isEmpty);
    await tester.enterText(
      find.byKey(const ValueKey('spelling-input')),
      'focus',
    );
    await tester.tap(find.byKey(const ValueKey('submit-spelling')));
    await tester.pumpAndSettle();
    expect(find.text('回答正确'), findsOneWidget);
    expect(await database.select(database.reviewRecords).get(), isEmpty);
    await unmount(tester);
  });
}
