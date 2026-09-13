import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/app.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/database/database_provider.dart';
import 'package:learning_bird/features/vocabulary/data/builtin_word_catalog.dart';
import 'package:learning_bird/features/vocabulary/data/vocabulary_providers.dart';
import 'package:learning_bird/features/vocabulary/domain/builtin_word_book.dart';
import 'package:learning_bird/features/vocabulary/domain/word_import.dart';

class TestCatalog extends BuiltinWordCatalog {
  Completer<List<WordImportRow>>? pending;
  bool fail = false;
  @override
  Future<List<BuiltinWordBook>> loadCatalog() async => [
    for (final entry in {
      'kaoyan': '考研英语',
      'cet4': '大学英语四级',
      'cet6': '大学英语六级',
    }.entries)
      BuiltinWordBook(
        id: entry.key,
        name: entry.value,
        description: '参考词库',
        count: 1,
        sha256: '',
      ),
  ];
  @override
  Future<List<WordImportRow>> loadWords(BuiltinWordBook book) async {
    if (fail) throw const FormatException('test');
    return pending == null
        ? const [WordImportRow(word: 'focus', meaning: '专注')]
        : pending!.future;
  }

  @override
  Future<String> loadLicense() async => 'MIT License';
}

void main() {
  Future<void> openPage(
    WidgetTester tester,
    AppDatabase database,
    TestCatalog catalog,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          builtinWordCatalogProvider.overrideWithValue(catalog),
        ],
        child: const LearningBirdApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('单词'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择预置词书'));
    await tester.pumpAndSettle();
  }

  testWidgets('手机界面显示三本词书，添加中阻止重复点击，完成后查看词表', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final catalog = TestCatalog()..pending = Completer<List<WordImportRow>>();
    await openPage(tester, database, catalog);
    expect(find.text('考研英语'), findsOneWidget);
    expect(find.text('大学英语四级'), findsOneWidget);
    expect(find.text('大学英语六级'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('install-kaoyan')));
    await tester.pump();
    expect(find.text('正在准备词书…'), findsOneWidget);
    for (final button in tester.widgetList<FilledButton>(
      find.byType(FilledButton),
    )) {
      expect(button.onPressed, isNull);
    }
    catalog.pending!.complete(const [
      WordImportRow(word: 'focus', meaning: '专注'),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('全部单词 · 共 1 词'), findsOneWidget);
    expect(find.text('focus'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(await database.select(database.wordBooks).get(), hasLength(1));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('我的单词'), findsOneWidget);
    await tester.tap(find.text('预置词书'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('install-kaoyan')));
    await tester.pumpAndSettle();
    expect(find.text('全部单词 · 共 1 词'), findsOneWidget);
    expect(await database.select(database.wordBooks).get(), hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('添加失败可重试，来源许可可以查看', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final catalog = TestCatalog()..fail = true;
    await openPage(tester, database, catalog);
    await tester.tap(find.byKey(const ValueKey('install-kaoyan')));
    await tester.pumpAndSettle();
    expect(await database.select(database.wordBooks).get(), isEmpty);
    await tester.scrollUntilVisible(find.text('词库来源与许可'), 250);
    await tester.pumpAndSettle();
    expect(find.text('添加失败，未创建不完整词书，请重试。'), findsOneWidget);
    await tester.tap(find.text('词库来源与许可'));
    await tester.pumpAndSettle();
    expect(find.textContaining('MIT License'), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    catalog.fail = false;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('install-kaoyan')),
      -250,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('install-kaoyan')));
    await tester.pumpAndSettle();
    expect(find.text('全部单词 · 共 1 词'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
