import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS 工程、应用信息、品牌资源和通知入口齐全', () {
    final info = File('ios/Runner/Info.plist').readAsStringSync();
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(info, contains('<string>Learning Bird</string>'));
    expect(info, contains('<string>1.0.0</string>'));
    expect(info, contains('<key>ITSAppUsesNonExemptEncryption</key>'));
    expect(project, contains('IPHONEOS_DEPLOYMENT_TARGET = 13.0;'));
    expect(
      project,
      contains('PRODUCT_BUNDLE_IDENTIFIER = com.learningbird.learningbird;'),
    );
    expect(delegate, contains('UNUserNotificationCenter.current().delegate'));
    expect(pubspec, isNot(contains('flutter_tts:')));

    final iconDirectory = Directory(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    );
    final manifest =
        jsonDecode(
              File('${iconDirectory.path}/Contents.json').readAsStringSync(),
            )
            as Map<String, Object?>;
    final images = manifest['images']! as List<Object?>;
    final filenames = images
        .cast<Map<String, Object?>>()
        .map((image) => image['filename'])
        .whereType<String>()
        .toSet();
    expect(filenames, isNotEmpty);
    for (final filename in filenames) {
      final image = File('${iconDirectory.path}/$filename');
      expect(image.existsSync(), isTrue, reason: '缺少 iOS 图标 $filename');
      expect(image.lengthSync(), greaterThan(0));
      final bytes = image.readAsBytesSync();
      expect(bytes[25], isNot(anyOf(4, 6)), reason: 'iOS 图标不能包含 Alpha 通道');
    }

    for (final filename in [
      'LaunchImage.png',
      'LaunchImage@2x.png',
      'LaunchImage@3x.png',
    ]) {
      final image = File(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/$filename',
      );
      expect(image.existsSync(), isTrue, reason: '缺少 iOS 启动图 $filename');
      expect(image.lengthSync(), greaterThan(0));
    }
  });
}
