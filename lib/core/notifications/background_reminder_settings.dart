import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backgroundReminderSettingsProvider =
    Provider<BackgroundReminderSettingsService>((ref) {
      return const BackgroundReminderSettingsService();
    });

final backgroundReminderStatusProvider =
    FutureProvider<BackgroundReminderStatus>((ref) async {
      return ref.watch(backgroundReminderSettingsProvider).getStatus();
    });

class BackgroundReminderStatus {
  const BackgroundReminderStatus({
    required this.canScheduleExactly,
    required this.ignoringBatteryOptimizations,
    required this.manufacturer,
    required this.sdkInt,
    this.canUseFullScreenIntents = true,
    this.supported = true,
  });

  const BackgroundReminderStatus.unsupported()
    : canScheduleExactly = true,
      ignoringBatteryOptimizations = true,
      manufacturer = '',
      sdkInt = 0,
      canUseFullScreenIntents = true,
      supported = false;

  final bool canScheduleExactly;
  final bool ignoringBatteryOptimizations;
  final String manufacturer;
  final int sdkInt;
  final bool canUseFullScreenIntents;
  final bool supported;

  bool get needsColorOsConfirmation {
    final value = manufacturer.toLowerCase();
    return value.contains('oppo') ||
        value.contains('oneplus') ||
        value.contains('realme');
  }
}

class BackgroundReminderSettingsService {
  const BackgroundReminderSettingsService();

  static const _channel = MethodChannel(
    'com.learningbird.learning_bird/background_reminder_settings',
  );

  Future<BackgroundReminderStatus> getStatus() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const BackgroundReminderStatus.unsupported();
    }
    final result = await _channel.invokeMapMethod<String, Object?>('getStatus');
    return BackgroundReminderStatus(
      canScheduleExactly: result?['canScheduleExactly'] == true,
      ignoringBatteryOptimizations:
          result?['ignoringBatteryOptimizations'] == true,
      manufacturer: result?['manufacturer'] as String? ?? '',
      sdkInt: result?['sdkInt'] as int? ?? 0,
      canUseFullScreenIntents: result?['canUseFullScreenIntents'] == true,
    );
  }

  Future<void> openExactAlarmSettings() =>
      _channel.invokeMethod<void>('openExactAlarmSettings');

  Future<void> openAppDetails() =>
      _channel.invokeMethod<void>('openAppDetails');

  Future<void> openNotificationSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');

  Future<void> openBackgroundLaunchSettings() =>
      _channel.invokeMethod<void>('openBackgroundLaunchSettings');
}
