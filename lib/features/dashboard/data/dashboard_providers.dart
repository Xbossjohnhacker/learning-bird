import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../domain/dashboard_models.dart';
import 'dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(databaseProvider));
});

final todaySummaryProvider = StreamProvider<TodaySummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchTodaySummary();
});

final statisticsPeriodProvider = StateProvider<StatisticsPeriod>((ref) {
  return StatisticsPeriod.daily;
});

final statisticsProvider = FutureProvider<StatisticsSummary>((ref) {
  final period = ref.watch(statisticsPeriodProvider);
  return ref.watch(dashboardRepositoryProvider).loadStatistics(period);
});
