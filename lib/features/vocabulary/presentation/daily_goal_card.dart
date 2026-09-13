import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vocabulary_providers.dart';

class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key, required this.bookId});
  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyStudyProgressProvider(bookId));
    return progress.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => TextButton(
        onPressed: () => ref.invalidate(dailyStudyProgressProvider(bookId)),
        child: const Text('每日目标加载失败，点击重试'),
      ),
      data: (value) => ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text('每日目标 ${value.goal} 词'),
        subtitle: Text('本词书今日已通过 ${value.completed} 词 · 达标后可继续'),
        trailing: TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                _DailyGoalDialog(bookId: bookId, initial: value.goal),
          ),
          child: const Text('设置'),
        ),
      ),
    );
  }
}

class _DailyGoalDialog extends ConsumerStatefulWidget {
  const _DailyGoalDialog({required this.bookId, required this.initial});
  final int bookId;
  final int initial;
  @override
  ConsumerState<_DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends ConsumerState<_DailyGoalDialog> {
  late String _draft = '${widget.initial}';
  String? _error;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final goal = int.tryParse(_draft.trim());
    if (goal == null || goal < 1 || goal > 1000) {
      setState(() => _error = '请输入 1–1000 的整数');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(vocabularyRepositoryProvider)
          .saveDailyGoal(widget.bookId, goal);
      if (!mounted) return;
      ref.invalidate(dailyStudyProgressProvider(widget.bookId));
      ref.invalidate(studyQueueProvider(widget.bookId));
      ref.invalidate(extraStudyQueueProvider(widget.bookId));
      Navigator.pop(context);
    } on Object catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '保存失败，请重试';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('设置本词书每日目标'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('仅对这本词书生效。新词与到期复习合计，完成一个词计一次，不按认识按钮的点击次数计数。'),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _draft,
              autofocus: true,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '每天学习词数',
                suffixText: '词',
                errorText: _error,
              ),
              onChanged: (value) => _draft = value,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '保存中…' : '保存'),
        ),
      ],
    ),
  );
}
