import 'package:flutter/material.dart';

import '../../../core/widgets/module_page.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      eyebrow: 'PLANS',
      title: '计划',
      description: '计划表、分类和提醒表已经建立，第五至六周接入完整生命周期。',
      icon: Icons.event_note_outlined,
      primaryAction: '创建计划',
      items: [
        ModuleItem(
          title: '考研词汇复习',
          subtitle: '20:00 · 预计 2 个番茄',
          icon: Icons.schedule,
        ),
        ModuleItem(
          title: '数学真题训练',
          subtitle: '明天 09:00 · 提前 10 分钟提醒',
          icon: Icons.functions,
        ),
      ],
    );
  }
}
