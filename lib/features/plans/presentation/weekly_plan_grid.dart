import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/course_import.dart';
import '../domain/plan_models.dart';
import '../domain/weekly_layout.dart';

class WeeklyPlanGrid extends StatelessWidget {
  const WeeklyPlanGrid({
    super.key,
    required this.date,
    required this.items,
    required this.onOpen,
    required this.onDay,
  });

  final DateTime date;
  final List<PlanListItem> items;
  final ValueChanged<PlanListItem> onOpen;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(date.year, date.month, date.day - date.weekday + 1);
    final blocks = layoutWeek(items, monday, minimumVisualMinutes: 0);
    final startHour = blocks.fold(
      7,
      (hour, block) => math.min(hour, block.startMinute ~/ 60),
    );
    final endHour = blocks.fold(
      22,
      (hour, block) => math.max(hour, (block.endMinute / 60).ceil()),
    );
    final now = DateTime.now();
    final currentMonday = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    );
    final isCurrentWeek =
        monday.year == currentMonday.year &&
        monday.month == currentMonday.month &&
        monday.day == currentMonday.day;
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const timeWidth = 36.0;
        const headerHeight = 48.0;
        final timelineHeight = math.max(
          120.0,
          constraints.maxHeight - headerHeight,
        );
        final minuteHeight = timelineHeight / ((endHour - startHour) * 60.0);
        final dayWidth = (constraints.maxWidth - timeWidth) / 7;

        return Column(
          key: const ValueKey('complete-week-grid'),
          children: [
            SizedBox(
              height: headerHeight,
              child: Row(
                children: [
                  const SizedBox(
                    width: timeWidth,
                    child: Center(
                      child: Icon(Icons.schedule_outlined, size: 16),
                    ),
                  ),
                  for (var day = 0; day < 7; day++)
                    SizedBox(
                      width: dayWidth,
                      child: InkWell(
                        onTap: () => onDay(
                          DateTime(monday.year, monday.month, monday.day + day),
                        ),
                        child: Center(
                          child: Text(
                            '周${const ['一', '二', '三', '四', '五', '六', '日'][day]}\n'
                            '${DateTime(monday.year, monday.month, monday.day + day).month}/'
                            '${DateTime(monday.year, monday.month, monday.day + day).day}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, height: 1.2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: timelineHeight,
              child: Stack(
                children: [
                  for (var hour = startHour; hour <= endHour; hour++)
                    Positioned(
                      top: (hour - startHour) * 60 * minuteHeight,
                      left: 0,
                      right: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: timeWidth,
                            child: Text(
                              hour.isEven || hour == startHour
                                  ? '${hour.toString().padLeft(2, '0')}:00'
                                  : '',
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: colors.outlineVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  for (var day = 0; day <= 7; day++)
                    Positioned(
                      left: timeWidth + day * dayWidth,
                      top: 0,
                      bottom: 0,
                      child: VerticalDivider(
                        width: 1,
                        color: colors.outlineVariant,
                      ),
                    ),
                  if (blocks.isEmpty)
                    const Positioned(
                      top: 30,
                      left: timeWidth + 12,
                      child: Text('本周暂无计划'),
                    ),
                  for (final block in blocks)
                    _buildPlanBlock(
                      context,
                      block: block,
                      blocks: blocks,
                      colors: colors,
                      dayWidth: dayWidth,
                      timeWidth: timeWidth,
                      timelineHeight: timelineHeight,
                      minuteHeight: minuteHeight,
                      startHour: startHour,
                      isCurrentWeek: isCurrentWeek,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanBlock(
    BuildContext context, {
    required WeekPlanBlock block,
    required List<WeekPlanBlock> blocks,
    required ColorScheme colors,
    required double dayWidth,
    required double timeWidth,
    required double timelineHeight,
    required double minuteHeight,
    required int startHour,
    required bool isCurrentWeek,
  }) {
    final location = planLocationFromNote(block.item.note);
    final overlapping =
        blocks
            .where(
              (other) =>
                  other.day == block.day &&
                  other.startMinute < block.endMinute &&
                  other.endMinute > block.startMinute,
            )
            .toList()
          ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final stackOffset = math.min(block.lane, 3) * 2.0;
    final baseOpacity = isCurrentWeek ? 1.0 : 0.52;
    final opacity = block.item.isCompleted ? baseOpacity * 0.62 : baseOpacity;
    final cardColor = _courseColor(colors, block.item.title);
    final top = (block.startMinute - startHour * 60) * minuteHeight;

    return Positioned(
      top: top,
      left: timeWidth + block.day * dayWidth + 2 + stackOffset,
      width: math.max(2, dayWidth - 4 - stackOffset),
      height: math.min(
        timelineHeight - top,
        math.max(20, (block.endMinute - block.startMinute) * minuteHeight - 2),
      ),
      child: Opacity(
        opacity: opacity,
        child: Tooltip(
          message: [
            block.item.title,
            if (location != null) '地点：$location',
            '${LessonPeriod.timeText(block.startMinute.toInt())}–'
                '${LessonPeriod.timeText(block.endMinute.toInt())}',
          ].join('\n'),
          child: Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('week-plan-${block.item.id}-${block.day}'),
              onTap: () => _openOverlappingPlans(
                context,
                selected: block,
                overlapping: overlapping,
                colors: colors,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: LayoutBuilder(
                  builder: (context, space) => Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              block.item.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: dayWidth < 55 ? 9 : 10,
                                height: 1.05,
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (location != null && space.maxHeight > 22)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 9,
                                  color: colors.onSurfaceVariant,
                                ),
                                Expanded(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 8,
                                      height: 1,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (space.maxHeight > 52 && dayWidth > 45)
                            Text(
                              LessonPeriod.timeText(block.startMinute.toInt()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      if (overlapping.length > 1)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${overlapping.length}',
                              style: TextStyle(
                                fontSize: 8,
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openOverlappingPlans(
    BuildContext context, {
    required WeekPlanBlock selected,
    required List<WeekPlanBlock> overlapping,
    required ColorScheme colors,
  }) async {
    if (overlapping.length == 1) {
      onOpen(selected.item);
      return;
    }
    final chosen = await showModalBottomSheet<PlanListItem>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '该时段有 ${overlapping.length} 个计划',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final block in overlapping)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _courseColor(colors, block.item.title),
                  child: const Icon(Icons.event_note_outlined, size: 18),
                ),
                title: Text(block.item.title),
                subtitle: Text(
                  [
                    '${LessonPeriod.timeText(block.startMinute.toInt())}–'
                        '${LessonPeriod.timeText(block.endMinute.toInt())}',
                    ?planLocationFromNote(block.item.note),
                  ].join(' · '),
                ),
                onTap: () => Navigator.pop(sheetContext, block.item),
              ),
          ],
        ),
      ),
    );
    if (chosen != null && context.mounted) onOpen(chosen);
  }

  Color _courseColor(ColorScheme colors, String title) {
    final palette = <Color>[
      colors.primaryContainer,
      Color.lerp(colors.primaryContainer, colors.secondaryContainer, 0.38)!,
      Color.lerp(colors.primaryContainer, colors.secondaryContainer, 0.72)!,
      colors.secondaryContainer,
      Color.lerp(colors.secondaryContainer, colors.tertiaryContainer, 0.38)!,
      Color.lerp(colors.secondaryContainer, colors.tertiaryContainer, 0.72)!,
      colors.tertiaryContainer,
    ];
    final seed = title.runes.fold<int>(
      0,
      (value, rune) => (value * 31 + rune) & 0x7fffffff,
    );
    return palette[seed % palette.length];
  }
}
