import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/vocabulary_providers.dart';

class MistakeWordsPage extends ConsumerWidget {
  const MistakeWordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mistakes = ref.watch(mistakeWordsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('错词本')),
      body: mistakes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(mistakeWordsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyMistakes()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${item.studyWord.lapseCount}'),
                      ),
                      title: Text(item.studyWord.word),
                      subtitle: Text(
                        '${item.studyWord.meaning}\n来自：${item.wordBookName}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: mistakes.asData?.value.isNotEmpty == true
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                key: const ValueKey('start-mistake-study'),
                onPressed: () => context.push('/words/mistakes/study'),
                icon: const Icon(Icons.replay_rounded),
                label: Text('开始强化（${mistakes.requireValue.length} 词）'),
              ),
            )
          : null,
    );
  }
}

class _EmptyMistakes extends StatelessWidget {
  const _EmptyMistakes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('当前没有错词', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('学习时选择“不认识”的单词会自动收录在这里。'),
          ],
        ),
      ),
    );
  }
}
