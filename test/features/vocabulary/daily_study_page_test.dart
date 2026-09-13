import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/presentation/study/study_page.dart';
import 'package:learning_bird/features/vocabulary/presentation/word_book_page.dart';

void main() {
  late AppDatabase db;
  late VocabularyRepository repo;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = VocabularyRepository(db);
  });
  tearDown(() async {
    await db.close();
  });

  Future<void> mount(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> answer(WidgetTester tester) async {
    await tester.tap(find.text('显示答案'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '认识'));
    await tester.pumpAndSettle();
  }

  testWidgets('单个词书的目标设置校验、取消、保存和重进持久化', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final a = await repo.createWordBook('考研');
    final b = await repo.createWordBook('四级');
    await mount(tester, WordBookPage(bookId: a));
    expect(find.text('每日目标 20 词'), findsOneWidget);
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('请输入 1–1000 的整数'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '30');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('每日目标 30 词'), findsOneWidget);
    expect((await repo.loadDailyProgress(b)).goal, 20);
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '50');
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect((await repo.loadDailyProgress(a)).goal, 30);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await mount(tester, WordBookPage(bookId: a));
    expect(find.text('每日目标 30 词'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('达标后重进仍提示目标完成，可持续加练直到无可学词', (tester) async {
    final id = await repo.createWordBook('考研');
    for (final word in ['focus', 'persist', 'learn']) {
      await repo.addWord(wordBookId: id, word: word, meaning: '中文意思');
    }
    await repo.saveDailyGoal(id, 1);
    await mount(tester, StudyPage(wordBookId: id, wordBookName: '考研'));
    for (var i = 0; i < 3; i++) {
      await answer(tester);
    }
    expect(find.text('本轮学习完成'), findsOneWidget);
    expect(find.text('继续学习'), findsOneWidget);
    expect((await repo.loadDailyProgress(id)).completed, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await mount(tester, StudyPage(wordBookId: id, wordBookName: '考研'));
    expect(find.text('今日目标已完成'), findsOneWidget);
    for (var round = 0; round < 2; round++) {
      await tester.tap(find.text('继续学习'));
      await tester.pumpAndSettle();
      expect(find.text('已通过 0 / 1'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await answer(tester);
      }
      expect(find.text('本轮学习完成'), findsOneWidget);
    }
    expect((await repo.loadDailyProgress(id)).completed, 3);
    expect(find.text('继续学习'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
