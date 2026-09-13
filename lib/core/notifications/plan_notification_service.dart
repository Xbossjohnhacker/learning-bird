import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';

final planNotificationServiceProvider = Provider<PlanNotificationService>((
  ref,
) {
  return PlanNotificationService(
    notifications: ref.watch(localNotificationServiceProvider),
  );
});

final notificationPermissionProvider = FutureProvider<bool>((ref) {
  return ref.watch(planNotificationServiceProvider).notificationsEnabled();
});

class PlanNotificationService {
  PlanNotificationService({LocalNotificationService? notifications})
    : _notifications = notifications ?? LocalNotificationService();

  final LocalNotificationService _notifications;
  static const backgroundTestNotificationId = 99002;

  Future<void> initialize() => _notifications.initialize();

  Future<bool> requestPermission() => _notifications.requestPermission();

  Future<bool> notificationsEnabled() => _notifications.notificationsEnabled();

  Future<bool> requestFullScreenIntentPermission() =>
      _notifications.requestFullScreenIntentPermission();

  Future<void> schedule({
    required int id,
    required String title,
    required DateTime triggerAt,
  }) {
    return _notifications.schedule(
      ReminderNotification(
        id: id,
        channel: ReminderNotificationChannel.plan,
        title: '学习计划提醒',
        body: title,
        payload: 'plan:$id',
      ),
      triggerAt,
    );
  }

  Future<void> cancel(int? id) => _notifications.cancel(id);

  Future<void> cancelAll() => _notifications.cancelAll();
}
