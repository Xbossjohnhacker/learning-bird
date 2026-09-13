import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/notifications/plan_notification_service.dart';
import '../../../core/apps/installed_app_service.dart';
import '../data/plans_providers.dart';
import '../domain/plan_models.dart';
import 'weekly_plan_grid.dart';
import 'editor/linked_app_picker.dart';

class PlansHomePage extends ConsumerWidget {
  const PlansHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedPlanDateProvider);
    final plans = ref.watch(plansForSelectedDateProvider);
    final weekly = ref.watch(weeklyPlanViewProvider);
    final weekPlans = ref.watch(plansForSelectedWeekProvider);
    final courseSchedules = ref.watch(courseSchedulesProvider);
    final selectedCourseSchedule = ref.watch(selectedCourseScheduleIdProvider);
    ref.watch(planReminderRestoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('计划'),
        actions: [
          IconButton(
            tooltip: '导入课表',
            onPressed: () => context.push('/plans/import'),
            icon: const Icon(Icons.file_upload_outlined),
          ),
          if (weekly)
            IconButton(
              tooltip: '创建计划',
              onPressed: () => _create(context, selectedDate),
              icon: const Icon(Icons.add),
            ),
          IconButton(
            tooltip: '选择日期',
            onPressed: () => _pickDate(context, ref, selectedDate),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      floatingActionButton: weekly
          ? null
          : FloatingActionButton.extended(
              heroTag: 'plans-create-fab',
              onPressed: () => _create(context, selectedDate),
              icon: const Icon(Icons.add),
              label: const Text('创建计划'),
            ),
      body: GestureDetector(
        key: const ValueKey('weekly-swipe-surface'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: weekly
            ? (details) => _swipeWeek(ref, selectedDate, details)
            : null,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.calendar_view_week),
                    label: Text('周规划表'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.view_list_outlined),
                    label: Text('日列表'),
                  ),
                ],
                selected: {weekly},
                onSelectionChanged: (value) {
                  final showWeekly = value.single;
                  if (!showWeekly) {
                    final now = DateTime.now();
                    ref.read(selectedPlanDateProvider.notifier).state =
                        DateTime(now.year, now.month, now.day);
                  }
                  ref.read(weeklyPlanViewProvider.notifier).state = showWeekly;
                },
              ),
            ),
            courseSchedules.when(
              loading: () => const SizedBox(height: 4),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) => _CourseScheduleSelector(
                items: items,
                selectedId: selectedCourseSchedule,
                onSelected: (id) {
                  ref.read(selectedCourseScheduleIdProvider.notifier).state =
                      id;
                },
                onManage: () => _manageCourseSchedules(context, ref, items),
              ),
            ),
            if (weekly) ...[
              Row(
                children: [
                  IconButton(
                    tooltip: '上一周',
                    onPressed: () => _changeWeek(ref, selectedDate, -7),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      _weekTitle(selectedDate),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: '下一周',
                    onPressed: () => _changeWeek(ref, selectedDate, 7),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(selectedPlanDateProvider.notifier).state =
                            DateTime.now(),
                    child: const Text('本周'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '左右滑动切换周 · 点击课程查看详情',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ] else
              _DateStrip(selectedDate: selectedDate),
            const Divider(height: 1),
            Expanded(
              child: weekly
                  ? weekPlans.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => Center(
                        child: TextButton(
                          onPressed: () =>
                              ref.invalidate(plansForSelectedWeekProvider),
                          child: const Text('周计划加载失败，点击重试'),
                        ),
                      ),
                      data: (items) => WeeklyPlanGrid(
                        date: selectedDate,
                        items: items,
                        onDay: (day) {
                          ref.read(selectedPlanDateProvider.notifier).state =
                              day;
                          ref.read(weeklyPlanViewProvider.notifier).state =
                              false;
                        },
                        onOpen: (item) => _openPlan(context, ref, item),
                      ),
                    )
                  : plans.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('加载失败：$error')),
                      data: (items) {
                        if (items.isEmpty) {
                          return _EmptyPlans(
                            date: selectedDate,
                            onCreate: () => context.push(
                              Uri(
                                path: '/plans/new',
                                queryParameters: {
                                  'date': selectedDate.toIso8601String(),
                                },
                              ).toString(),
                            ),
                          );
                        }
                        final completed = items
                            .where((item) => item.isCompleted)
                            .length;
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _dateTitle(selectedDate),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                                Text('完成 $completed / ${items.length}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: items.isEmpty
                                  ? 0
                                  : completed / items.length,
                            ),
                            const SizedBox(height: 16),
                            for (final item in items) ...[
                              _PlanCard(
                                item: item,
                                onStart: () => ref
                                    .read(plansRepositoryProvider)
                                    .startPlan(item.id),
                                onComplete: () => _complete(context, ref, item),
                                onCancelRepeat: () =>
                                    _cancelRepeat(context, ref, item),
                                onDelete: () => _delete(context, ref, item),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _create(BuildContext context, DateTime selectedDate) {
    context.push(
      Uri(
        path: '/plans/new',
        queryParameters: {'date': selectedDate.toIso8601String()},
      ).toString(),
    );
  }

  void _changeWeek(WidgetRef ref, DateTime date, int days) {
    ref.read(selectedPlanDateProvider.notifier).state = DateTime(
      date.year,
      date.month,
      date.day + days,
    );
  }

  void _swipeWeek(
    WidgetRef ref,
    DateTime selectedDate,
    DragEndDetails details,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 180) return;
    _changeWeek(ref, selectedDate, velocity < 0 ? 7 : -7);
  }

  String _weekTitle(DateTime date) {
    final monday = DateTime(date.year, date.month, date.day - date.weekday + 1);
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    return '${monday.year}/${monday.month}/${monday.day} – ${sunday.month}/${sunday.day}';
  }

  Future<void> _openPlan(
    BuildContext context,
    WidgetRef ref,
    PlanListItem item,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlanCard(
                  item: item,
                  onStart: () {
                    Navigator.pop(sheetContext);
                    ref.read(plansRepositoryProvider).startPlan(item.id);
                  },
                  onComplete: () {
                    Navigator.pop(sheetContext);
                    _complete(context, ref, item);
                  },
                  onCancelRepeat: () {
                    Navigator.pop(sheetContext);
                    _cancelRepeat(context, ref, item);
                  },
                  onDelete: () {
                    Navigator.pop(sheetContext);
                    _delete(context, ref, item);
                  },
                ),
                if (item.note != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(item.note!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime initial,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      ref.read(selectedPlanDateProvider.notifier).state = picked;
    }
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    PlanListItem item,
  ) async {
    final generateNext = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '完成“${item.title}”',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('选择完成后的安排。'),
              const SizedBox(height: 16),
              if (!(item.note?.startsWith('[课表导入]') ?? false))
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    item.repeat == PlanRepeat.none
                        ? '完成，并安排到明天'
                        : '完成，并生成下一次（${item.repeat.label}）',
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('仅标记完成'),
              ),
            ],
          ),
        ),
      ),
    );
    if (generateNext == null) return;

    final notifications = ref.read(planNotificationServiceProvider);
    await notifications.cancel(item.notificationId);
    final next = await ref
        .read(plansRepositoryProvider)
        .completePlan(item, generateNext: generateNext);
    if (next?.notificationId != null && next?.reminderAt != null) {
      await notifications.schedule(
        id: next!.notificationId!,
        title: next.title,
        triggerAt: next.reminderAt!,
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PlanListItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除计划？'),
        content: Text('“${item.title}”将从计划列表移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(planNotificationServiceProvider).cancel(item.notificationId);
    await ref.read(plansRepositoryProvider).softDelete(item.id);
  }

  Future<void> _manageCourseSchedules(
    BuildContext context,
    WidgetRef ref,
    List<CourseScheduleOption> items,
  ) async {
    final target = await showModalBottomSheet<CourseScheduleOption>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                '选择和管理课表',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              subtitle: const Text('点击名称切换课表，右侧按钮用于删除'),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    key: const ValueKey('select-course-schedule-none'),
                    leading: const Icon(Icons.event_note_outlined),
                    title: const Text('仅显示普通计划'),
                    trailing: ref.read(selectedCourseScheduleIdProvider) == -1
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: () {
                      ref
                              .read(selectedCourseScheduleIdProvider.notifier)
                              .state =
                          -1;
                      Navigator.pop(sheetContext);
                    },
                  ),
                  for (final item in items)
                    ListTile(
                      key: ValueKey('select-course-schedule-${item.id}'),
                      leading: Icon(_scheduleIcon(item.sourceKind)),
                      title: Text(item.name),
                      subtitle: Text(_scheduleSourceLabel(item.sourceKind)),
                      selected:
                          ref.read(selectedCourseScheduleIdProvider) == item.id,
                      onTap: () {
                        ref
                                .read(selectedCourseScheduleIdProvider.notifier)
                                .state =
                            item.id;
                        Navigator.pop(sheetContext);
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ref.read(selectedCourseScheduleIdProvider) ==
                              item.id)
                            const Icon(Icons.check_circle),
                          IconButton(
                            tooltip: '删除 ${item.name}',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => Navigator.pop(sheetContext, item),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (target == null || !context.mounted) return;
    final repository = ref.read(plansRepositoryProvider);
    final info = await repository.courseScheduleDeleteInfo(target.id);
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除课表？'),
        content: Text(
          '“${target.name}”及其中 ${info.courseCount} 条课程将被永久删除，'
          '对应提醒也会取消。普通计划和其他课表不受影响。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除课表'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await repository.deleteCourseSchedule(target.id);
    final notifications = ref.read(planNotificationServiceProvider);
    for (final notificationId in deleted.notificationIds) {
      await notifications.cancel(notificationId);
    }
    if (ref.read(selectedCourseScheduleIdProvider) == target.id) {
      final remaining = items.where((item) => item.id != target.id);
      ref.read(selectedCourseScheduleIdProvider.notifier).state =
          remaining.isEmpty ? -1 : remaining.first.id;
    }
    ref.invalidate(courseSchedulesProvider);
    ref.invalidate(plansForSelectedWeekProvider);
    ref.invalidate(plansForSelectedDateProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除“${target.name}”及 ${deleted.courseCount} 条课程'),
      ),
    );
  }

  static IconData _scheduleIcon(String sourceKind) => sourceKind == 'web'
      ? Icons.language_outlined
      : sourceKind == 'excel'
      ? Icons.table_view_outlined
      : Icons.history;

  static String _scheduleSourceLabel(String sourceKind) => sourceKind == 'web'
      ? '教务系统导入'
      : sourceKind == 'excel'
      ? 'Excel 导入'
      : '历史导入';

  Future<void> _cancelRepeat(
    BuildContext context,
    WidgetRef ref,
    PlanListItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('取消重复计划？'),
        content: Text(
          '“${item.title}”将保留在当前日期，但完成后不再自动按${item.repeat.label}生成。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('继续重复'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('取消重复'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(plansRepositoryProvider).cancelRepeat(item.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已取消重复，当前计划仍然保留')));
  }

  static String _dateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized == today) return '今天';
    if (normalized == today.add(const Duration(days: 1))) return '明天';
    return '${date.month}月${date.day}日';
  }
}

