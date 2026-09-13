import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/app/theme/app_theme.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_providers.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_repository.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';
import 'package:learning_bird/features/vocabulary/presentation/study/study_page.dart';

class _FailOnceRepository extends VocabularyRepository {
  _FailOnceRepository(super.database);
  bool failNext = true;

  @override
  Future<ReviewDecision> recordReview({
    required StudyWord word,
    required ReviewRating rating,
    DateTime? reviewedAt,
  }) {
    if (failNext) {
      failNext = false;
      return Future.error(StateError('test save failure'));
    }
    return super.recordReview(
      word: word,
      rating: rating,
      reviewedAt: reviewedAt,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> mount(
    WidgetTester tester,
    AppDatabase db,
    VocabularyRepository repository,
    int bookId, {
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
    bool reveal = true,
  }) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          vocabularyRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: StudyPage(wordBookId: bookId, wordBookName: '英语'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('朗读'), findsNothing);
    expect(find.byIcon(Icons.volume_up_outlined), findsNothing);
    if (reveal) {
      await tester.tap(find.text('显示答案'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('朗读'), findsNothing);
      expect(find.byIcon(Icons.volume_up_outlined), findsNothing);
    }
  }

  testWidgets('未翻面和翻面后均可跳过已认识，直接通过并计入每日目标', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = VocabularyRepository(db);
    final id = await repository.createWordBook('英语');
    for (final word in ['focus', 'persist']) {
      await repository.addWord(wordBookId: id, word: word, meaning: '中文意思');
    }
    await repository.saveDailyGoal(id, 2);
    await mount(tester, db, repository, id, reveal: false);
    expect(find.text('显示答案'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-known-word')));
    await tester.tap(find.byKey(const ValueKey('skip-known-word')));
    await tester.pumpAndSettle();
    expect(find.text('已通过 1 / 2'), findsOneWidget);
    expect((await repository.loadDailyProgress(id)).completed, 1);
    expect(await db.select(db.reviewRecords).get(), hasLength(1));
    await tester.tap(find.text('显示答案'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skip-known-word')));
    await tester.pumpAndSettle();
    expect(find.text('本轮学习完成'), findsOneWidget);
    expect((await repository.loadDailyProgress(id)).completed, 2);
    expect(
      (await db.select(db.reviewRecords).get()).every(
        (row) => row.rating == 'already_known',
      ),
      isTrue,
    );
    expect(await repository.loadStudyQueue(id), isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('跳过保存失败保留原词卡，重试后只记一次', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = _FailOnceRepository(db);
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    await mount(tester, db, repository, id, reveal: false);
    await tester.tap(find.byKey(const ValueKey('skip-known-word')));
    await tester.pumpAndSettle();
    expect(find.text('保存失败，请重试'), findsOneWidget);
    expect(find.text('focus'), findsOneWidget);
    expect(find.text('显示答案'), findsOneWidget);
    expect(await db.select(db.reviewRecords).get(), isEmpty);
    await tester.tap(find.byKey(const ValueKey('skip-known-word')));
    await tester.pumpAndSettle();
    expect(find.text('本轮学习完成'), findsOneWidget);
    expect(await db.select(db.reviewRecords).get(), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('${mode.name}主题按钮颜色统一，放大文字下等宽且无溢出', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = VocabularyRepository(db);
      final id = await repository.createWordBook('英语');
      await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
      await mount(tester, db, repository, id, themeMode: mode, textScale: 1.3);
      final knownFinder = find.widgetWithText(FilledButton, '认识');
      final unknownFinder = find.widgetWithText(OutlinedButton, '不认识');
      final known = tester.widget<FilledButton>(knownFinder);
      final unknown = tester.widget<OutlinedButton>(unknownFinder);
      final colors = Theme.of(tester.element(knownFinder)).colorScheme;
      expect(
        colors.brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
      expect(known.style!.backgroundColor!.resolve({}), colors.primary);
      expect(known.style!.foregroundColor!.resolve({}), colors.onPrimary);
      expect(
        unknown.style!.foregroundColor!.resolve({}),
        colors.onSurfaceVariant,
      );
      expect(unknown.style!.side!.resolve({})!.color, colors.outline);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(
        tester.getSize(knownFinder).width,
        tester.getSize(unknownFinder).width,
      );
      expect(tester.getSize(knownFinder).height, greaterThanOrEqualTo(56));
      expect(tester.getSize(unknownFinder).height, greaterThanOrEqualTo(56));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  for (final known in [true, false]) {
    testWidgets('${known ? '认识' : '不认识'}正确保存，两按钮且重复点击不重复记录', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = VocabularyRepository(db);
      final bookId = await repository.createWordBook('英语');
      await repository.addWord(
        wordBookId: bookId,
        word: 'focus',
        meaning: '专注',
      );
      await repository.addWord(
        wordBookId: bookId,
        word: 'persist',
        meaning: '坚持',
      );
      await mount(tester, db, repository, bookId);
      expect(find.text('认识'), findsOneWidget);
      expect(find.text('不认识'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '认识'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '不认识'), findsOneWidget);
      for (final old in ['忘记', '模糊', '记得', '掌握', '熟练']) {
        expect(find.text(old), findsNothing);
      }
      final label = known ? '认识' : '不认识';
      await tester.tap(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final record = await db.select(db.reviewRecords).getSingle();
      final schedule = await db.select(db.reviewSchedules).getSingle();
      expect(record.rating, known ? 'remembered' : 'forgot');
      expect(schedule.intervalDays, 0);
      expect(schedule.streak, 0);
      expect(schedule.lapseCount, known ? 0 : 1);
      expect(schedule.dueAt.difference(record.reviewedAt), Duration.zero);
      expect(find.text('已通过 0 / 2'), findsOneWidget);
      expect(find.text('显示答案'), findsOneWidget);
      await tester.tap(find.text('显示答案'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(await db.select(db.reviewRecords).get(), hasLength(2));
      expect(find.text('本轮学习完成'), findsNothing);
      expect(find.text(known ? '连续认识 1/3' : '连续认识 0/3'), findsNothing);
      for (var i = 0; i < (known ? 4 : 6); i++) {
        await tester.tap(find.text('显示答案'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('认识'));
        await tester.pumpAndSettle();
      }
      expect(find.text('本轮学习完成'), findsOneWidget);
      expect(find.text('已通过 2 个单词，复习记录已保存。'), findsOneWidget);
      expect(await db.select(db.reviewRecords).get(), hasLength(known ? 6 : 8));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('退出保留两次认识进度，第三次通过后后续只需一次', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = VocabularyRepository(db);
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    await mount(tester, db, repository, id);
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(find.text('连续认识 1/3'), findsNothing);
    await tester.tap(find.text('显示答案'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(find.text('连续认识 2/3'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await mount(tester, db, repository, id);
    expect(find.text('连续认识 2/3'), findsNothing);
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(find.text('本轮学习完成'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db
        .update(db.reviewSchedules)
        .write(
          ReviewSchedulesCompanion(
            dueAt: Value(DateTime.now().subtract(const Duration(days: 1))),
          ),
        );
    await mount(tester, db, repository, id);
    expect(find.text('复习确认：认识 1 次即可通过'), findsNothing);
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(find.text('本轮学习完成'), findsOneWidget);
    expect(await db.select(db.reviewRecords).get(), hasLength(4));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('后续复习不认识变为三次，两次后再不认识又清零', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = VocabularyRepository(db);
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    final word = (await repository.loadStudyQueue(id)).single;
    for (var i = 0; i < 3; i++) {
      await repository.recordReview(
        word: word,
        rating: ReviewRating.remembered,
      );
    }
    await db
        .update(db.reviewSchedules)
        .write(
          ReviewSchedulesCompanion(
            dueAt: Value(DateTime.now().subtract(const Duration(days: 1))),
          ),
        );
    await mount(tester, db, repository, id);
    expect(find.text('复习确认：认识 1 次即可通过'), findsNothing);
    await tester.tap(find.text('不认识'));
    await tester.pumpAndSettle();
    expect(find.text('连续认识 0/3'), findsNothing);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('显示答案'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('认识'));
      await tester.pumpAndSettle();
    }
    expect(find.text('连续认识 2/3'), findsNothing);
    await tester.tap(find.text('显示答案'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('不认识'));
    await tester.pumpAndSettle();
    expect(find.text('连续认识 0/3'), findsNothing);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('显示答案'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('认识'));
      await tester.pumpAndSettle();
    }
    expect(find.text('本轮学习完成'), findsOneWidget);
    expect((await db.select(db.reviewSchedules).getSingle()).lapseCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('保存失败保留词卡，允许再次点击认识', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = _FailOnceRepository(db);
    final id = await repository.createWordBook('英语');
    await repository.addWord(wordBookId: id, word: 'focus', meaning: '专注');
    await mount(tester, db, repository, id);
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(find.text('保存失败，请重试'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(await db.select(db.reviewRecords).get(), isEmpty);
    await tester.tap(find.text('认识'));
    await tester.pumpAndSettle();
    expect(await db.select(db.reviewRecords).get(), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
