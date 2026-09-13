import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pomodoro_providers.dart';
import '../domain/pomodoro_models.dart';

class PomodoroHomePage extends ConsumerStatefulWidget {
  const PomodoroHomePage({super.key});

  @override
  ConsumerState<PomodoroHomePage> createState() => _PomodoroHomePageState();
}

class _PomodoroHomePageState extends ConsumerState<PomodoroHomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(pomodoroControllerProvider.notifier).reconcile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(pomodoroControllerProvider);
    final controller = ref.read(pomodoroControllerProvider.notifier);
    final plans = ref.watch(availableFocusPlansProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('番茄钟'),
        actions: [
          IconButton(
            tooltip: '计时设置',
            onPressed: timer.isIdle
                ? () => _showSettings(context, timer.settings, controller)
                : null,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            SegmentedButton<PomodoroPhase>(
              segments: [
                for (final phase in PomodoroPhase.values)
                  ButtonSegment(value: phase, label: Text(phase.label)),
              ],
              selected: {timer.phase},
              onSelectionChanged: timer.isIdle
                  ? (value) => controller.selectPhase(value.first)
                  : null,
            ),
            const SizedBox(height: 28),
            Center(
              child: SizedBox.square(
                dimension: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: timer.progress,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colors.primaryContainer,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDuration(timer.remaining),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timer.isPaused
                              ? '已暂停'
                              : timer.isRunning
                              ? timer.phase.label
                              : '准备开始',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (timer.planTitle != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              timer.planTitle!,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (timer.isIdle)
              plans.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('计划加载失败：$error'),
                data: (items) {
                  final selectedExists =
                      timer.planId == null ||
                      items.any((item) => item.id == timer.planId);
                  if (!selectedExists) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      final current = ref.read(pomodoroControllerProvider);
                      if (current.isIdle && current.planId == timer.planId) {
                        controller.selectPlan(null);
                      }
                    });
                  }
                  return DropdownButtonFormField<int?>(
                    key: ValueKey((timer.planId, selectedExists)),
                    initialValue: selectedExists ? timer.planId : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: '关联课程或计划（可选）',
                      helperText: '课程来自计划页当前使用的课表',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_note_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('自由专注')),
                      for (final plan in items)
                        DropdownMenuItem(
                          value: plan.id,
                          child: Text(
                            '${plan.isCourse ? '课程' : '计划'} · ${plan.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      FocusPlanOption? selected;
                      for (final plan in items) {
                        if (plan.id == id) selected = plan;
                      }
                      controller.selectPlan(selected);
                    },
                  );
                },
              ),
            const SizedBox(height: 20),
            _Controls(timer: timer, controller: controller),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日完成 ${timer.completedFocusCount} 个番茄',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            timer.completedFocusCount == 0
                                ? '从第一轮专注开始积累'
                                : '每 4 轮专注后建议进行一次长休息',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '计时以系统时间戳校准，切到后台后仍会按正确时间结束。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSettings(
    BuildContext context,
    PomodoroSettings current,
    PomodoroController controller,
  ) async {
    var focus = current.focusMinutes;
    var shortBreak = current.shortBreakMinutes;
    var longBreak = current.longBreakMinutes;
    var every = current.longBreakEvery;
    final result = await showDialog<PomodoroSettings>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('计时设置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingDropdown(
                  label: '专注时长',
                  value: focus,
                  values: const [15, 20, 25, 30, 45, 60],
                  suffix: '分钟',
                  onChanged: (value) => setDialogState(() => focus = value),
                ),
                const SizedBox(height: 12),
                _SettingDropdown(
                  label: '短休息',
                  value: shortBreak,
                  values: const [3, 5, 10, 15],
                  suffix: '分钟',
                  onChanged: (value) =>
                      setDialogState(() => shortBreak = value),
                ),
                const SizedBox(height: 12),
                _SettingDropdown(
                  label: '长休息',
                  value: longBreak,
                  values: const [10, 15, 20, 30],
                  suffix: '分钟',
                  onChanged: (value) => setDialogState(() => longBreak = value),
                ),
                const SizedBox(height: 12),
                _SettingDropdown(
                  label: '长休息间隔',
                  value: every,
                  values: const [2, 3, 4, 5, 6],
                  suffix: '个番茄',
                  onChanged: (value) => setDialogState(() => every = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                PomodoroSettings(
                  focusMinutes: focus,
                  shortBreakMinutes: shortBreak,
                  longBreakMinutes: longBreak,
                  longBreakEvery: every,
                ),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (result != null) await controller.updateSettings(result);
  }

  static String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 359999);
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.timer, required this.controller});

  final PomodoroState timer;
  final PomodoroController controller;

  @override
  Widget build(BuildContext context) {
    if (timer.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (timer.isIdle) {
      return FilledButton.icon(
        onPressed: controller.start,
        icon: const Icon(Icons.play_arrow),
        label: Text('开始${timer.phase.label}'),
      );
    }
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: timer.isRunning ? controller.pause : controller.resume,
            icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(timer.isRunning ? '暂停' : '继续'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmStop(context),
            icon: const Icon(Icons.stop_outlined),
            label: const Text('结束'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提前结束？'),
        content: const Text('本次计时会保存为已取消，不计入完成番茄。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('继续计时'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('结束'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.stop();
  }
}

class _SettingDropdown extends StatelessWidget {
  const _SettingDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in values)
          DropdownMenuItem(value: option, child: Text('$option $suffix')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
