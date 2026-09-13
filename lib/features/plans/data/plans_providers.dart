import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/plan_notification_service.dart';
import '../domain/plan_models.dart';
import 'plans_repository.dart';
import 'course_import_repository.dart';

final courseImportRepositoryProvider = Provider<CourseImportRepository>(
  (ref) => CourseImportRepository(ref.watch(databaseProvider)),
);
final weeklyPlanViewProvider = StateProvider<bool>((ref) => false);
// 0 = 尚未初始化，-1 = 仅计划，正数 = 指定课表。
final selectedCourseScheduleIdProvider = StateProvider<int>((ref) => 0);
final courseSchedulesProvider =
    StreamProvider.autoDispose<List<CourseScheduleOption>>((ref) {
      return ref.watch(plansRepositoryProvider).watchCourseSchedules();
    });
final plansForSelectedWeekProvider =
    StreamProvider.autoDispose<List<PlanListItem>>((ref) {
      final selection = ref.watch(selectedCourseScheduleIdProvider);
      return ref
          .watch(plansRepositoryProvider)
          .watchPlansForWeek(
            ref.watch(selectedPlanDateProvider),
            courseScheduleId: selection > 0 ? selection : null,
            includeAllCourseSchedules: false,
          );
    });

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.watch(databaseProvider));
});

final selectedPlanDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final plansForSelectedDateProvider =
    StreamProvider.autoDispose<List<PlanListItem>>((ref) {
      final date = ref.watch(selectedPlanDateProvider);
      final selection = ref.watch(selectedCourseScheduleIdProvider);
      return ref
          .watch(plansRepositoryProvider)
          .watchPlansForDate(
            date,
            courseScheduleId: selection > 0 ? selection : null,
            includeAllCourseSchedules: false,
          );
    });

final categoriesProvider = StreamProvider.autoDispose<List<CategoryOption>>((
  ref,
) {
  return ref.watch(plansRepositoryProvider).watchCategories();
});

final planReminderRestoreProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(plansRepositoryProvider);
  final notifications = ref.watch(planNotificationServiceProvider);
  await notifications.initialize();
  final pending = await repository.loadPendingReminders();
  for (final reminder in pending) {
    final id = reminder.notificationId;
    final at = reminder.reminderAt;
    if (id != null && at != null) {
      await notifications.schedule(
        id: id,
        title: reminder.title,
        triggerAt: at,
      );
    }
  }
});
