import 'plan_models.dart';

class WeekPlanBlock {
  WeekPlanBlock(this.item, this.day, this.startMinute, this.endMinute);
  final PlanListItem item;
  final int day;
  final double startMinute, endMinute;
  int lane = 0;
  int laneCount = 1;
}

List<WeekPlanBlock> layoutWeek(
  List<PlanListItem> plans,
  DateTime monday, {
  double minimumVisualMinutes = 28,
}) {
  final blocks = <WeekPlanBlock>[];
  for (var day = 0; day < 7; day++) {
    final start = DateTime(monday.year, monday.month, monday.day + day);
    final end = DateTime(monday.year, monday.month, monday.day + day + 1);
    final daily = <WeekPlanBlock>[];
    for (final plan in plans) {
      final finish = plan.startsAt.add(
        Duration(minutes: plan.estimatedMinutes),
      );
      if (!plan.startsAt.isBefore(end) || !finish.isAfter(start)) continue;
      final from = plan.startsAt.isBefore(start) ? start : plan.startsAt;
      final to = finish.isAfter(end) ? end : finish;
      final fromMinute = (from.hour * 60 + from.minute).toDouble();
      final toMinute = to == end
          ? 1440.0
          : (to.hour * 60 + to.minute).toDouble();
      daily.add(WeekPlanBlock(plan, day, fromMinute, toMinute));
    }
    daily.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final cluster = <WeekPlanBlock>[];
    final laneEnds = <double>[];
    void finishCluster() {
      for (final block in cluster) {
        block.laneCount = laneEnds.length;
      }
      cluster.clear();
      laneEnds.clear();
    }

    for (final block in daily) {
      if (laneEnds.isNotEmpty &&
          laneEnds.every((end) => end <= block.startMinute)) {
        finishCluster();
      }
      var lane = laneEnds.indexWhere((end) => end <= block.startMinute);
      // Minimum visual height is also reserved in lanes so short plans don't cover each other.
      final visualEnd = (block.startMinute + minimumVisualMinutes).clamp(
        block.endMinute,
        1440.0,
      );
      if (lane < 0) {
        lane = laneEnds.length;
        laneEnds.add(visualEnd);
      } else {
        laneEnds[lane] = visualEnd;
      }
      block.lane = lane;
      cluster.add(block);
    }
    finishCluster();
    blocks.addAll(daily);
  }
  return blocks;
}
