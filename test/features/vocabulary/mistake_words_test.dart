import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/presentation/mistake_words_page.dart';
import 'package:learning_bird/features/vocabulary/presentation/study/study_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('不认识自动进入错词本，连续三次认识后自动移出', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('考研英语');
    await repository.addWord(
      wordBookId: bookId,
      word: 'persist',
      meaning: '坚持',
    );

    final word = (await repository.loadStudyQueue(bookId)).single;
    await repository.recordReview(word: word, rating: ReviewRating.forgot);

    var mistakes = await repository.watchMistakeWords().first;
    expect(mistakes, hasLength(1));
    expect(mistakes.single.studyWord.word, 'persist');
    expect(mistakes.single.wordBookName, '考研英语');
    expect(await repository.loadMistakeStudyQueue(), hasLength(1));

    for (var count = 1; count <= 3; count++) {
      await repository.recordReview(
        word: word,
        rating: ReviewRating.remembered,
      );
      mistakes = await repository.watchMistakeWords().first;
      expect(mistakes, hasLength(count < 3 ? 1 : 0));
    }
  });

  testWidgets('错词本显示来源并可进入强化词卡', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VocabularyRepository(database);
    final bookId = await repository.createWordBook('六级词书');
    await repository.addWord(
      wordBookId: bookId,
      word: 'derive',
      meaning: '获得；源自',
    );
    final word = (await repository.loadStudyQueue(bookId)).single;
    await repository.recordReview(word: word, rating: ReviewRating.forgot);

    final router = GoRouter(
      initialLocation: '/words/mistakes',
      routes: [
        GoRoute(
          path: '/words/mistakes',
          builder: (_, _) => const MistakeWordsPage(),
          routes: [
            GoRoute(
              path: 'study',
              builder: (_, _) => const StudyPage.mistakes(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('derive'), findsOneWidget);
    expect(find.textContaining('来自：六级词书'), findsOneWidget);
    expect(find.text('开始强化（1 词）'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('start-mistake-study')));
    await tester.pumpAndSettle();
    expect(find.text('错词强化'), findsOneWidget);
    expect(find.text('derive'), findsOneWidget);
    expect(find.text('显示答案'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
