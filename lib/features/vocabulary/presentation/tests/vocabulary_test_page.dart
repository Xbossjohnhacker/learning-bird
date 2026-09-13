import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vocabulary_providers.dart';
import '../../data/vocabulary_repository.dart';
import '../../domain/review_scheduler.dart';
import '../../domain/vocabulary_test_mode.dart';

class VocabularyTestPage extends ConsumerStatefulWidget {
  const VocabularyTestPage({
    required this.wordBookId,
    required this.mode,
    super.key,
  });

  final int wordBookId;
  final VocabularyTestMode mode;

  @override
  ConsumerState<VocabularyTestPage> createState() => _VocabularyTestPageState();
}

class _VocabularyTestPageState extends ConsumerState<VocabularyTestPage> {
  late Future<List<StudyWord>> _load;
  List<StudyWord> _words = const [];
  int _index = 0;
  int _correct = 0;
  bool _answered = false;
  bool _saving = false;
  bool? _wasCorrect;
  String? _selected;
  final _spellingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load = ref
        .read(vocabularyRepositoryProvider)
        .loadTestQueue(widget.wordBookId);
  }

  @override
  void dispose() {
    _spellingController.dispose();
    super.dispose();
  }

  List<String> _options(StudyWord word, {required bool meanings}) {
    final values = <String>{
      meanings ? word.meaning : word.word,
      for (final item in _words) meanings ? item.meaning : item.word,
    }.toList();
    values.shuffle(Random(word.itemId));
    final answer = meanings ? word.meaning : word.word;
    final result = values.take(4).toList();
    if (!result.contains(answer)) result[result.length - 1] = answer;
    result.shuffle(Random(word.itemId + 31));
    return result;
  }

  Future<void> _answer(StudyWord word, bool correct, {String? selected}) async {
    if (_answered || _saving) return;
    setState(() {
      _saving = !correct;
      _selected = selected;
    });
    try {
      if (!correct) {
        await ref
            .read(vocabularyRepositoryProvider)
            .recordReview(word: word, rating: ReviewRating.forgot);
        ref.invalidate(mistakeWordsProvider);
        ref.invalidate(mistakeStudyQueueProvider);
        ref.invalidate(wordBooksProvider);
      }
      if (!mounted) return;
      setState(() {
        _saving = false;
        _answered = true;
        _wasCorrect = correct;
        if (correct) _correct++;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _selected = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('结果保存失败，请重试')));
    }
  }

  void _next() {
    setState(() {
      _index++;
      _answered = false;
      _wasCorrect = null;
      _selected = null;
      _spellingController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mode.title)),
      body: FutureBuilder<List<StudyWord>>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败：${snapshot.error}'));
          }
          _words = snapshot.data ?? const [];
          if (_words.isEmpty) return const Center(child: Text('这本词书暂无可测试单词'));
          if (_index >= _words.length) {
            return _TestResult(correct: _correct, total: _words.length);
          }
          final word = _words[_index];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('${_index + 1} / ${_words.length}'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_index + 1) / _words.length,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _question(word)),
                  if (_saving) const LinearProgressIndicator(),
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    Text(
                      _wasCorrect == true ? '回答正确' : '已加入错词本',
                      key: const ValueKey('test-feedback'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _wasCorrect == true
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const ValueKey('next-test-word'),
                      onPressed: _next,
                      child: Text(_index + 1 == _words.length ? '查看结果' : '下一题'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _question(StudyWord word) => switch (widget.mode) {
    VocabularyTestMode.wordToMeaning => _ChoiceQuestion(
      prompt: word.word,
      options: _options(word, meanings: true),
      answer: word.meaning,
      selected: _selected,
      answered: _answered,
      onSelected: (value) =>
          _answer(word, value == word.meaning, selected: value),
    ),
    VocabularyTestMode.meaningRecall => _RecallQuestion(
      word: word,
      answered: _answered,
      onAnswer: (correct) => _answer(word, correct),
    ),
    VocabularyTestMode.spelling => _SpellingQuestion(
      word: word,
      controller: _spellingController,
      answered: _answered,
      onSubmit: () {
        final input = _spellingController.text.trim();
        if (input.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('请先输入英文单词')));
          return;
        }
        _answer(
          word,
          input.toLowerCase() == word.word.trim().toLowerCase(),
          selected: input,
        );
      },
    ),
  };
}

class _ChoiceQuestion extends StatelessWidget {
  const _ChoiceQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.selected,
    required this.answered,
    required this.onSelected,
  });
  final String prompt;
  final List<String> options;
  final String answer;
  final String? selected;
  final bool answered;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      Text(
        prompt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 24),
      for (final option in options)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: answered || selected != null
                ? null
                : () => onSelected(option),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              alignment: Alignment.centerLeft,
            ),
            child: Text(option),
          ),
        ),
      if (answered && selected != answer)
        Text('正确答案：$answer', textAlign: TextAlign.center),
    ],
  );
}

class _RecallQuestion extends StatefulWidget {
  const _RecallQuestion({
    required this.word,
    required this.answered,
    required this.onAnswer,
  });
  final StudyWord word;
  final bool answered;
  final ValueChanged<bool> onAnswer;

  @override
  State<_RecallQuestion> createState() => _RecallQuestionState();
}

class _RecallQuestionState extends State<_RecallQuestion> {
  bool revealed = false;

  @override
  void didUpdateWidget(covariant _RecallQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.itemId != widget.word.itemId) revealed = false;
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        widget.word.meaning,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 28),
      if (!revealed)
        FilledButton(
          key: const ValueKey('reveal-recall-answer'),
          onPressed: () => setState(() => revealed = true),
          child: const Text('显示单词'),
        )
      else ...[
        Text(
          widget.word.word,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        if (!widget.answered)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => widget.onAnswer(false),
                  child: const Text('没想起'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onAnswer(true),
                  child: const Text('想起来了'),
                ),
              ),
            ],
          ),
      ],
    ],
  );
}

class _SpellingQuestion extends StatelessWidget {
  const _SpellingQuestion({
    required this.word,
    required this.controller,
    required this.answered,
    required this.onSubmit,
  });
  final StudyWord word;
  final TextEditingController controller;
  final bool answered;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        word.meaning,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 28),
      TextField(
        key: const ValueKey('spelling-input'),
        controller: controller,
        enabled: !answered,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(
          labelText: '输入英文单词',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => onSubmit(),
      ),
      const SizedBox(height: 16),
      if (!answered)
        FilledButton(
          key: const ValueKey('submit-spelling'),
          onPressed: onSubmit,
          child: const Text('提交答案'),
        )
      else
        Text('正确拼写：${word.word}'),
    ],
  );
}

class _TestResult extends StatelessWidget {
  const _TestResult({required this.correct, required this.total});
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_outlined, size: 72),
          const SizedBox(height: 16),
          Text('测试完成', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('答对 $correct / $total 题'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回测试中心'),
          ),
        ],
      ),
    ),
  );
}
