import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/course_file_parser.dart';
import '../data/course_import_repository.dart';
import '../data/plans_providers.dart';
import '../domain/course_import.dart';
import '../domain/plan_models.dart';
import 'course_system_web_page.dart';

class PickedCourseFile {
  const PickedCourseFile(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

final courseParserProvider =
    Provider<Future<List<CourseSheet>> Function(Uint8List)>(
      (ref) =>
          (bytes) => compute(CourseFileParser.parse, bytes),
    );

final courseFilePickerProvider = Provider<Future<PickedCourseFile?> Function()>(
  (ref) => () async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );
    if (files.isEmpty) return null;
    return PickedCourseFile(
      files.single.name,
      await files.single.readAsBytes(),
    );
  },
);

final courseSystemBrowserLauncherProvider =
    Provider<Future<bool> Function(Uri)>((ref) {
      return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
    });

typedef CourseSystemReader =
    Future<List<CourseSheet>?> Function(BuildContext context, Uri uri);

final courseSystemReaderProvider = Provider<CourseSystemReader>((ref) {
  return (context, uri) => Navigator.of(context).push<List<CourseSheet>>(
    MaterialPageRoute(builder: (_) => CourseSystemWebPage(initialUri: uri)),
  );
});

class CourseImportPage extends ConsumerStatefulWidget {
  const CourseImportPage({super.key});
  @override
  ConsumerState<CourseImportPage> createState() => _CourseImportPageState();
}

class _CourseImportPageState extends ConsumerState<CourseImportPage> {
  final _courseSystemUrlController = TextEditingController();
  final _scheduleNameController = TextEditingController();
  List<CourseSheet>? _sheets;
  int _sheet = 0;
  String? _fileName, _error;
  DateTime? _monday;
  List<LessonPeriod> _periods = LessonPeriod.exampleTimes();
  bool _busy = false, _timesConfirmed = false, _skipConfirmed = false;
  List<CourseOccurrence>? _occurrences;
  CourseImportPreview? _preview, _result;
  String? _courseSystemUrlError;
  String _sourceType = 'excel';
  bool _createNewSchedule = true;
  int? _selectedScheduleId;
  CourseSheet? get _table => _sheets?[_sheet];

  @override
  void dispose() {
    _courseSystemUrlController.dispose();
    _scheduleNameController.dispose();
    super.dispose();
  }

  String _suggestedScheduleName(
    String sourceType,
    String fileName,
    List<CourseSheet> sheets,
  ) {
    if (sourceType == 'excel') {
      final withoutExtension = fileName.replaceFirst(
        RegExp(r'\.xlsx$', caseSensitive: false),
        '',
      );
      if (withoutExtension.trim().isNotEmpty) {
        final normalized = withoutExtension.trim();
        return normalized.length > 80
            ? normalized.substring(0, 80)
            : normalized;
      }
    }
    final sheetName = sheets.firstOrNull?.name.trim() ?? '';
    return sheetName.isEmpty ? '教务系统课表' : sheetName;
  }