class _DateStrip extends ConsumerStatefulWidget {
  const _DateStrip({required this.selectedDate});

  final DateTime selectedDate;

  @override
  ConsumerState<_DateStrip> createState() => _DateStripState();

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _weekday(int weekday) {
    return const ['一', '二', '三', '四', '五', '六', '日'][weekday - 1];
  }
}

class _DateStripState extends ConsumerState<_DateStrip> {
  static const _dateRadius = 45;
  static const _itemExtent = 72.0;
  final ScrollController _controller = ScrollController();
  bool _needsCenter = true;

  @override
  void didUpdateWidget(covariant _DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_DateStrip._sameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _needsCenter = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      _dateRadius * 2 + 1,
      (index) => DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day - _dateRadius + index,
      ),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return SizedBox(
      height: 88,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _centerSelectedDate(constraints.maxWidth);
          return ListView.builder(
            key: const ValueKey('plan-date-strip'),
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemExtent: _itemExtent,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              return _DateStripItem(
                date: date,
                selected: _DateStrip._sameDay(date, widget.selectedDate),
                isToday: _DateStrip._sameDay(date, today),
                onTap: () =>
                    ref.read(selectedPlanDateProvider.notifier).state = date,
              );
            },
          );
        },
      ),
    );
  }

  void _centerSelectedDate(double viewportWidth) {
    if (!_needsCenter) return;
    _needsCenter = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final desired =
          _dateRadius * _itemExtent + _itemExtent / 2 - viewportWidth / 2;
      final target = desired.clamp(
        _controller.position.minScrollExtent,
        _controller.position.maxScrollExtent,
      );
      _controller.jumpTo(target);
    });
  }
}

