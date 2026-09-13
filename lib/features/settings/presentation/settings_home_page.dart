import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/release_info.dart';
import '../../../core/backup/backup_providers.dart';
import '../../../core/backup/backup_repository.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/plan_notification_service.dart';
import '../../dashboard/data/dashboard_providers.dart';
import '../../plans/data/plans_providers.dart';
import 'background_reminder_settings_page.dart';
import 'privacy_policy_page.dart';

class SettingsHomePage extends ConsumerStatefulWidget {
  const SettingsHomePage({super.key});

  @override
  ConsumerState<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends ConsumerState<SettingsHomePage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    final permission = ref.watch(notificationPermissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SectionTitle(title: '外观'),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (value) => _setMode(value),
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text('跟随系统'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text('浅色'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text('深色'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: '权限与提醒'),
          Card(
            child: Column(
              children: [
                permission.when(
                  data: (enabled) => ListTile(
                    leading: Icon(
                      enabled
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                    ),
                    title: const Text('系统通知'),
                    subtitle: Text(
                      enabled ? '已允许，计划和番茄提醒可正常显示' : '未允许，提醒将无法显示',
                    ),
                    trailing: enabled
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : FilledButton.tonal(
                            onPressed: _busy
                                ? null
                                : _requestNotificationPermission,
                            child: const Text('允许'),
                          ),
                  ),
                  loading: () => const ListTile(
                    leading: Icon(Icons.notifications_outlined),
                    title: Text('系统通知'),
                    subtitle: Text('正在检查权限…'),
                  ),
                  error: (error, _) => ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('系统通知'),
                    subtitle: const Text('无法读取权限状态'),
                    trailing: IconButton(
                      onPressed: () =>
                          ref.invalidate(notificationPermissionProvider),
                      icon: const Icon(Icons.refresh),
                      tooltip: '重试',
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.alarm_on_outlined),
                  title: const Text('后台提醒设置检查'),
                  subtitle: const Text('检查精确闹钟、电池优化和厂商后台限制'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackgroundReminderSettingsPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: '数据安全'),
          Card(
            child: Column(
              children: [
                ListTile(
                  enabled: !_busy,
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('备份全部数据'),
                  subtitle: const Text('导出词书、计划、复习记录、番茄记录和设置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _exportBackup,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  enabled: !_busy,
                  leading: Icon(
                    Icons.restore_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: const Text('从备份恢复'),
                  subtitle: const Text('验证备份后替换当前全部数据'),
                  trailing: _busy
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _importBackup,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('隐私政策'),
                  subtitle: const Text('查看本地数据、权限和关联应用说明'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '备份仅保存在你选择的位置，不会上传到网络。备份文件未加密，请妥善保管。恢复操作不可撤销，建议先导出当前数据。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于 Learning Bird'),
              subtitle: const Text(ReleaseInfo.label),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Learning Bird',
                applicationVersion: ReleaseInfo.label,
                applicationIcon: const Icon(Icons.menu_book_rounded, size: 40),
                children: const [
                  Text(ReleaseInfo.status),
                  SizedBox(height: 12),
                  Text('学习数据保存在本机；应用不主动上传数据。请在卸载或更换签名前导出备份。'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setMode(ThemeMode? value) {
    if (value != null) {
      ref.read(themeModeProvider.notifier).state = value;
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() => _busy = true);
    try {
      final allowed = await ref
          .read(planNotificationServiceProvider)
          .requestPermission();
      ref.invalidate(notificationPermissionProvider);
      if (!mounted) return;
      _showMessage(allowed ? '通知权限已允许' : '通知权限未开启，可在系统设置中手动允许');
    } on Object catch (_) {
      if (mounted) _showMessage('通知权限申请失败，请稍后重试', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final source = await ref.read(backupRepositoryProvider).createBackup();
      final now = DateTime.now();
      final fileName = 'learning-bird-backup-${_compactDate(now)}.json';
      final uri = await FilePicker.saveFile(
        dialogTitle: '保存 Learning Bird 备份',
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(source)),
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (!mounted || uri == null) return;
      _showMessage('数据备份成功');
    } on Object catch (_) {
      if (mounted) _showMessage('备份失败，请确认存储空间后重试', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: '选择 Learning Bird 备份',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null || !mounted) return;
    if (await file.length() > 50 * 1024 * 1024) {
      _showMessage('备份文件超过 50 MB，已停止读取', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await file.readAsBytes();
      final source = utf8.decode(bytes);
      final repository = ref.read(backupRepositoryProvider);
      final summary = repository.inspectBackup(source);
      if (!mounted) return;
      final confirmed = await _confirmRestore(summary);
      if (!confirmed || !mounted) return;

      await repository.restoreBackup(source);
      var remindersRestored = true;
      try {
        await ref.read(planNotificationServiceProvider).cancelAll();
        await _restorePlanReminders();
      } on Object catch (_) {
        remindersRestored = false;
      }
      ref.invalidate(databaseHealthProvider);
      ref.invalidate(todaySummaryProvider);
      ref.invalidate(statisticsProvider);
      if (!mounted) return;
      _showMessage(
        remindersRestored
            ? '已恢复 ${summary.totalRecords} 条数据'
            : '数据已恢复，但系统提醒重建失败，请检查通知权限',
        error: !remindersRestored,
      );
    } on BackupValidationException catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } on FormatException {
      if (mounted) _showMessage('备份文本编码无效', error: true);
    } on Object catch (_) {
      if (mounted) _showMessage('恢复失败，当前数据未被替换', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmRestore(BackupSummary summary) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.warning_amber_rounded),
            title: const Text('确认替换全部数据？'),
            content: Text(
              '备份时间：${_displayDate(summary.exportedAt)}\n'
              '数据记录：${summary.totalRecords} 条\n\n'
              '当前词书、计划、复习记录、番茄记录和设置都会被替换。此操作不可撤销。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认恢复'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _restorePlanReminders() async {
    final notifications = ref.read(planNotificationServiceProvider);
    final pending = await ref
        .read(plansRepositoryProvider)
        .loadPendingReminders();
    for (final reminder in pending) {
      final id = reminder.notificationId;
      final at = reminder.reminderAt;
      if (id != null && at != null) {
        await notifications.schedule(
          id: id,
          title: reminder.title,
          triggerAt: at,
        );
      }
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _compactDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}${two(value.month)}${two(value.day)}-'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}';
  }

  String _displayDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
