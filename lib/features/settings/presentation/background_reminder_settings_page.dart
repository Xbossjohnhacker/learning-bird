import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/background_reminder_settings.dart';
import '../../../core/notifications/plan_notification_service.dart';

class BackgroundReminderSettingsPage extends ConsumerStatefulWidget {
  const BackgroundReminderSettingsPage({super.key});

  @override
  ConsumerState<BackgroundReminderSettingsPage> createState() =>
      _BackgroundReminderSettingsPageState();
}

class _BackgroundReminderSettingsPageState
    extends ConsumerState<BackgroundReminderSettingsPage>
    with WidgetsBindingObserver {
  bool _busy = false;

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
    if (state == AppLifecycleState.resumed) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationPermissionProvider);
    final status = ref.watch(backgroundReminderStatusProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('后台提醒设置检查'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: '重新检查',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '让计划和番茄钟在桌面、其他软件和锁屏时按时提醒',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('下面三项都需要正常。修改系统设置后返回本页，状态会自动更新。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                notification.when(
                  data: (enabled) => _StatusTile(
                    icon: Icons.notifications_active_outlined,
                    title: '通知与顶部横幅',
                    subtitle: enabled ? '通知权限已允许' : '未允许，后台提醒无法显示',
                    ok: enabled,
                    actionLabel: enabled ? '通知设置' : '去开启',
                    onPressed: enabled
                        ? _openNotificationSettings
                        : _requestNotificationPermission,
                  ),
                  loading: () => const _LoadingTile(title: '通知与顶部横幅'),
                  error: (_, _) =>
                      _ErrorTile(title: '通知与顶部横幅', onRetry: _refresh),
                ),
                const Divider(height: 1, indent: 56),
                status.when(
                  data: (value) => _StatusTile(
                    icon: Icons.notification_important_outlined,
                    title: '闹钟式强提醒',
                    subtitle: !value.supported
                        ? '当前系统无需单独设置'
                        : value.canUseFullScreenIntents
                        ? '已允许，可在普通横幅被隐藏时显示强提醒'
                        : '未允许，ColorOS 可能只把提醒放入通知栏',
                    ok: !value.supported || value.canUseFullScreenIntents,
                    actionLabel: value.canUseFullScreenIntents ? null : '去开启',
                    onPressed: value.canUseFullScreenIntents
                        ? null
                        : _requestFullScreenIntentPermission,
                  ),
                  loading: () => const _LoadingTile(title: '闹钟式强提醒'),
                  error: (_, _) =>
                      _ErrorTile(title: '闹钟式强提醒', onRetry: _refresh),
                ),
                const Divider(height: 1, indent: 56),
                status.when(
                  data: (value) => _StatusTile(
                    icon: Icons.alarm_on_outlined,
                    title: '精确闹钟',
                    subtitle: !value.supported
                        ? '当前系统无需 Android 精确闹钟设置'
                        : value.canScheduleExactly
                        ? '已允许，计划和番茄钟可按准确时间触发'
                        : '未允许，系统可能延迟提醒',
                    ok: !value.supported || value.canScheduleExactly,
                    actionLabel: value.canScheduleExactly ? null : '去开启',
                    onPressed: value.canScheduleExactly
                        ? null
                        : _openExactAlarmSettings,
                  ),
                  loading: () => const _LoadingTile(title: '精确闹钟'),
                  error: (_, _) => _ErrorTile(title: '精确闹钟', onRetry: _refresh),
                ),
                const Divider(height: 1, indent: 56),
                status.when(
                  data: (value) => _StatusTile(
                    icon: Icons.battery_saver_outlined,
                    title: '后台运行与省电限制',
                    subtitle: _batteryMessage(value),
                    ok: false,
                    info: value.supported,
                    actionLabel: value.supported ? '打开应用设置' : null,
                    onPressed: value.supported ? _openAppDetails : null,
                  ),
                  loading: () => const _LoadingTile(title: '后台运行与省电限制'),
                  error: (_, _) =>
                      _ErrorTile(title: '后台运行与省电限制', onRetry: _refresh),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          status.maybeWhen(
            data: (value) => value.supported
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            value.needsColorOsConfirmation
                                ? '当前是 ColorOS 系统。打开系统设置后搜索“自启动”，进入自启动管理并开启 Learning Bird；再搜索“应用耗电管理”，将它设为“完全允许后台行为”。'
                                : '请允许 Learning Bird 自启动或后台启动，并在耗电管理中选择“允许后台活动”或“不限制”。不同品牌名称可能略有不同。',
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: _openBackgroundLaunchSettings,
                            icon: const Icon(Icons.rocket_launch_outlined),
                            label: Text(
                              value.needsColorOsConfirmation
                                  ? '打开系统设置并搜索'
                                  : '打开后台启动设置',
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _openNotificationSettings,
                            icon: const Icon(Icons.web_asset_outlined),
                            label: const Text('检查横幅与锁屏通知'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '这些厂商开关不是 Android 运行时权限，应用无法代替你开启。设置一次后即可长期生效。',
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _testBackgroundReminder,
            icon: const Icon(Icons.notification_add_outlined),
            label: const Text('10 秒后测试后台提醒'),
          ),
          const SizedBox(height: 10),
          const Text(
            '点击后立即返回桌面。若正常，应在约 10 秒后看到顶部横幅，并听到声音或感到振动。',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('重新检查'),
          ),
        ],
      ),
    );
  }

  String _batteryMessage(BackgroundReminderStatus value) {
    if (!value.supported) return '请在系统中允许后台通知';
    return value.ignoringBatteryOptimizations
        ? '系统电池优化已关闭；还需确认厂商后台设置'
        : '请关闭电池优化，并确认厂商后台设置';
  }

  void _refresh() {
    ref.invalidate(notificationPermissionProvider);
    ref.invalidate(backgroundReminderStatusProvider);
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _busy = true);
    try {
      await ref.read(planNotificationServiceProvider).requestPermission();
    } finally {
      if (mounted) setState(() => _busy = false);
      _refresh();
    }
  }

  Future<void> _requestFullScreenIntentPermission() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(planNotificationServiceProvider)
          .requestFullScreenIntentPermission();
    } finally {
      if (mounted) setState(() => _busy = false);
      _refresh();
    }
  }

  Future<void> _openNotificationSettings() =>
      ref.read(backgroundReminderSettingsProvider).openNotificationSettings();

  Future<void> _openExactAlarmSettings() =>
      ref.read(backgroundReminderSettingsProvider).openExactAlarmSettings();

  Future<void> _openAppDetails() =>
      ref.read(backgroundReminderSettingsProvider).openAppDetails();

  Future<void> _openBackgroundLaunchSettings() => ref
      .read(backgroundReminderSettingsProvider)
      .openBackgroundLaunchSettings();

  Future<void> _testBackgroundReminder() async {
    setState(() => _busy = true);
    try {
      final notifications = ref.read(planNotificationServiceProvider);
      final granted = await notifications.requestPermission();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请先允许通知权限')));
        return;
      }
      await notifications.cancel(
        PlanNotificationService.backgroundTestNotificationId,
      );
      await notifications.schedule(
        id: PlanNotificationService.backgroundTestNotificationId,
        title: '后台计划提醒测试成功',
        triggerAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('测试提醒已安排，请立即返回桌面等待约 10 秒')));
    } finally {
      if (mounted) setState(() => _busy = false);
      _refresh();
    }
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
    this.info = false,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;
  final bool info;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: actionLabel == null
          ? Icon(
              ok ? Icons.check_circle : Icons.info_outline,
              color: ok ? Colors.green : colorScheme.error,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ok
                      ? Icons.check_circle
                      : info
                      ? Icons.info_outline
                      : Icons.warning_amber_rounded,
                  color: ok
                      ? Colors.green
                      : info
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
                const SizedBox(width: 6),
                TextButton(onPressed: onPressed, child: Text(actionLabel!)),
              ],
            ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    title: Text(title),
    subtitle: const Text('正在检查…'),
  );
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.title, required this.onRetry});

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.error_outline),
    title: Text(title),
    subtitle: const Text('无法读取状态'),
    trailing: IconButton(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      tooltip: '重试',
    ),
  );
}
