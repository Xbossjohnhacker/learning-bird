import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation.dart';
import '../../features/plans/data/plans_providers.dart';
import '../../features/plans/domain/plan_models.dart';
import '../../features/pomodoro/data/pomodoro_providers.dart';
import '../../features/pomodoro/domain/pomodoro_models.dart';
import 'plan_notification_service.dart';

final inAppReminderIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 15);
});

/// Coordinates every foreground reminder through one serial dialog queue.
class InAppReminderHost extends ConsumerStatefulWidget {
  const InAppReminderHost({
    required this.child,
    this.enablePlans = true,
    this.enablePomodoro = true,
    super.key,
  });

  final Widget child;
  final bool enablePlans;
  final bool enablePomodoro;

  @override
  ConsumerState<InAppReminderHost> createState() => _InAppReminderHostState();
}

class InAppPlanReminderHost extends StatelessWidget {
  const InAppPlanReminderHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InAppReminderHost(enablePomodoro: false, child: child);
  }
}

class InAppPomodoroReminderHost extends StatelessWidget {
  const InAppPomodoroReminderHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InAppReminderHost(enablePlans: false, child: child);
  }
}

class _InAppReminderHostState extends ConsumerState<InAppReminderHost>
    with WidgetsBindingObserver {
  final Queue<_DialogReminder> _queue = Queue<_DialogReminder>();
  ProviderSubscription<PomodoroFinishedEvent?>? _pomodoroSubscription;
  Timer? _planTimer;
  bool _checkingPlans = false;
  bool _showing = false;

  bool get _isForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enablePomodoro) {
      _pomodoroSubscription = ref.listenManual<PomodoroFinishedEvent?>(
        pomodoroFinishedEventProvider,
        (_, event) {
          if (event != null) _enqueue(_PomodoroDialogReminder(event));
        },
      );
    }
    if (widget.enablePlans) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkPlans());
      _planTimer = Timer.periodic(
        ref.read(inAppReminderIntervalProvider),
        (_) => _checkPlans(),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (widget.enablePlans) unawaited(_checkPlans());
    unawaited(_showNext());
  }

  Future<void> _checkPlans() async {
    if (_checkingPlans || !mounted || !_isForeground) return;
    _checkingPlans = true;
    try {
      final reminders = await ref
          .read(plansRepositoryProvider)
          .claimDuePopupReminders();
      if (!mounted || !_isForeground) return;
      for (final reminder in reminders) {
        try {
          await ref
              .read(planNotificationServiceProvider)
              .cancel(reminder.notificationId);
        } on Object {
          // The foreground reminder remains useful if cancellation fails.
        }
        _enqueue(_PlanDialogReminder(reminder));
      }
    } on Object {
      // A scheduled system notification remains the fallback.
    } finally {
      _checkingPlans = false;
    }
  }

  void _enqueue(_DialogReminder reminder) {
    if (!mounted) return;
    _queue.add(reminder);
    unawaited(_showNext());
  }

  Future<void> _showNext() async {
    if (_showing || !mounted || !_isForeground || _queue.isEmpty) return;
    final navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNext());
      return;
    }

    _showing = true;
    final reminder = _queue.removeFirst();
    final confirmed = await showDialog<bool>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: reminder.buildDialog,
    );
    if (mounted && confirmed == true) await reminder.onConfirm(ref);
    _showing = false;
    if (_queue.isNotEmpty) unawaited(_showNext());
  }

  @override
  void dispose() {
    _planTimer?.cancel();
    _pomodoroSubscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

sealed class _DialogReminder {
  const _DialogReminder();

  Widget buildDialog(BuildContext context);

  Future<void> onConfirm(WidgetRef ref);
}

class _PlanDialogReminder extends _DialogReminder {
  const _PlanDialogReminder(this.reminder);

  final DuePlanReminder reminder;

  @override
  Widget buildDialog(BuildContext context) =>
      _PlanReminderDialog(reminder: reminder);

  @override
  Future<void> onConfirm(WidgetRef ref) async {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) context.go('/plans');
  }
}

class _PomodoroDialogReminder extends _DialogReminder {
  const _PomodoroDialogReminder(this.event);

  final PomodoroFinishedEvent event;

  @override
  Widget buildDialog(BuildContext context) =>
      _PomodoroFinishedDialog(event: event);

  @override
  Future<void> onConfirm(WidgetRef ref) =>
      ref.read(pomodoroControllerProvider.notifier).start();
}

class _PlanReminderDialog extends StatelessWidget {
  const _PlanReminderDialog({required this.reminder});

  final DuePlanReminder reminder;

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        reminder.isCourse ? Icons.school_outlined : Icons.event_note_outlined,
      ),
      title: Text(reminder.isCourse ? '课程提醒' : '计划提醒'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reminder.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('开始时间：${_time(reminder.startsAt)}'),
          if (reminder.location != null) ...[
            const SizedBox(height: 4),
            Text('地点：${reminder.location}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('知道了'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('查看计划'),
        ),
      ],
    );
  }
}

class _PomodoroFinishedDialog extends StatelessWidget {
  const _PomodoroFinishedDialog({required this.event});

  final PomodoroFinishedEvent event;

  @override
  Widget build(BuildContext context) {
    final focusFinished = event.finishedPhase == PomodoroPhase.focus;
    final nextLabel = event.nextPhase.label;
    return AlertDialog(
      icon: Icon(
        focusFinished
            ? Icons.self_improvement_outlined
            : Icons.play_circle_outline,
      ),
      title: Text(focusFinished ? '专注时间结束' : '休息时间结束'),
      content: Text(
        focusFinished ? '本轮专注已完成。接下来建议进行$nextLabel。' : '休息完成，可以开始下一轮专注了。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(focusFinished ? '稍后休息' : '稍后开始'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(focusFinished ? '开始$nextLabel' : '开始专注'),
        ),
      ],
    );
  }
}
