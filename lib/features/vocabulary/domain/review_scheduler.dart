enum ReviewRating { forgot, fuzzy, remembered, mastered, alreadyKnown }

extension ReviewRatingLabel on ReviewRating {
  String get storageValue => switch (this) {
    ReviewRating.forgot => 'forgot',
    ReviewRating.fuzzy => 'fuzzy',
    ReviewRating.remembered => 'remembered',
    ReviewRating.mastered => 'mastered',
    ReviewRating.alreadyKnown => 'already_known',
  };

  String get label => switch (this) {
    ReviewRating.forgot => '忘记',
    ReviewRating.fuzzy => '模糊',
    ReviewRating.remembered => '记得',
    ReviewRating.mastered => '熟练',
    ReviewRating.alreadyKnown => '跳过（已认识）',
  };
}

class ReviewDecision {
  const ReviewDecision({
    required this.dueAt,
    required this.intervalDays,
    required this.streak,
    required this.lapseCount,
    this.learningState = 'reviewing',
  });

  final DateTime dueAt;
  final int intervalDays;
  final int streak;
  final int lapseCount;
  final String learningState;
  bool get needsConfirmation =>
      ReviewScheduler.needsConfirmation(learningState);
}

abstract final class ReviewScheduler {
  // Explicit confirmation states use the existing persisted learning_state field.
  // Old reviewing/mastered records remain passed; old forgotten records relearn.
  static bool needsConfirmation(String state, [String? lastRating]) =>
      state == 'new' || state.startsWith('learning_') || lastRating == 'forgot';

  static int confirmationCount(String state) => switch (state) {
    'learning_1' => 1,
    'learning_2' => 2,
    _ => 0,
  };

  static ReviewDecision next({
    required ReviewRating rating,
    required DateTime reviewedAt,
    int currentStreak = 0,
    int currentLapseCount = 0,
    String learningState = 'new',
    String? lastRating,
  }) {
    final utc = reviewedAt.toUtc();

    if ((rating == ReviewRating.remembered ||
            rating == ReviewRating.mastered) &&
        needsConfirmation(learningState, lastRating)) {
      final count = confirmationCount(learningState) + 1;
      if (count < 3) {
        return ReviewDecision(
          dueAt: utc,
          intervalDays: 0,
          streak: currentStreak,
          lapseCount: currentLapseCount,
          learningState: 'learning_$count',
        );
      }
    }

    return switch (rating) {
      ReviewRating.forgot => ReviewDecision(
        dueAt: utc,
        intervalDays: 0,
        streak: 0,
        lapseCount: currentLapseCount + 1,
        learningState: 'learning_0',
      ),
      ReviewRating.fuzzy => ReviewDecision(
        dueAt: utc.add(const Duration(days: 1)),
        intervalDays: 1,
        streak: 0,
        lapseCount: currentLapseCount,
      ),
      ReviewRating.remembered => _remembered(
        utc,
        currentStreak,
        currentLapseCount,
      ),
      ReviewRating.mastered => _mastered(utc, currentStreak, currentLapseCount),
      // Explicitly known words bypass confirmation, but still get a review date.
      ReviewRating.alreadyKnown => _remembered(
        utc,
        currentStreak,
        currentLapseCount,
      ),
    };
  }

  static ReviewDecision _remembered(
    DateTime reviewedAt,
    int streak,
    int lapseCount,
  ) {
    final days = (3 * (streak + 1)).clamp(3, 60);
    return ReviewDecision(
      dueAt: reviewedAt.add(Duration(days: days)),
      intervalDays: days,
      streak: streak + 1,
      lapseCount: lapseCount,
    );
  }

  static ReviewDecision _mastered(
    DateTime reviewedAt,
    int streak,
    int lapseCount,
  ) {
    final days = (7 * (streak + 1)).clamp(7, 180);
    return ReviewDecision(
      dueAt: reviewedAt.add(Duration(days: days)),
      intervalDays: days,
      streak: streak + 1,
      lapseCount: lapseCount,
    );
  }
}
