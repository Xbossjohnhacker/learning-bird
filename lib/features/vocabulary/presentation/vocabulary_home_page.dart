import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/vocabulary_providers.dart';
import '../data/vocabulary_repository.dart';
import 'add_word_dialog.dart';

class VocabularyHomePage extends ConsumerWidget {
  const VocabularyHomePage({super.key});

  Future<void> _addWord(BuildContext context, WordBookSummary book) async {
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddWordDialog(bookId: book.id, bookName: book.name),
    );
    if (context.mounted && added == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('单词已添加')));
    }
  }

  Future<void> _createBook(BuildContext context, WidgetRef ref) async {
    var draftName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建词书'),
        content: TextField(
          maxLength: 80,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如：考研英语核心词汇'),
          onChanged: (value) => draftName = value,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (!context.mounted || name == null || name.isEmpty) return;
    try {
      await ref.read(vocabularyRepositoryProvider).createWordBook(name);
      if (context.mounted) ref.invalidate(wordBooksProvider);
    } on Object catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('词书创建失败，请检查名称或存储空间后重试')));
    }
  }

  Future<void> _deleteBook(
    BuildContext context,
    WidgetRef ref,
    WordBookSummary book,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除词书'),
        content: Text(
          '确定永久删除“${book.name}”吗？\n\n'
          '其中的 ${book.totalCount} 个单词关联、学习进度和导入记录将一并删除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;

    try {
      await ref.read(vocabularyRepositoryProvider).deleteWordBook(book.id);
      if (!context.mounted) return;
      ref.invalidate(wordBooksProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已删除词书“${book.name}”')));
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(wordBooksProvider);
    final mistakeCount = ref.watch(mistakeWordsProvider).asData?.value.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的单词'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/words/library'),
            icon: const Icon(Icons.library_books_outlined),
            label: const Text('预置词书'),
          ),
          IconButton(
            tooltip: '新建词书',
            onPressed: () => _createBook(context, ref),
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'vocabulary-import-fab',
        onPressed: () => context.push('/words/import'),
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('导入单词'),
      ),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        '还没有词书',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('可直接选择考研、四级、六级词书，也可以新建自己的词书。'),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => context.push('/words/library'),
                        icon: const Icon(Icons.library_books_outlined),
                        label: const Text('选择预置词书'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _createBook(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('新建词书'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: items.length + 2,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: InkWell(
                        key: const ValueKey('mistake-book-entry'),
                        onTap: () => context.push('/words/mistakes'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.replay_circle_filled_outlined,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '错词本',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      mistakeCount == null
                                          ? '正在整理需要强化的单词…'
                                          : mistakeCount == 0
                                          ? '暂无错词，选择“不认识”后会自动收录'
                                          : '$mistakeCount 个单词需要强化',
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == 1) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: const ValueKey('vocabulary-test-entry'),
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Icon(
                            Icons.quiz_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: const Text('单词测试'),
                        subtitle: const Text('看词选义、看义回忆、单词拼写'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/words/tests'),
                      ),
                    );
                  }
                  final book = items[index - 2];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push('/words/book/${book.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    book.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('点击查看全部单词'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Text('共 ${book.totalCount} 词'),
                                Text('新词 ${book.newCount}'),
                                Text('待复习 ${book.dueCount}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: '删除词书',
                                  onPressed: () =>
                                      _deleteBook(context, ref, book),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _addWord(context, book),
                                  icon: const Icon(Icons.add),
                                  label: const Text('添加单词'),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: book.totalCount == 0
                                      ? null
                                      : () => context.push(
                                          Uri(
                                            path:
                                                '/words/book/${book.id}/study',
                                            queryParameters: {
                                              'name': book.name,
                                            },
                                          ).toString(),
                                        ),
                                  icon: const Icon(Icons.school_outlined),
                                  label: const Text('开始学习'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
