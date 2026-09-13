import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/in_app_reminder_host.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LearningBirdApp extends ConsumerWidget {
  const LearningBirdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Learning Bird',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          InAppReminderHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
