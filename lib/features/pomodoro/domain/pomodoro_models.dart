enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak;

  String get storageValue => switch (this) {
    PomodoroPhase.focus => 'focus',
    PomodoroPhase.shortBreak => 'short_break',
    PomodoroPhase.longBreak => 'long_break',
  };

  String get label => switch (this) {
    PomodoroPhase.focus => '专注',
    PomodoroPhase.shortBreak => '短休息',
    PomodoroPhase.longBreak => '长休息',
  };

  static PomodoroPhase fromStorage(String value) {
    return PomodoroPhase.values.firstWhere(
      (phase) => phase.storageValue == value,
      orElse: () => PomodoroPhase.focus,
    );
  }
}

enum PomodoroRunStatus { idle, running, paused }

class PomodoroFinishedEvent {
  const PomodoroFinishedEvent({
    required this.sessionId,
    required this.finishedPhase,
    required this.nextPhase,
  });

  final int sessionId;
  final PomodoroPhase finishedPhase;
  final PomodoroPhase nextPhase;
}

class PomodoroSettings {
  const PomodoroSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakEvery = 4,
  });

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakEvery;

  int minutesFor(PomodoroPhase phase) => switch (phase) {
    PomodoroPhase.focus => focusMinutes,
    PomodoroPhase.shortBreak => shortBreakMinutes,
    PomodoroPhase.longBreak => longBreakMinutes,
  };

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakEvery,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakEvery: longBreakEvery ?? this.longBreakEvery,
    );
  }
}

class PomodoroState {
  const PomodoroState({
    required this.phase,
    required this.status,
    required this.remaining,
    required this.settings,
    this.sessionId,
    this.planId,
    this.planTitle,
    this.targetEndAt,
    this.completedFocusCount = 0,
    this.loading = false,
  });

  factory PomodoroState.initial() {
    const settings = PomodoroSettings();
    return const PomodoroState(
      phase: PomodoroPhase.focus,
      status: PomodoroRunStatus.idle,
      remaining: Duration(minutes: 25),
      settings: settings,
      loading: true,
    );
  }

  final PomodoroPhase phase;
  final PomodoroRunStatus status;
  final Duration remaining;
  final PomodoroSettings settings;
  final int? sessionId;
  final int? planId;
  final String? planTitle;
  final DateTime? targetEndAt;
  final int completedFocusCount;
  final bool loading;

  bool get isIdle => status == PomodoroRunStatus.idle;
  bool get isRunning => status == PomodoroRunStatus.running;
  bool get isPaused => status == PomodoroRunStatus.paused;

  double get progress {
    final total = settings.minutesFor(phase) * 60;
    if (total <= 0) return 0;
    return (1 - remaining.inSeconds / total).clamp(0, 1);
  }

  PomodoroState copyWith({
    PomodoroPhase? phase,
    PomodoroRunStatus? status,
    Duration? remaining,
    PomodoroSettings? settings,
    int? sessionId,
    int? planId,
    String? planTitle,
    DateTime? targetEndAt,
    int? completedFocusCount,
    bool? loading,
    bool clearSession = false,
    bool clearPlan = false,
    bool clearTarget = false,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      settings: settings ?? this.settings,
      sessionId: clearSession ? null : (sessionId ?? this.sessionId),
      planId: clearPlan ? null : (planId ?? this.planId),
      planTitle: clearPlan ? null : (planTitle ?? this.planTitle),
      targetEndAt: clearTarget ? null : (targetEndAt ?? this.targetEndAt),
      completedFocusCount: completedFocusCount ?? this.completedFocusCount,
      loading: loading ?? this.loading,
    );
  }
}

class FocusPlanOption {
  const FocusPlanOption({
    required this.id,
    required this.title,
    this.courseScheduleId,
  });

  final int id;
  final String title;
  final int? courseScheduleId;

  bool get isCourse => courseScheduleId != null;
}