class _DateStripItem extends StatelessWidget {
  const _DateStripItem({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: isToday ? '今天 ${date.day}日' : '${date.month}月${date.day}日',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: isToday ? const ValueKey('today-date-chip') : null,
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: selected ? colors.primaryContainer : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isToday
                      ? colors.primary
                      : colors.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? '今' : _DateStrip._weekday(date.weekday),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isToday ? colors.primary : null,
                      fontWeight: isToday ? FontWeight.w700 : null,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? colors.onPrimaryContainer : null,
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({
    required this.item,
    required this.onStart,
    required this.onComplete,
    required this.onCancelRepeat,
    required this.onDelete,
  });

  final PlanListItem item;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onCancelRepeat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time =
        '${item.startsAt.hour.toString().padLeft(2, '0')}:${item.startsAt.minute.toString().padLeft(2, '0')}';
    final location = planLocationFromNote(item.note);
    final priorityColor = switch (item.priority) {
      2 => Colors.red,
      0 => Colors.blueGrey,
      _ => Colors.orange,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: item.isCompleted ? Colors.green : priorityColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text('$time · ${item.estimatedMinutes} 分钟'),
                      if (location != null)
                        Row(
                          key: ValueKey('day-plan-location-${item.id}'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 3),
                            Text(location),
                          ],
                        ),
                      if (item.categoryName != null) Text(item.categoryName!),
                      if (item.courseScheduleName != null)
                        Text(item.courseScheduleName!),
                      if (item.repeat != PlanRepeat.none)
                        Text(item.repeat.label),
                      if (item.reminderOffsetMinutes != null)
                        Text(
                          item.reminderOffsetMinutes == 0
                              ? '开始时提醒'
                              : '提前 ${item.reminderOffsetMinutes} 分钟',
                        ),
                    ],
                  ),
                  if (item.note?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (item.linkedAppPackage != null)
              IconButton(
                key: ValueKey('open-linked-app-${item.id}'),
                tooltip: '打开 ${item.linkedAppName ?? '关联应用'}',
                onPressed: () => _openLinkedApp(context, ref),
                icon: LinkedAppIcon(
                  packageName: item.linkedAppPackage!,
                  size: 30,
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'start') onStart();
                if (value == 'complete') onComplete();
                if (value == 'cancel-repeat') onCancelRepeat();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (!item.isCompleted && !item.isInProgress)
                  const PopupMenuItem(value: 'start', child: Text('开始执行')),
                if (!item.isCompleted)
                  const PopupMenuItem(value: 'complete', child: Text('完成')),
                if (!item.isCompleted && item.repeat != PlanRepeat.none)
                  PopupMenuItem(
                    value: 'cancel-repeat',
                    child: Text('取消${item.repeat.label}重复'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLinkedApp(BuildContext context, WidgetRef ref) async {
    final opened = await ref
        .read(installedAppServiceProvider)
        .launch(item.linkedAppPackage!);
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('无法打开 ${item.linkedAppName ?? '关联应用'}，可能已被卸载')),
    );
  }
}

class _CourseScheduleSelector extends ConsumerWidget {
  const _CourseScheduleSelector({
    required this.items,
    required this.selectedId,
    required this.onSelected,
    required this.onManage,
  });

  final List<CourseScheduleOption> items;
  final int selectedId;
  final ValueChanged<int> onSelected;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelected = items.any((item) => item.id == selectedId);
    if (selectedId == 0 || selectedId > 0 && !hasSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(selectedCourseScheduleIdProvider.notifier).state =
            items.isEmpty ? -1 : items.first.id;
      });
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              key: const ValueKey('course-schedule-selector'),
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('仅计划'),
                    selected: selectedId == -1,
                    onSelected: (_) => onSelected(-1),
                  ),
                ),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('course-schedule-${item.id}'),
                      avatar: Icon(
                        PlansHomePage._scheduleIcon(item.sourceKind),
                        size: 18,
                      ),
                      label: Text('计划 + ${item.name}'),
                      selected: selectedId == item.id,
                      onSelected: (_) => onSelected(item.id),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: '选择和管理课表',
            onPressed: onManage,
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans({required this.date, required this.onCreate});

  final DateTime date;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available_outlined, size: 68),
            const SizedBox(height: 16),
            Text('这一天还没有计划', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('创建一项明确、可执行的学习任务。'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('创建计划'),
            ),
          ],
        ),
      ),
    );
  }
}
