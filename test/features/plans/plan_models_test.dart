import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/plans/domain/plan_models.dart';

void main() {
  test('重复规则计算每天和每周的下一次时间', () {
    final current = DateTime(2026, 8, 27, 20, 30);

    expect(
      PlanRepeat.daily.nextOccurrence(current),
      DateTime(2026, 8, 28, 20, 30),
    );
    expect(
      PlanRepeat.weekly.nextOccurrence(current),
      DateTime(2026, 9, 3, 20, 30),
    );
  });

  test('每月重复会适配目标月份的最后一天', () {
    final result = PlanRepeat.monthly.nextOccurrence(DateTime(2027, 1, 31, 9));

    expect(result, DateTime(2027, 2, 28, 9));
  });

  test('一次性计划没有自动下一次时间', () {
    expect(PlanRepeat.none.nextOccurrence(DateTime.now()), isNull);
  });
}
