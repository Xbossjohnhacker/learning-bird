import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/vocabulary_providers.dart';
import '../../domain/vocabulary_test_mode.dart';

class VocabularyTestCenterPage extends ConsumerStatefulWidget {
  const VocabularyTestCenterPage({super.key});

  @override
  ConsumerState<VocabularyTestCenterPage> createState() =>
      _VocabularyTestCenterPageState();
}

class _VocabularyTestCenterPageState
    extends ConsumerState<VocabularyTestCenterPage> {
  int? _selectedBookId;

  IconData _icon(VocabularyTestMode mode) => switch (mode) {
    VocabularyTestMode.wordToMeaning => Icons.fact_check_outlined,
    VocabularyTestMode.meaningRecall => Icons.psychology_alt_outlined,
    VocabularyTestMode.spelling => Icons.keyboard_alt_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(wordBooksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('单词测试')),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (items) {
          final available = items.where((book) => book.totalCount > 0).toList();
          if (available.isEmpty) {
            return const Center(child: Text('请先添加一本有单词的词书'));
          }
          final selected = available.any((b) => b.id == _selectedBookId)
              ? _selectedBookId!
              : available.first.id;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                key: const ValueKey('test-book-selector'),
                initialValue: selected,
                decoration: const InputDecoration(
                  labelText: '测试词书',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                items: [
                  for (final book in available)
                    DropdownMenuItem(
                      value: book.id,
                      child: Text('${book.name}（${book.totalCount} 词）'),
                    ),
                ],
                onChanged: (value) => setState(() => _selectedBookId = value),
              ),
              const SizedBox(height: 18),
              Text('选择测试方式', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              for (final mode in VocabularyTestMode.values) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: ValueKey('test-mode-${mode.routeName}'),
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(child: Icon(_icon(mode))),
                    title: Text(mode.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(mode.description),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      Uri(
                        path: '/words/tests/${mode.routeName}',
                        queryParameters: {'bookId': '$selected'},
                      ).toString(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              const Text('每轮最多抽取 20 词。答错会自动进入错词本；答对不会提前改变原复习时间，也不占每日学习额度。'),
            ],
          );
        },
      ),
    );
  }
}
