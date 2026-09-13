import 'package:flutter/material.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('POMODORO', style: TextStyle(color: colors.primary)),
          Text('番茄钟', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primaryContainer, width: 14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '25:00',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const Text('考研词汇复习'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始专注'),
          ),
          const SizedBox(height: 12),
          Text(
            '计时数据表与恢复字段已经就绪，第七周接入后台时间校准。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
