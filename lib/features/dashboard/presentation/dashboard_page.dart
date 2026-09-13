import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(databaseHealthProvider);
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNING BIRD',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      '今日',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => context.push('/settings'),
                tooltip: '设置',
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            color: colors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '继续前进',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '第二阶段基础框架已运行',
                    style: TextStyle(color: colors.onPrimary),
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: 0.42,
                    color: colors.onPrimary,
                    backgroundColor: colors.onPrimary.withValues(alpha: 0.25),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(value: '42', label: '待复习'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(value: '3', label: '今日番茄'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(value: '75m', label: '专注时长'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('基础设施状态', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('本地数据库'),
              subtitle: const Text('Drift + SQLite · Schema v1'),
              trailing: health.when(
                data: (ready) => Icon(
                  ready ? Icons.check_circle : Icons.error,
                  color: ready ? colors.primary : colors.error,
                ),
                loading: () => const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => Icon(Icons.error, color: colors.error),
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.route_outlined),
              title: Text('应用导航'),
              subtitle: Text('GoRouter · 四个一级入口'),
              trailing: Icon(Icons.check_circle),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.account_tree_outlined),
              title: Text('状态管理'),
              subtitle: Text('Riverpod · 依赖注入就绪'),
              trailing: Icon(Icons.check_circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
