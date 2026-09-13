import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vocabulary_providers.dart';
import '../../data/vocabulary_repository.dart';
import '../../domain/review_scheduler.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({
    required this.wordBookId,
    required this.wordBookName,
    super.key,
  }) : mistakeMode = false;

  const StudyPage.mistakes({super.key})
    : wordBookId = null,
      wordBookName = '错词强化',
      mistakeMode = true;

  final int? wordBookId;
  final String wordBookName;
  final bool mistakeMode;

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  List<StudyWord>? _pending;
  int _roundTotal = 0;
  int _completed = 0;
  bool _revealed = false;
  bool _saving = false;
  bool _finished = false;
  bool _extra = false;

  void _continueLearning() {
    final bookId = widget.wordBookId;
    if (bookId == null) return;
    ref.invalidate(extraStudyQueueProvider(bookId));
    ref.invalidate(dailyStudyProgressProvider(bookId));
    setState(() {
      _extra = true;
      _pending = null;
      _roundTotal = 0;
      _completed = 0;
      _revealed = false;
      _finished = false;
    });
  }

  Future<void> _rate(StudyWord word, ReviewRating rating) async {
    if (_saving || (!_revealed && rating != ReviewRating.alreadyKnown)) return;
    setState(() => _saving = true);
    try {
      final decision = await ref
          .read(vocabularyRepositoryProvider)
          .recordReview(word: word, rating: rating);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _revealed = false;
        _pending!.removeAt(0);
        if (decision.needsConfirmation) {
          _pending!.add(word.afterReview(decision, rating));
        } else {
          _completed++;
        }
        _finished = _pending!.isEmpty;
      });
      ref.invalidate(mistakeWordsProvider);
      ref.invalidate(mistakeStudyQueueProvider);
      if (_finished) {
        final bookId = widget.wordBookId;
        if (bookId != null) {
          ref.invalidate(studyQueueProvider(bookId));
          ref.invalidate(extraStudyQueueProvider(bookId));
          ref.invalidate(dailyStudyProgressProvider(bookId));
        }
        ref.invalidate(wordBooksProvider);
      }
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存失败，请重试'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16, 16, 16, 140),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = widget.wordBookId;
    final queue = widget.mistakeMode
        ? ref.watch(mistakeStudyQueueProvider)
        : _extra
        ? ref.watch(extraStudyQueueProvider(bookId!))
        : ref.watch(studyQueueProvider(bookId!));
    final daily = bookId == null
        ? null
        : ref.watch(dailyStudyProgressProvider(bookId)).asData?.value;
    return Scaffold(
      appBar: AppBar(title: Text(widget.wordBookName)),
      body: queue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (words) {
          if (_finished) {
            return _EmptyStudy(
              icon: Icons.emoji_events_outlined,
              title: '本轮学习完成',
              subtitle: widget.mistakeMode
                  ? '已完成 $_roundTotal 个错词的强化，学习记录已保存。'
                  : '已通过 $_roundTotal 个单词，复习记录已保存。',
              action: widget.mistakeMode
                  ? null
                  : daily == null
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          '今日已通过 ${daily.completed} / ${daily.goal} 词${daily.goalReached ? '，已达标' : ''}',
                        ),
                        if (daily.hasMore) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _continueLearning,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('继续学习'),
                          ),
                        ],
                      ],
                    ),
            );
          }
          if (_pending == null && words.isEmpty) {
            return _EmptyStudy(
              icon: Icons.check_circle_outline,
              title: widget.mistakeMode
                  ? '错词已清空'
                  : daily?.goalReached == true
                  ? '今日目标已完成'
                  : '暂无可学习的单词',
              subtitle: widget.mistakeMode
                  ? '当前没有需要强化的错词，继续保持。'
                  : daily == null
                  ? '正在读取今日进度…'
                  : '今日已通过 ${daily.completed} / ${daily.goal} 词。\n${daily.hasMore ? '可以继续学习剩余单词。' : '新的复习任务会按记忆反馈自动安排。'}',
              action: !widget.mistakeMode && daily?.hasMore == true
                  ? FilledButton.icon(
                      onPressed: _continueLearning,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('继续学习'),
                    )
                  : null,
            );
          }
          if (_pending == null) {
            _pending = List.of(words);
            _roundTotal = words.length;
          }
          final word = _pending!.first;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('已通过 $_completed / $_roundTotal'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _completed / _roundTotal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _revealed = true),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      word.word,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displaySmall,
                                    ),
                                  ),
                                ],
                              ),
                              if (word.phonetic?.isNotEmpty ?? false)
                                Text(
                                  word.phonetic!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              const SizedBox(height: 28),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _revealed
                                    ? Column(
                                        key: const ValueKey('answer'),
                                        children: [
                                          Text(
                                            word.meaning,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall,
                                          ),
                                          if (word.example?.isNotEmpty ??
                                              false) ...[
                                            const SizedBox(height: 20),
                                            Text(
                                              word.example!,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                          if (word
                                                  .exampleTranslation
                                                  ?.isNotEmpty ??
                                              false)
                                            Text(
                                              word.exampleTranslation!,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                        ],
                                      )
                                    : const Column(
                                        key: ValueKey('prompt'),
                                        children: [
                                          Icon(Icons.touch_app_outlined),
                                          SizedBox(height: 8),
                                          Text('点击卡片查看释义'),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_revealed)
                    FilledButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _revealed = true),
                      child: const Text('显示答案'),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _RatingButton(
                            label: '不认识',
                            isKnown: false,
                            onPressed: _saving
                                ? null
                                : () => _rate(word, ReviewRating.forgot),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RatingButton(
                            label: '认识',
                            isKnown: true,
                            onPressed: _saving
                                ? null
                                : () => _rate(word, ReviewRating.remembered),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Tooltip(
                    message: widget.mistakeMode
                        ? '确认已经认识，直接完成该词的强化'
                        : '直接通过这个词，计入今日完成并安排后续复习',
                    child: TextButton.icon(
                      key: const ValueKey('skip-known-word'),
                      onPressed: _saving
                          ? null
                          : () => _rate(word, ReviewRating.alreadyKnown),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('跳过（已认识）'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.isKnown,
    required this.onPressed,
  });

  final String label;
  final bool isKnown;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    if (isKnown) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          shape: shape,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded, size: 20),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            shape: shape,
          ).copyWith(
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? colors.onSurface.withValues(alpha: 0.12)
                    : colors.outline,
              ),
            ),
          ),
      onPressed: onPressed,
      icon: const Icon(Icons.help_outline_rounded, size: 20),
      label: Text(label),
    );
  }
}

class _EmptyStudy extends StatelessWidget {
  const _EmptyStudy({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
