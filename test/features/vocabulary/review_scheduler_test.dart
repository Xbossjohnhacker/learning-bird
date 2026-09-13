import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/vocabulary/domain/review_scheduler.dart';

void main() {
  final now = DateTime.utc(2026, 8, 26, 8);

  test('跳过已认识词直接通过各确认阶段，后续遗忘仍重置三次', () {
    for (final state in [
      'new',
      'learning_0',
      'learning_1',
      'learning_2',
      'reviewing',
    ]) {
      final passed = ReviewScheduler.next(
        rating: ReviewRating.alreadyKnown,
        reviewedAt: now,
        learningState: state,
        lastRating: 'forgot',
        currentLapseCount: 2,
      );
      expect(passed.needsConfirmation, isFalse);
      expect(passed.intervalDays, 3);
      expect(passed.streak, 1);
      expect(passed.lapseCount, 2);
      final forgot = ReviewScheduler.next(
        rating: ReviewRating.forgot,
        reviewedAt: now,
        learningState: passed.learningState,
        lastRating: 'already_known',
      );
      expect(forgot.learningState, 'learning_0');
      expect(forgot.needsConfirmation, isTrue);
    }
  });

  test('后续复习沿用间隔，遗忘立即进入三次确认', () {
    expect(
      ReviewScheduler.next(rating: ReviewRating.forgot, reviewedAt: now).dueAt,
      now,
    );
    expect(
      ReviewScheduler.next(
        rating: ReviewRating.fuzzy,
        reviewedAt: now,
      ).intervalDays,
      1,
    );
    expect(
      ReviewScheduler.next(
        rating: ReviewRating.remembered,
        learningState: 'reviewing',
        reviewedAt: now,
      ).intervalDays,
      3,
    );
    expect(
      ReviewScheduler.next(
        rating: ReviewRating.mastered,
        learningState: 'mastered',
        reviewedAt: now,
      ).intervalDays,
      7,
    );
  });

  test('忘记会清空连续记忆次数并增加遗忘次数', () {
    final result = ReviewScheduler.next(
      rating: ReviewRating.forgot,
      reviewedAt: now,
      currentStreak: 5,
      currentLapseCount: 2,
    );

    expect(result.streak, 0);
    expect(result.lapseCount, 3);
    expect(result.learningState, 'learning_0');
    expect(result.needsConfirmation, isTrue);
  });

  test('新词前两次不通过，第三次通过且只增加一次复习轮次', () {
    var state = 'new';
    for (var count = 1; count <= 3; count++) {
      final result = ReviewScheduler.next(
        rating: ReviewRating.remembered,
        reviewedAt: now,
        learningState: state,
      );
      expect(result.needsConfirmation, count < 3);
      expect(result.streak, count < 3 ? 0 : 1);
      expect(result.intervalDays, count < 3 ? 0 : 3);
      state = result.learningState;
    }
    expect(state, 'reviewing');
  });

  test('两次认识后不认识清零，再需三次认识', () {
    final reset = ReviewScheduler.next(
      rating: ReviewRating.forgot,
      reviewedAt: now,
      learningState: 'learning_2',
    );
    expect(reset.learningState, 'learning_0');
    final next = ReviewScheduler.next(
      rating: ReviewRating.remembered,
      reviewedAt: now,
      learningState: reset.learningState,
    );
    expect(next.learningState, 'learning_1');
    expect(next.needsConfirmation, isTrue);
  });

  test('历史已通过词只需一次，历史遗忘词进入三次确认', () {
    for (final state in ['reviewing', 'mastered']) {
      final passed = ReviewScheduler.next(
        rating: ReviewRating.remembered,
        reviewedAt: now,
        learningState: state,
        currentStreak: 2,
      );
      expect(passed.needsConfirmation, isFalse);
      expect(passed.streak, 3);
    }
    final forgotten = ReviewScheduler.next(
      rating: ReviewRating.remembered,
      reviewedAt: now,
      learningState: 'reviewing',
      lastRating: 'forgot',
    );
    expect(forgotten.learningState, 'learning_1');
  });
}
