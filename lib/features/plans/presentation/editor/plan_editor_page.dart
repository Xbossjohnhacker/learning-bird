import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/plan_notification_service.dart';
import '../../../../core/apps/installed_app_service.dart';
import '../../../vocabulary/data/vocabulary_providers.dart';
import '../../data/plans_providers.dart';
import '../../domain/plan_models.dart';
import 'linked_app_picker.dart';

class PlanEditorPage extends ConsumerStatefulWidget {
  const PlanEditorPage({required this.initialDate, super.key});

  final DateTime initialDate;

  @override
  ConsumerState<PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends ConsumerState<PlanEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _estimatedMinutesController = TextEditingController(text: '25');
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  int _priority = 1;
  int _targetPomodoros = 1;
  PlanRepeat _repeat = PlanRepeat.none;
  int? _reminderOffset = 10;
  int? _categoryId;
  int? _wordBookId;
  LaunchableApp? _linkedApp;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (mounted && picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (mounted && picked != null) setState(() => _time = picked);
  }

  Future<void> _addCategory() async {
    var draftName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建分类'),
        content: TextField(
          maxLength: 40,
          onChanged: (value) => draftName = value,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如：英语、数学、政治'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftName.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.isEmpty) return;
    final id = await ref.read(plansRepositoryProvider).createCategory(name);
    if (!mounted) return;
    ref.invalidate(categoriesProvider);
    if (mounted) setState(() => _categoryId = id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final startsAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    try {
      final result = await ref
          .read(plansRepositoryProvider)
          .createPlan(
            PlanDraft(
              title: _title.text,
              note: _note.text,
              startsAt: startsAt,
              estimatedMinutes: int.parse(
                _estimatedMinutesController.text.trim(),
              ),
              priority: _priority,
              targetPomodoros: _targetPomodoros,
              repeat: _repeat,
              categoryId: _categoryId,
              wordBookId: _wordBookId,
              reminderOffsetMinutes: _reminderOffset,
              linkedAppPackage: _linkedApp?.packageName,
              linkedAppName: _linkedApp?.label,
            ),
          );
      final reminderAt = result.reminderAt;
      final notificationId = result.notificationId;
      if (reminderAt != null && notificationId != null) {
        final notifications = ref.read(planNotificationServiceProvider);
        final granted = await notifications.requestPermission();
        if (granted) {
          await notifications.schedule(
            id: notificationId,
            title: result.title,
            triggerAt: reminderAt,
          );
        }
      }
      ref.read(selectedPlanDateProvider.notifier).state = _date;
      if (mounted) context.pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final wordBooks = ref.watch(wordBooksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('创建学习计划')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: '计划标题',
                hintText: '例如：完成英语阅读真题',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? '请输入计划标题' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_formatDate(_date)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('plan-estimated-minutes'),
                    controller: _estimatedMinutesController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: '预计时长',
                      hintText: '例如 90',
                      suffixText: '分钟',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final minutes = int.tryParse(value?.trim() ?? '');
                      if (minutes == null) return '请输入预计时长';
                      if (minutes < 1 || minutes > 1440) {
                        return '请输入 1–1440 分钟';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _targetPomodoros,
                    decoration: const InputDecoration(
                      labelText: '目标番茄',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var count = 1; count <= 8; count++)
                        DropdownMenuItem(value: count, child: Text('$count 个')),
                    ],
                    onChanged: (value) =>
                        setState(() => _targetPomodoros = value ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('优先级', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('低')),
                ButtonSegment(value: 1, label: Text('普通')),
                ButtonSegment(value: 2, label: Text('高')),
              ],
              selected: {_priority},
              onSelectionChanged: (value) =>
                  setState(() => _priority = value.first),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '重复规则',
                border: OutlineInputBorder(),
                helperText: '再次点击已选中的规则可取消重复',
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final repeat in PlanRepeat.values)
                    ChoiceChip(
                      key: ValueKey('plan-repeat-${repeat.name}'),
                      label: Text(repeat.label),
                      selected: _repeat == repeat,
                      onSelected: (selected) {
                        setState(() {
                          _repeat = selected ? repeat : PlanRepeat.none;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _reminderOffset,
              decoration: const InputDecoration(
                labelText: '提醒',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('不提醒')),
                DropdownMenuItem(value: 0, child: Text('开始时提醒')),
                DropdownMenuItem(value: 5, child: Text('提前 5 分钟')),
                DropdownMenuItem(value: 10, child: Text('提前 10 分钟')),
                DropdownMenuItem(value: 30, child: Text('提前 30 分钟')),
              ],
              onChanged: (value) => setState(() => _reminderOffset = value),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: categories.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => Text('分类加载失败：$error'),
                    data: (items) => DropdownButtonFormField<int?>(
                      key: ValueKey(_categoryId),
                      initialValue: items.any((item) => item.id == _categoryId)
                          ? _categoryId
                          : null,
                      decoration: const InputDecoration(
                        labelText: '分类（可选）',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('未分类')),
                        for (final item in items)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => _categoryId = value),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: '新建分类',
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            wordBooks.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('词书加载失败：$error'),
              data: (items) => DropdownButtonFormField<int?>(
                initialValue: _wordBookId,
                decoration: const InputDecoration(
                  labelText: '关联词书（可选）',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('不关联')),
                  for (final item in items)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) => setState(() => _wordBookId = value),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const ValueKey('linked-app-selector'),
              onPressed: _pickLinkedApp,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
              child: Row(
                children: [
                  if (_linkedApp == null)
                    const Icon(Icons.apps_outlined, size: 32)
                  else
                    LinkedAppIcon(
                      packageName: _linkedApp!.packageName,
                      size: 32,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('关联应用（可选）'),
                        Text(
                          _linkedApp?.label ?? '点击选择，例如 Keep',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_linkedApp != null)
                    IconButton(
                      tooltip: '取消关联',
                      onPressed: () => setState(() => _linkedApp = null),
                      icon: const Icon(Icons.close),
                    )
                  else
                    const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('保存计划'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.month}月${value.day}日';
  }

  Future<void> _pickLinkedApp() async {
    final selected = await showModalBottomSheet<LaunchableApp>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const LinkedAppPicker(),
    );
    if (mounted && selected != null) setState(() => _linkedApp = selected);
  }
}