  Uri? _parseCourseSystemUri(String value) {
    final input = value.trim();
    if (input.isEmpty || input.contains(RegExp(r'\s'))) return null;
    final normalized = input.contains('://') ? input : 'https://$input';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }
    return uri;
  }

  Future<void> _openCourseSystem() async {
    FocusScope.of(context).unfocus();
    final uri = _parseCourseSystemUri(_courseSystemUrlController.text);
    if (uri == null) {
      setState(() => _courseSystemUrlError = '请输入正确的 http 或 https 教务系统网址');
      return;
    }
    setState(() => _courseSystemUrlError = null);
    try {
      final opened = await ref.read(courseSystemBrowserLauncherProvider)(uri);
      if (!mounted) return;
      if (!opened) {
        setState(() => _courseSystemUrlError = '无法打开浏览器，请检查网址或浏览器设置');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已打开浏览器；导出 Excel 后请返回本页选择文件')),
      );
    } on Object {
      if (mounted) {
        setState(() => _courseSystemUrlError = '无法打开浏览器，请检查网址或浏览器设置');
      }
    }
  }

  Future<void> _readCourseSystem() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final uri = _parseCourseSystemUri(_courseSystemUrlController.text);
    if (uri == null) {
      setState(() => _courseSystemUrlError = '请输入正确的 http 或 https 教务系统网址');
      return;
    }
    setState(() {
      _courseSystemUrlError = null;
      _busy = true;
    });
    try {
      final sheets = await ref.read(courseSystemReaderProvider)(context, uri);
      if (!mounted || sheets == null) return;
      if (sheets.isEmpty) {
        throw const FormatException('当前页面没有读取到有效课表');
      }
      final primarySheets = <CourseSheet>[sheets.first];
      setState(() {
        _sheets = primarySheets;
        _sheet = 0;
        _fileName = '教务系统网页课表';
        _sourceType = 'web';
        if (_createNewSchedule) {
          _scheduleNameController.text = _suggestedScheduleName(
            'web',
            _fileName!,
            primarySheets,
          );
        }
        _clearPreview();
        _skipConfirmed = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _courseSystemUrlError = '无法进入教务系统：$error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clearPreview() {
    _preview = null;
    _occurrences = null;
    _result = null;
    _error = null;
  }

  Future<void> _pick() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await ref.read(courseFilePickerProvider)();
      if (!mounted || file == null) return;
      setState(() {
        _sheets = null;
        _fileName = null;
        _clearPreview();
        _skipConfirmed = false;
      });
      if (!file.name.toLowerCase().endsWith('.xlsx')) {
        throw const FormatException('仅支持 .xlsx 课程明细表');
      }
      final sheets = await ref.read(courseParserProvider)(file.bytes);
      if (!mounted) return;
      setState(() {
        _sheets = sheets;
        _sheet = 0;
        _fileName = file.name;
        _sourceType = 'excel';
        if (_createNewSchedule) {
          _scheduleNameController.text = _suggestedScheduleName(
            'excel',
            file.name,
            sheets,
          );
        }
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _sheets = null;
          _fileName = null;
          _skipConfirmed = false;
          _clearPreview();
          _error = '课表读取失败：$error';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickMonday() async {
    final now = DateTime.now();
    final chosen = await showDatePicker(
      context: context,
      initialDate:
          _monday ?? DateTime(now.year, now.month, now.day - now.weekday + 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择学期第一周的星期一',
      selectableDayPredicate: (date) => date.weekday == DateTime.monday,
    );
    if (mounted && chosen != null) {
      setState(() {
        _monday = chosen;
        _clearPreview();
      });
    }
  }

  Future<void> _editPeriod(int index, bool start) async {
    final period = _periods[index];
    final minute = start ? period.startMinute : period.endMinute;
    final chosen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    if (mounted && chosen != null) {
      setState(() {
        final value = chosen.hour * 60 + chosen.minute;
        _periods = [..._periods];
        _periods[index] = LessonPeriod(
          period.number,
          start ? value : period.startMinute,
          start ? period.endMinute : value,
        );
        _timesConfirmed = false;
        _clearPreview();
      });
    }
  }

  Future<void> _makePreview() async {
    if (_busy) return;
    setState(() => _error = null);
    if (_table == null ||
        _monday == null ||
        !_timesConfirmed ||
        (_table!.warnings.isNotEmpty && !_skipConfirmed)) {
      setState(() => _error = '请选择课表和第一周周一日期，核对节次时间，并确认未排课行的处理');
      return;
    }
    if (_createNewSchedule && _scheduleNameController.text.trim().isEmpty) {
      setState(() => _error = '请输入新课表名称');
      return;
    }
    if (!_createNewSchedule && _selectedScheduleId == null) {
      setState(() => _error = '请选择要继续使用的旧课表');
      return;
    }
    setState(() => _busy = true);
    try {
      final occurrences = CourseExpansion.expand(_table!, _monday!, _periods);
      final preview = await ref
          .read(courseImportRepositoryProvider)
          .preview(
            occurrences,
            sourceType: _sourceType,
            scheduleId: _createNewSchedule ? null : _selectedScheduleId,
          );
      if (mounted) {
        setState(() {
          _occurrences = occurrences;
          _preview = preview;
          _result = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = '无法生成预览：$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy || _occurrences == null || _preview == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(courseImportRepositoryProvider)
          .importCourses(
            _occurrences!,
            acceptConflicts: true,
            sourceType: _sourceType,
            scheduleId: _createNewSchedule ? null : _selectedScheduleId,
            createNewSchedule: _createNewSchedule,
            scheduleName: _createNewSchedule
                ? _scheduleNameController.text
                : null,
          );
      if (!mounted) return;
      ref.read(selectedPlanDateProvider.notifier).state =
          _occurrences!.first.startsAt;
      ref.read(weeklyPlanViewProvider.notifier).state = true;
      if (result.scheduleId != null) {
        ref.read(selectedCourseScheduleIdProvider.notifier).state =
            result.scheduleId!;
      }
      ref.invalidate(courseSchedulesProvider);
      ref.invalidate(plansForSelectedWeekProvider);
      ref.invalidate(plansForSelectedDateProvider);
      ref.invalidate(planReminderRestoreProvider);
      setState(() {
        _result = result;
        _preview = null;
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = '导入失败，未保存不完整课表：$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final table = _table;
    final schedules = table == null
        ? const <CourseScheduleOption>[]
        : ref
              .watch(courseSchedulesProvider)
              .maybeWhen(
                data: (items) => items,
                orElse: () => const <CourseScheduleOption>[],
              );
    final selectedScheduleExists = schedules.any(
      (item) => item.id == _selectedScheduleId,
    );
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('导入课程表')),
        body: ListView(
          key: const ValueKey('course-import-list'),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '选择 Excel → 核对学期与时间 → 预览 → 确认导入',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '支持逐行课程明细 .xlsx：课程名称、星期、开始节数、结束节数、老师、地点、周数。支持 1-16、3-17单、12-18双、7-10、12、15-17；不是直接读取截图或网格型课表。原文件不会修改。',
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: const ValueKey('course-system-guide'),
                leading: const Icon(Icons.language_outlined),
                title: const Text('从教务系统直接读取'),
                subtitle: const Text('应用内登录，无需下载 Excel'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '1. 输入学校教务系统网址并进入登录。\n'
                      '2. 在教务系统中打开“我的课表”或“课表查询”。\n'
                      '3. 确保完整课表已经显示，再点击“读取当前课表”。',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('course-system-url-field'),
                    controller: _courseSystemUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: '教务系统网址',
                      hintText: 'https://jw.example.edu.cn',
                      errorText: _courseSystemUrlError,
                      prefixIcon: const Icon(Icons.link_outlined),
                    ),
                    onSubmitted: (_) => _openCourseSystem(),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _readCourseSystem,
                      icon: const Icon(Icons.login_outlined),
                      label: const Text('进入教务系统并读取课表'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _openCourseSystem,
                    icon: const Icon(Icons.open_in_browser_outlined),
                    label: const Text('在系统浏览器导出 Excel'),
                  ),
                  const Text(
                    '登录由教务网页处理，Learning Bird 不保存账号和密码；仅在你点击读取时提取当前页面中可见的表格文字。部分使用图片或特殊控件的教务系统可能无法自动识别，仍可使用下方 Excel 导入。',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('或从 Excel 导入'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.file_open_outlined),
              label: const Text('选择课表文件'),
            ),
            if (_fileName != null) Text(_fileName!),
            if (_busy) const LinearProgressIndicator(),
            if (table != null) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '保存到哪张课表',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        key: ValueKey(
                          'course-import-target-${_createNewSchedule ? -1 : _selectedScheduleId}',
                        ),
                        initialValue:
                            !_createNewSchedule && selectedScheduleExists
                            ? _selectedScheduleId
                            : -1,
                        decoration: const InputDecoration(
                          labelText: '新建或使用旧课表',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: -1,
                            child: Text('新建课表'),
                          ),
                          for (final schedule in schedules)
                            DropdownMenuItem(
                              value: schedule.id,
                              child: Text(schedule.name),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (value) {
                                setState(() {
                                  _createNewSchedule = value == -1;
                                  _selectedScheduleId = value == -1
                                      ? null
                                      : value;
                                  _clearPreview();
                                });
                              },
                      ),
                      if (_createNewSchedule) ...[
                        const SizedBox(height: 8),
                        TextField(
                          key: const ValueKey('new-course-schedule-name'),
                          controller: _scheduleNameController,
                          maxLength: 80,
                          decoration: const InputDecoration(
                            labelText: '新课表名称',
                            hintText: '例如：2026 秋季课表',
                          ),
                          onChanged: (_) {
                            if (_preview != null || _result != null) {
                              setState(_clearPreview);
                            }
                          },
                        ),
                      ],
                      const Text(
                        '选择旧课表会把课程追加进去；新建课表与其他课表独立保存、独立去重。',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              if (_sourceType == 'web')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.table_chart_outlined),
                  title: const Text('使用首张有效课表'),
                  subtitle: Text(table.name),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _sheet,
                  decoration: const InputDecoration(labelText: 'Excel页签（工作表）'),
                  items: [
                    for (var i = 0; i < _sheets!.length; i++)
                      DropdownMenuItem(value: i, child: Text(_sheets![i].name)),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _sheet = value;
                              _skipConfirmed = false;
                              _clearPreview();
                            });
                          }
                        },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('学期第一周的星期一'),
                subtitle: Text(
                  _monday == null
                      ? '课表没有日期，必须手动选择'
                      : '${_monday!.year}/${_monday!.month}/${_monday!.day}',
                ),
                trailing: TextButton(
                  key: const ValueKey('pick-course-semester-monday'),
                  onPressed: _busy ? null : _pickMonday,
                  child: const Text('选择日期'),
                ),
              ),
              ExpansionTile(
                title: const Text('每节课的实际时间（务必核对）'),
                subtitle: const Text('以下为示例时间，不代表你学校的作息'),
                children: [
                  for (var i = 0; i < _periods.length; i++)
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text('第 ${_periods[i].number} 节'),
                        ),
                        TextButton(
                          onPressed: _busy ? null : () => _editPeriod(i, true),
                          child: Text(
                            LessonPeriod.timeText(_periods[i].startMinute),
                          ),
                        ),
                        const Text('–'),
                        TextButton(
                          onPressed: _busy ? null : () => _editPeriod(i, false),
                          child: Text(
                            LessonPeriod.timeText(_periods[i].endMinute),
                          ),
                        ),
                      ],
                    ),
                  if (_periods.length < 24)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _periods = [
                                ..._periods,
                                LessonPeriod(_periods.length + 1, 0, 45),
                              ];
                              _timesConfirmed = false;
                              _clearPreview();
                            }),
                      child: const Text('添加节次（需设置时间）'),
                    ),
                ],
              ),
              CheckboxListTile(
                key: const ValueKey('confirm-course-period-times'),
                contentPadding: EdgeInsets.zero,
                title: const Text('已核对节次时间，确认与学校作息一致'),
                value: _timesConfirmed,
                onChanged: _busy
                    ? null
                    : (value) => setState(() {
                        _timesConfirmed = value ?? false;
                        _clearPreview();
                      }),
              ),
              Text(
                '识别 ${table.courses.length} 条可排课记录，${table.warnings.length} 条需补充或修正',
              ),
              if (table.warnings.isNotEmpty) ...[
                for (final warning in table.warnings)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      warning,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                CheckboxListTile(
                  key: const ValueKey('confirm-course-warning-skip'),
                  contentPadding: EdgeInsets.zero,
                  value: _skipConfirmed,
                  title: const Text('确认本次跳过以上记录，补充原表后可再次导入'),
                  onChanged: _busy
                      ? null
                      : (value) => setState(() {
                          _skipConfirmed = value ?? false;
                          _clearPreview();
                        }),
                ),
              ],
              ExpansionTile(
                title: const Text('查看识别的课程与周次'),
                children: [
                  for (final course in table.courses)
                    ListTile(
                      title: Text(course.title),
                      subtitle: Text(
                        '周${course.weekday} · 第${course.startPeriod}–${course.endPeriod}节 · ${course.weekText}周\n${course.teacher} · ${course.location}',
                      ),
                    ),
                ],
              ),
              FilledButton(
                key: const ValueKey('generate-course-import-preview'),
                onPressed: _busy ? null : _makePreview,
                child: const Text('生成导入预览'),
              ),
            ],
            if (_preview != null) ...[
              const Divider(),
              Text(
                '本次读取 ${table!.courses.length} 条课程信息，按周次展开后将新增 ${_preview!.pending.length} 次上课安排；跳过 ${_preview!.skipped} 次已导入或重复安排。',
              ),
              const Text(
                '例如同一门课上 16 周，会生成 16 次上课安排，但仍是一门课程。每次安排保留自己的日期、提醒和完成状态。',
              ),
              if (_preview!.conflicts > 0)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.layers_outlined),
                    title: Text('${_preview!.conflicts} 次时间重叠'),
                    subtitle: const Text('将自动保留，并在周表同一时间格内叠放；点击即可分别查看。'),
                  ),
                ),
              ExpansionTile(
                title: const Text('查看全部具体日期和时间'),
                children: [
                  for (final item in _preview!.pending)
                    ListTile(
                      title: Text(item.course.title),
                      subtitle: Text(
                        '第${item.week}周 · ${item.startsAt.year}/${item.startsAt.month}/${item.startsAt.day}\n${LessonPeriod.timeText(item.startsAt.hour * 60 + item.startsAt.minute)}–${LessonPeriod.timeText(item.endsAt.hour * 60 + item.endsAt.minute)} · ${item.course.location}',
                      ),
                    ),
                ],
              ),
              FilledButton.icon(
                key: const ValueKey('confirm-course-import'),
                onPressed: _busy ? null : _import,
                icon: const Icon(Icons.check),
                label: const Text('确认导入课程'),
              ),
            ],
            if (_result != null) ...[
              Text(
                '导入完成：已保存 ${table!.courses.length} 条课程信息对应的 ${_result!.pending.length} 次上课安排，跳过 ${_result!.skipped} 次重复安排。',
              ),
              FilledButton(
                key: const ValueKey('return-to-weekly-plan'),
                onPressed: () => Navigator.pop(context),
                child: const Text('返回周规划表'),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
