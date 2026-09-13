enum StatisticsPeriod {
  daily,
  weekly,
  monthly;

  String get label => switch (this) {
    StatisticsPeriod.daily => '按日',
    StatisticsPeriod.weekly => '按周',
    StatisticsPeriod.monthly => '按月',
  };
}

class TodaySummary {
  const TodaySummary({
    required this.planTotal,
    required this.planCompleted,
    required this.dueWords,
    required this.reviewedWords,
    required this.pomodoroCount,
    required this.focusMinutes,
    this.nextPlanTitle,
    this.nextPlanAt,
  });

  final int planTotal;
  final int planCompleted;
  final int dueWords;
  final int reviewedWords;
  final int pomodoroCount;
  final int focusMinutes;
  final String? nextPlanTitle;
  final DateTime? nextPlanAt;

  double get planProgress => planTotal == 0 ? 0 : planCompleted / planTotal;
}

class StatisticsPoint {
  const StatisticsPoint({
    required this.label,
    required this.focusMinutes,
    required this.completedPlans,
    required this.reviewedWords,
  });

  final String label;
  final int focusMinutes;
  final int completedPlans;
  final int reviewedWords;
}

class StatisticsSummary {
  const StatisticsSummary({
    required this.points,
    required this.totalFocusMinutes,
    required this.completedPlans,
    required this.reviewedWords,
  });

  final List<StatisticsPoint> points;
  final int totalFocusMinutes;
  final int completedPlans;
  final int reviewedWords;
}
