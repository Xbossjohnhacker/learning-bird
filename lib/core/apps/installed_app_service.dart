import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LaunchableApp {
  const LaunchableApp({required this.packageName, required this.label});

  final String packageName;
  final String label;
}

class InstalledAppService {
  const InstalledAppService();

  static const _channel = MethodChannel(
    'com.learningbird.learning_bird/linked_apps',
  );

  Future<List<LaunchableApp>> loadLaunchableApps() async {
    if (defaultTargetPlatform != TargetPlatform.android) return const [];
    final raw = await _channel.invokeListMethod<Object?>('getLaunchableApps');
    return (raw ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => LaunchableApp(
            packageName: item['packageName']! as String,
            label: item['label']! as String,
          ),
        )
        .toList(growable: false);
  }

  Future<Uint8List?> loadIcon(String packageName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    return _channel.invokeMethod<Uint8List>('getAppIcon', <String, Object?>{
      'packageName': packageName,
    });
  }

  Future<bool> launch(String packageName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    return await _channel.invokeMethod<bool>('launchApp', <String, Object?>{
          'packageName': packageName,
        }) ??
        false;
  }
}

final installedAppServiceProvider = Provider<InstalledAppService>(
  (ref) => const InstalledAppService(),
);

final installedAppIconProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, packageName) {
      return ref.read(installedAppServiceProvider).loadIcon(packageName);
    });
