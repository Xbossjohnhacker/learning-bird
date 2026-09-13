import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/vocabulary_providers.dart';
import '../data/vocabulary_repository.dart';
import 'add_word_dialog.dart';
import 'daily_goal_card.dart';

class WordBookPage extends ConsumerWidget {
  const WordBookPage({super.key, required this.bookId});
  final int bookId;

  Future<void> _addWord(BuildContext context, WordBookSummary book) async {
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddWordDialog(bookId: bookId, bookName: book.name),
    );
    if (context.mounted && added == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('单词已添加')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(wordBooksProvider);
    final words = ref.watch(bookWordsProvider(bookId));
    WordBookSummary? book;
    for (final item in books.asData?.value ?? <WordBookSummary>[]) {
      if (item.id == bookId) {
        book = item;
        break;
      }
    }
    final currentBook = book;
    return Scaffold(
      appBar: AppBar(
        title: Text(currentBook?.name ?? '词书详情'),
        actions: [
          IconButton(
            tooltip: '开始学习',
            icon: const Icon(Icons.school_outlined),
            onPressed: currentBook == null || currentBook.totalCount == 0
                ? null
                : () => context.push(
                    Uri(
                      path: '/words/book/$bookId/study',
                      queryParameters: {'name': currentBook.name},
                    ).toString(),
                  ),
          ),
        ],
      ),
      floatingActionButton: currentBook == null
          ? null
          : FloatingActionButton.extended(
              heroTag: 'word-book-add-fab-$bookId',
              onPressed: () => _addWord(context, currentBook),
              icon: const Icon(Icons.add),
              label: const Text('添加单词'),
            ),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(child: Text('词书加载失败，请返回重试')),
        data: (_) => currentBook == null
            ? const Center(child: Text('这本词书已不存在，请返回词书列表'))
            : words.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(bookWordsProvider(bookId)),
                    child: const Text('单词加载失败，点击重试'),
                  ),
                ),
                data: (items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DailyGoalCard(bookId: bookId),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '全部单词 · 共 ${items.length} 词',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  '词书里还没有单词\n点击“添加单词”，或返回列表导入文件。',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              key: ValueKey('book-words-$bookId'),
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final word = items[index];
                                return ListTile(
                                  key: ValueKey('book-word-${word.id}'),
                                  leading: Text('${index + 1}'),
                                  title: Text(word.word),
                                  subtitle: Text(word.meaning),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
