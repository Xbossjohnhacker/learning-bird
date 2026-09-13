import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/pomodoro_notification_service.dart';
import '../../plans/data/plans_providers.dart';
import '../domain/pomodoro_models.dart';
import 'pomodoro_repository.dart';

final pomodoroRepositoryProvider = Provider<PomodoroRepository>((ref) {
  return PomodoroRepository(ref.watch(databaseProvider));
});

final availableFocusPlansProvider =
    StreamProvider.autoDispose<List<FocusPlanOption>>((ref) {
      final selection = ref.watch(selectedCourseScheduleIdProvider);
      final schedules = ref.watch(courseSchedulesProvider).valueOrNull;
      final selectedScheduleId = switch (selection) {
        > 0 => selection,
        -1 => null,
        _ when schedules != null && schedules.isNotEmpty => schedules.first.id,
        _ => null,
      };
      return ref
          .watch(pomodoroRepositoryProvider)
          .watchAvailablePlans(courseScheduleId: selectedScheduleId);
    });

final pomodoroFinishedEventProvider = StateProvider<PomodoroFinishedEvent?>(
  (ref) => null,
);

final pomodoroAppForegroundProvider = Provider<bool Function()>((ref) {
  return () =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
});

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
      final controller = PomodoroController(
        repository: ref.watch(pomodoroRepositoryProvider),
        notifications: ref.watch(pomodoroNotificationServiceProvider),
        onFinished: (event) {
          ref.read(pomodoroFinishedEventProvider.notifier).state = event;
        },
        isAppForeground: ref.watch(pomodoroAppForegroundProvider),
      );
      return controller;
    });

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController({
    required this._repository,
    required this._notifications,
    required this.onFinished,
    required this.isAppForeground,
  }) : super(PomodoroState.initial()) {
    _initialize();
  }

  final PomodoroRepository _repository;
  final PomodoroNotificationService _notifications;
  final void Function(PomodoroFinishedEvent event) onFinished;
  final bool Function() isAppForeground;
  Timer? _ticker;
  RestoredPomodoroSession? _active;
  bool _finishing = false;

  Future<void> _initialize() async {
    final settings = await _repository.loadSettings();
    final count = await _repository.completedFocusCountToday();
    final active = await _repository.loadActiveSession();
    _active = active;

    if (active == null) {
      state = state.copyWith(
        settings: settings,
        remaining: Duration(minutes: settings.focusMinutes),
        completedFocusCount: count,
        loading: false,
      );
      return;
    }

    final now = DateTime.now();
    final status = active.status == 'paused'
        ? PomodoroRunStatus.paused
        : PomodoroRunStatus.running;
    final reference = status == PomodoroRunStatus.paused
        ? (active.pausedAt ?? now)
        : now;
    final remaining = active.targetEndAt.difference(reference);
    state = PomodoroState(
      phase: active.phase,
      status: status,
      remaining: remaining.isNegative ? Duration.zero : remaining,
      settings: settings,
      sessionId: active.id,
      planId: active.planId,
      planTitle: active.planTitle,
      targetEndAt: active.targetEndAt,
      completedFocusCount: count,
      loading: false,
    );
    if (status == PomodoroRunStatus.running) {
      if (remaining <= Duration.zero) {
        await _finish();
      } else {
        _startTicker();
      }
    }
  }

  void selectPhase(PomodoroPhase phase) {
    if (!state.isIdle) return;
    state = state.copyWith(
      phase: phase,
      remaining: Duration(minutes: state.settings.minutesFor(phase)),
    );
  }

  void selectPlan(FocusPlanOption? plan) {
    if (!state.isIdle) return;
    state = state.copyWith(
      planId: plan?.id,
      planTitle: plan?.title,
      clearPlan: plan == null,
    );
  }

  Future<void> updateSettings(PomodoroSettings settings) async {
    if (!state.isIdle) return;
    await _repository.saveSettings(settings);
    state = state.copyWith(
      settings: settings,
      remaining: Duration(minutes: settings.minutesFor(state.phase)),
    );
  }

  Future<void> start() async {
    if (!state.isIdle || state.loading) return;
    final now = DateTime.now();
    final duration = Duration(minutes: state.settings.minutesFor(state.phase));
    final target = now.add(duration);
    final id = await _repository.startSession(
      phase: state.phase,
      startedAt: now,
      targetEndAt: target,
      planId: state.planId,
    );
    _active = RestoredPomodoroSession(
      id: id,
      phase: state.phase,
      status: 'running',
      startedAt: now,
      targetEndAt: target,
      pausedTotalMs: 0,
      planId: state.planId,
      planTitle: state.planTitle,
    );
    state = state.copyWith(
      status: PomodoroRunStatus.running,
      remaining: duration,
      sessionId: id,
      targetEndAt: target,
    );
    await _notifications.requestPermission();
    await _notifications.scheduleEnd(phase: state.phase, targetEndAt: target);
    _startTicker();
  }

  Future<void> pause() async {
    final active = _active;
    if (!state.isRunning || active == null) return;
    final now = DateTime.now();
    await _repository.pauseSession(active.id, now);
    await _notifications.cancel();
    _active = RestoredPomodoroSession(
      id: active.id,
      phase: active.phase,
      status: 'paused',
      startedAt: active.startedAt,
      targetEndAt: active.targetEndAt,
      pausedAt: now,
      pausedTotalMs: active.pausedTotalMs,
      planId: active.planId,
      planTitle: active.planTitle,
    );
    _ticker?.cancel();
    final remaining = active.targetEndAt.difference(now);
    state = state.copyWith(
      status: PomodoroRunStatus.paused,
      remaining: remaining.isNegative ? Duration.zero : remaining,
    );
  }

  Future<void> resume() async {
    final active = _active;
    if (!state.isPaused || active == null) return;
    final now = DateTime.now();
    final target = await _repository.resumeSession(active, now);
    final pauseMs = now.difference(active.pausedAt ?? now).inMilliseconds;
    _active = RestoredPomodoroSession(
      id: active.id,
      phase: active.phase,
      status: 'running',
      startedAt: active.startedAt,
      targetEndAt: target,
      pausedTotalMs: active.pausedTotalMs + pauseMs,
      planId: active.planId,
      planTitle: active.planTitle,
    );
    state = state.copyWith(
      status: PomodoroRunStatus.running,
      targetEndAt: target,
    );
    await _notifications.scheduleEnd(phase: state.phase, targetEndAt: target);
    _startTicker();
  }

  Future<void> stop() async {
    final active = _active;
    if (active == null || state.isIdle) return;
    await _repository.completeSession(
      id: active.id,
      phase: active.phase,
      startedAt: active.startedAt,
      pausedTotalMs: active.pausedTotalMs,
      completedAt: DateTime.now(),
      planId: active.planId,
      status: 'cancelled',
    );
    await _notifications.cancel();
    _ticker?.cancel();
    _active = null;
    state = state.copyWith(
      status: PomodoroRunStatus.idle,
      remaining: Duration(minutes: state.settings.minutesFor(state.phase)),
      clearSession: true,
      clearTarget: true,
    );
  }

  Future<void> reconcile() async {
    if (!state.isRunning) return;
    _tick();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final active = _active;
    if (!state.isRunning || active == null || _finishing) return;
    final remaining = active.targetEndAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _finish();
    } else {
      state = state.copyWith(remaining: remaining);
    }
  }

  Future<void> _finish() async {
    final active = _active;
    if (active == null || _finishing) return;
    _finishing = true;
    _ticker?.cancel();
    final phase = active.phase;
    await _repository.completeSession(
      id: active.id,
      phase: phase,
      startedAt: active.startedAt,
      pausedTotalMs: active.pausedTotalMs,
      completedAt: DateTime.now(),
      planId: active.planId,
    );
    final showInAppDialog = isAppForeground();
    if (showInAppDialog) {
      await _notifications.cancel();
    }

    var count = state.completedFocusCount;
    if (phase == PomodoroPhase.focus) count++;
    final nextPhase = phase == PomodoroPhase.focus
        ? (count % state.settings.longBreakEvery == 0
              ? PomodoroPhase.longBreak
              : PomodoroPhase.shortBreak)
        : PomodoroPhase.focus;
    _active = null;
    state = state.copyWith(
      phase: nextPhase,
      status: PomodoroRunStatus.idle,
      remaining: Duration(minutes: state.settings.minutesFor(nextPhase)),
      completedFocusCount: count,
      clearSession: true,
      clearTarget: true,
    );
    _finishing = false;
    if (showInAppDialog) {
      onFinished(
        PomodoroFinishedEvent(
          sessionId: active.id,
          finishedPhase: phase,
          nextPhase: nextPhase,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
