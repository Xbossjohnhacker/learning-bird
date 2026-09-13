import 'package:flutter/material.dart';

class ModulePage extends StatelessWidget {
  const ModulePage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.items,
    required this.primaryAction,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<ModuleItem> items;
  final String primaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            eyebrow,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                  ],
                ),
              ),
              Icon(icon, size: 42, color: colors.primary),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: Text(primaryAction),
          ),
          const SizedBox(height: 20),
          for (final item in items)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(item.icon, color: colors.onPrimaryContainer),
                ),
                title: Text(item.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(item.subtitle),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
        ],
      ),
    );
  }
}

class ModuleItem {
  const ModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
