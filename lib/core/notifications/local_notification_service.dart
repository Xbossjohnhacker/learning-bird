import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

enum ReminderNotificationChannel {
  plan(
    androidId: 'study_plan_alerts_v2',
    androidName: '计划到时弹窗',
    androidDescription: '计划和课程开始前显示顶部横幅、声音和振动提醒',
    iosThreadIdentifier: 'study_plan_reminders',
  ),
  pomodoro(
    androidId: 'pomodoro_timer_alerts_v2',
    androidName: '番茄钟到时弹窗',
    androidDescription: '专注和休息结束时显示顶部横幅、声音和振动提醒',
    iosThreadIdentifier: 'pomodoro_timer',
  );

  const ReminderNotificationChannel({
    required this.androidId,
    required this.androidName,
    required this.androidDescription,
    required this.iosThreadIdentifier,
  });

  final String androidId;
  final String androidName;
  final String androidDescription;
  final String iosThreadIdentifier;
}

class ReminderNotification {
  const ReminderNotification({
    required this.id,
    required this.channel,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final ReminderNotificationChannel channel;
  final String title;
  final String body;
  final String payload;
}

/// Owns the notification plugin and all platform-specific reminder policy.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _android;
      final granted = await android?.requestNotificationsPermission() ?? true;
      if (!(await android?.canScheduleExactNotifications() ?? true)) {
        await android?.requestExactAlarmsPermission();
      }
      return granted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }
    return true;
  }

  Future<bool> notificationsEnabled() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return (await _ios?.checkPermissions())?.isEnabled ?? true;
    }
    return true;
  }

  Future<bool> requestFullScreenIntentPermission() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await _android?.requestFullScreenIntentPermission() ?? true;
  }

  Future<void> schedule(
    ReminderNotification notification,
    DateTime triggerAt,
  ) async {
    await initialize();
    final utc = triggerAt.toUtc();
    if (!utc.isAfter(DateTime.now().toUtc())) return;
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(utc, tz.UTC),
      notificationDetails: _detailsFor(notification.channel),
      androidScheduleMode: await _scheduleMode(),
      payload: notification.payload,
    );
  }

  Future<void> show(ReminderNotification notification) async {
    await initialize();
    await _plugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: _detailsFor(notification.channel),
      payload: notification.payload,
    );
  }

  Future<void> cancel(int? id) async {
    if (id == null) return;
    await initialize();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<AndroidScheduleMode> _scheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    // Alarm clock scheduling avoids large vendor-specific delivery windows for
    // user-created, time-critical reminders.
    return (await _android?.canScheduleExactNotifications() ?? false)
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _detailsFor(ReminderNotificationChannel channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.androidId,
        channel.androidName,
        channelDescription: channel.androidDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        threadIdentifier: channel.iosThreadIdentifier,
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }
}
