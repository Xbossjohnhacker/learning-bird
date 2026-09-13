import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/pomodoro/domain/pomodoro_models.dart';
import 'local_notification_service.dart';

final pomodoroNotificationServiceProvider =
    Provider<PomodoroNotificationService>((ref) {
      return PomodoroNotificationService(
        notifications: ref.watch(localNotificationServiceProvider),
      );
    });

class PomodoroNotificationService {
  PomodoroNotificationService({LocalNotificationService? notifications})
    : _notifications = notifications ?? LocalNotificationService();

  final LocalNotificationService _notifications;
  static const timerNotificationId = 90001;

  Future<void> initialize() => _notifications.initialize();

  Future<void> requestPermission() async => _notifications.requestPermission();

  Future<void> scheduleEnd({
    required PomodoroPhase phase,
    required DateTime targetEndAt,
  }) {
    return _notifications.schedule(_notificationFor(phase), targetEndAt);
  }

  Future<void> showFinished(PomodoroPhase phase) =>
      _notifications.show(_notificationFor(phase));

  Future<void> cancel() => _notifications.cancel(timerNotificationId);

  ReminderNotification _notificationFor(PomodoroPhase phase) {
    return ReminderNotification(
      id: timerNotificationId,
      channel: ReminderNotificationChannel.pomodoro,
      title: '${phase.label}计时结束',
      body: phase == PomodoroPhase.focus ? '辛苦了，起来休息一下吧。' : '休息结束，可以开始下一轮专注了。',
      payload: 'pomodoro:${phase.storageValue}',
    );
  }
}
