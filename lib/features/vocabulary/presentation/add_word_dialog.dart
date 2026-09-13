import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vocabulary_providers.dart';
import '../domain/manual_word_validator.dart';

class AddWordDialog extends ConsumerStatefulWidget {
  const AddWordDialog({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  final int bookId;
  final String bookName;

  @override
  ConsumerState<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends ConsumerState<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  String _word = '';
  String _meaning = '';
  String? _error;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(vocabularyRepositoryProvider)
          .addWord(wordBookId: widget.bookId, word: _word, meaning: _meaning);
      if (!mounted) return;
      ref.invalidate(wordBooksProvider);
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error is FormatException ? error.message : '添加失败，请稍后重试';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text('添加单词'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('添加到：${widget.bookName}'),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('manual-word'),
                  autofocus: true,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: '单词',
                    hintText: '例如：focus',
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => _word = value,
                  validator: ManualWordValidator.wordError,
                  errorBuilder: (context, error) => Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('manual-meaning'),
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: '意思',
                    hintText: '例如：专注',
                  ),
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (value) => _meaning = value,
                  validator: ManualWordValidator.meaningError,
                  errorBuilder: (context, error) => Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '仅检查格式和重复项，拼写及译义准确性请自行核对。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '添加中…' : '添加'),
          ),
        ],
      ),
    );
  }
}
