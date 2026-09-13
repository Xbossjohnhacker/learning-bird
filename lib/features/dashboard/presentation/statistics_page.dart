import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(statisticsPeriodProvider);
    final statistics = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('学习统计')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(statisticsProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SegmentedButton<StatisticsPeriod>(
              segments: StatisticsPeriod.values
                  .map(
                    (period) =>
                        ButtonSegment(value: period, label: Text(period.label)),
                  )
                  .toList(),
              selected: {selectedPeriod},
              onSelectionChanged: (selection) {
                ref.read(statisticsPeriodProvider.notifier).state =
                    selection.first;
              },
            ),
            const SizedBox(height: 20),
            statistics.when(
              data: (value) => _StatisticsContent(summary: value),
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) =>
                  _ErrorView(onRetry: () => ref.invalidate(statisticsProvider)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.timer_outlined,
                label: '专注时长',
                value: _formatMinutes(summary.totalFocusMinutes),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.task_alt,
                label: '完成计划',
                value: '${summary.completedPlans}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                icon: Icons.spellcheck,
                label: '复习单词',
                value: '${summary.reviewedWords}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ChartCard(
          title: '专注趋势',
          subtitle: '每个周期的有效专注分钟数',
          child: _FocusChart(points: summary.points),
        ),
        const SizedBox(height: 16),
        _ChartCard(
          title: '学习成果',
          subtitle: '计划完成数与复习单词数',
          child: _ActivityChart(points: summary.points),
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes 分';
    }
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours 小时' : '$hours小时$rest分';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _FocusChart extends StatelessWidget {
  const _FocusChart({required this.points});

  final List<StatisticsPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final peak = points.fold<int>(
      0,
      (value, point) => math.max(value, point.focusMinutes),
    );
    final maxY = math.max(30, (peak * 1.25).ceil()).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${points[group.x].label}\n${rod.toY.round()} 分钟',
                TextStyle(color: colors.onPrimary, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: _titles(points),
        barGroups: [
          for (var index = 0; index < points.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: points[index].focusMinutes.toDouble(),
                  width: 18,
                  color: colors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.points});

  final List<StatisticsPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final peak = points.fold<int>(
      0,
      (value, point) =>
          math.max(value, math.max(point.completedPlans, point.reviewedWords)),
    );
    final maxY = math.max(5, (peak * 1.25).ceil()).toDouble();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: _titles(points),
              barGroups: [
                for (var index = 0; index < points.length; index++)
                  BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: points[index].completedPlans.toDouble(),
                        width: 8,
                        color: colors.tertiary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: points[index].reviewedWords.toDouble(),
                        width: 8,
                        color: colors.secondary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: colors.tertiary, label: '完成计划'),
            const SizedBox(width: 18),
            _LegendDot(color: colors.secondary, label: '复习单词'),
          ],
        ),
      ],
    );
  }
}

FlTitlesData _titles(List<StatisticsPoint> points) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 36),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= points.length || value != index) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            meta: meta,
            child: Text(
              points[index].label,
              style: const TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          const Icon(Icons.query_stats, size: 48),
          const SizedBox(height: 12),
          const Text('统计数据加载失败'),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
