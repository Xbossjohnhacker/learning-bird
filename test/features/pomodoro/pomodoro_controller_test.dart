import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/core/database/app_database.dart';
import 'package:learning_bird/core/notifications/pomodoro_notification_service.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_providers.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_repository.dart';
import 'package:learning_bird/features/pomodoro/domain/pomodoro_models.dart';

class _RecordingPomodoroNotifications extends PomodoroNotificationService {
  int cancelled = 0;
  int directlyShown = 0;

  @override
  Future<void> cancel() async => cancelled++;

  @override
  Future<void> showFinished(PomodoroPhase phase) async => directlyShown++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final phase in [PomodoroPhase.focus, PomodoroPhase.shortBreak]) {
    test('${phase.label}到时完成并发送应用内弹窗事件', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = PomodoroRepository(database);
      final now = DateTime.now();
      await repository.startSession(
        phase: phase,
        startedAt: now.subtract(const Duration(minutes: 2)),
        targetEndAt: now.subtract(const Duration(seconds: 1)),
      );
      final notifications = _RecordingPomodoroNotifications();
      final events = <PomodoroFinishedEvent>[];
      final controller = PomodoroController(
        repository: repository,
        notifications: notifications,
        onFinished: events.add,
        isAppForeground: () => true,
      );

      for (var attempt = 0; attempt < 50 && events.isEmpty; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(events, hasLength(1));
      expect(events.single.finishedPhase, phase);
      expect(
        events.single.nextPhase,
        phase == PomodoroPhase.focus
            ? PomodoroPhase.shortBreak
            : PomodoroPhase.focus,
      );
      expect(controller.state.isIdle, isTrue);
      expect(notifications.cancelled, 1);
      expect(notifications.directlyShown, 0);

      controller.dispose();
      await database.close();
    });
  }

  test('后台到时保留系统定时通知且不尝试应用内弹窗', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = PomodoroRepository(database);
    final now = DateTime.now();
    await repository.startSession(
      phase: PomodoroPhase.focus,
      startedAt: now.subtract(const Duration(minutes: 2)),
      targetEndAt: now.subtract(const Duration(seconds: 1)),
    );
    final notifications = _RecordingPomodoroNotifications();
    final events = <PomodoroFinishedEvent>[];
    final controller = PomodoroController(
      repository: repository,
      notifications: notifications,
      onFinished: events.add,
      isAppForeground: () => false,
    );

    for (var attempt = 0; attempt < 50 && controller.state.loading; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(controller.state.isIdle, isTrue);
    expect(notifications.cancelled, 0);
    expect(events, isEmpty);

    controller.dispose();
    await database.close();
  });
}
