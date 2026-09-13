import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/vocabulary_providers.dart';
import '../domain/builtin_word_book.dart';

class BuiltinWordBooksPage extends ConsumerStatefulWidget {
  const BuiltinWordBooksPage({super.key});
  @override
  ConsumerState<BuiltinWordBooksPage> createState() =>
      _BuiltinWordBooksPageState();
}

class _BuiltinWordBooksPageState extends ConsumerState<BuiltinWordBooksPage> {
  String? _installing;
  String? _error;

  Future<void> _install(BuiltinWordBook book) async {
    if (_installing != null) return;
    setState(() {
      _installing = book.id;
      _error = null;
    });
    try {
      final catalog = ref.read(builtinWordCatalogProvider);
      final repository = ref.read(vocabularyRepositoryProvider);
      final rows = await catalog.loadWords(book);
      if (!mounted) return;
      final id = await repository.installBuiltinWordBook(book, rows);
      if (!mounted) return;
      ref.invalidate(wordBooksProvider);
      setState(() => _installing = null);
      context.pushReplacement('/words/book/$id');
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _installing = null;
          _error = '添加失败，未创建不完整词书，请重试。';
        });
      }
    }
  }

  Future<void> _showSource() async {
    try {
      final license = await ref.read(builtinWordCatalogProvider).loadLicense();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('词库来源与许可'),
          content: SingleChildScrollView(
            child: SelectableText(
              'ECDICT 开源参考词库\nhttps://github.com/skywind3000/ECDICT\n\n'
              '按 ky、cet4、cet6 分类标签整理；六级包含四级基础词。'
              '不代表最新版官方完整考试大纲，释义可能存在遗漏或错误。\n\n$license',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } on Object catch (_) {
      if (mounted) setState(() => _error = '许可信息读取失败，请重试。');
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(builtinWordBooksProvider);
    return PopScope(
      canPop: _installing == null,
      child: Scaffold(
        appBar: AppBar(title: const Text('预置词书')),
        body: books.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(builtinWordBooksProvider),
              child: const Text('词库加载失败，点击重试'),
            ),
          ),
          data: (items) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '选择一本，离线开始学习',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('词库随应用提供，无需下载文件。已添加过的词书会直接打开，不会重复创建或重置进度。'),
              const SizedBox(height: 16),
              for (final book in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('${book.count} 词 · ${book.description}'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: ValueKey('install-${book.id}'),
                          onPressed: _installing == null
                              ? () => _install(book)
                              : null,
                          icon: _installing == book.id
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.library_add_outlined),
                          label: Text(
                            _installing == book.id ? '正在准备词书…' : '添加 / 打开词书',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Text('来源：ECDICT（MIT），开源参考词库，非官方完整大纲。同一单词若已有自定义意思，会保留你的内容。'),
              TextButton(onPressed: _showSource, child: const Text('词库来源与许可')),
            ],
          ),
        ),
      ),
    );
  }
}
