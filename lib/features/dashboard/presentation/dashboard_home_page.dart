import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(todaySummaryProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: colors.primary),
                        ),
                        Text(
                          '今日',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: '学习统计',
                    onPressed: () => context.push('/statistics'),
                    icon: const Icon(Icons.insights_outlined),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: '设置',
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              summary.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('今日数据加载失败：$error'),
                  ),
                ),
                data: (data) => _SummaryContent(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，注意休息';
    if (hour < 12) return '早上好，稳步开始';
    if (hour < 18) return '下午好，保持节奏';
    return '晚上好，完成今天';
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.data});

  final TodaySummary data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: colors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.planTotal == 0
                      ? '今天还没有安排'
                      : '已完成 ${data.planCompleted} / ${data.planTotal} 项计划',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.planTotal == 0
                      ? '创建一项清晰、能立即执行的学习计划。'
                      : data.planCompleted == data.planTotal
                      ? '今日计划全部完成，做得漂亮。'
                      : '专注完成眼前这一项，进度自然会向前。',
                  style: TextStyle(color: colors.onPrimary),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: data.planProgress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: colors.onPrimary,
                  backgroundColor: colors.onPrimary.withValues(alpha: 0.24),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: '${data.dueWords}',
                label: '待复习',
                icon: Icons.translate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value: '${data.pomodoroCount}',
                label: '今日番茄',
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value: '${data.focusMinutes}m',
                label: '专注时长',
                icon: Icons.bolt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('下一项', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Card(
          child: data.nextPlanTitle == null
              ? ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('暂无待执行计划'),
                  subtitle: const Text('为今天补充一个明确目标'),
                  trailing: const Icon(Icons.add),
                  onTap: () => context.push(
                    Uri(
                      path: '/plans/new',
                      queryParameters: {
                        'date': DateTime.now().toIso8601String(),
                      },
                    ).toString(),
                  ),
                )
              : ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(data.nextPlanTitle!),
                  subtitle: Text(_timeLabel(data.nextPlanAt)),
                  trailing: FilledButton.tonal(
                    onPressed: () => context.go('/focus'),
                    child: const Text('去专注'),
                  ),
                  onTap: () => context.go('/plans'),
                ),
        ),
        const SizedBox(height: 22),
        Text('快速开始', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.translate,
                label: '背单词',
                onTap: () => context.go('/words'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.add_task,
                label: '建计划',
                onTap: () => context.push(
                  Uri(
                    path: '/plans/new',
                    queryParameters: {'date': DateTime.now().toIso8601String()},
                  ).toString(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.timer_outlined,
                label: '开番茄',
                onTap: () => context.go('/focus'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Card(
          child: ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('学习统计'),
            subtitle: Text('今日复习 ${data.reviewedWords} 词 · 查看日周月趋势'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/statistics'),
          ),
        ),
      ],
    );
  }

  static String _timeLabel(DateTime? value) {
    if (value == null) return '等待开始';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} · 今日待执行';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
