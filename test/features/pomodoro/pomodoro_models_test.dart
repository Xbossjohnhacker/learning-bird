import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/pomodoro/domain/pomodoro_models.dart';

void main() {
  test('不同阶段读取各自配置时长', () {
    const settings = PomodoroSettings(
      focusMinutes: 30,
      shortBreakMinutes: 6,
      longBreakMinutes: 18,
    );

    expect(settings.minutesFor(PomodoroPhase.focus), 30);
    expect(settings.minutesFor(PomodoroPhase.shortBreak), 6);
    expect(settings.minutesFor(PomodoroPhase.longBreak), 18);
  });

  test('进度根据剩余时间计算并限制在有效范围', () {
    final state = PomodoroState.initial().copyWith(
      loading: false,
      remaining: const Duration(minutes: 10),
    );

    expect(state.progress, closeTo(0.6, 0.001));
    expect(state.copyWith(remaining: Duration.zero).progress, 1);
  });
}
