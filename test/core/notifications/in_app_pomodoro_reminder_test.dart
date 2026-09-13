import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/app/navigation.dart';
import 'package:learning_bird/core/notifications/in_app_pomodoro_reminder.dart';
import 'package:learning_bird/features/pomodoro/data/pomodoro_providers.dart';
import 'package:learning_bird/features/pomodoro/domain/pomodoro_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('专注和休息结束都会显示对应弹窗', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: InAppPomodoroReminderHost(
            child: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Column(
                  children: [
                    FilledButton(
                      key: const ValueKey('finish-focus'),
                      onPressed: () {
                        ref
                            .read(pomodoroFinishedEventProvider.notifier)
                            .state = const PomodoroFinishedEvent(
                          sessionId: 1,
                          finishedPhase: PomodoroPhase.focus,
                          nextPhase: PomodoroPhase.shortBreak,
                        );
                      },
                      child: const Text('结束专注'),
                    ),
                    FilledButton(
                      key: const ValueKey('finish-break'),
                      onPressed: () {
                        ref
                            .read(pomodoroFinishedEventProvider.notifier)
                            .state = const PomodoroFinishedEvent(
                          sessionId: 2,
                          finishedPhase: PomodoroPhase.shortBreak,
                          nextPhase: PomodoroPhase.focus,
                        );
                      },
                      child: const Text('结束休息'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('finish-focus')));
    await tester.pumpAndSettle();
    expect(find.text('专注时间结束'), findsOneWidget);
    expect(find.text('本轮专注已完成。接下来建议进行短休息。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始短休息'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '稍后休息'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('finish-break')));
    await tester.pumpAndSettle();
    expect(find.text('休息时间结束'), findsOneWidget);
    expect(find.text('休息完成，可以开始下一轮专注了。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始专注'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '稍后开始'));
    await tester.pumpAndSettle();
    expect(find.text('休息时间结束'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
