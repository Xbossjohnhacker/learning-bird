import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vocabulary_providers.dart';
import '../../data/word_file_parser.dart';
import '../../domain/word_import.dart';

class WordImportPage extends ConsumerStatefulWidget {
  const WordImportPage({super.key});

  @override
  ConsumerState<WordImportPage> createState() => _WordImportPageState();
}

class _WordImportPageState extends ConsumerState<WordImportPage> {
  TabularWordData? _table;
  ImportFieldMapping? _mapping;
  Uint8List? _bytes;
  String? _fileName;
  int? _bookId;
  DuplicateStrategy _strategy = DuplicateStrategy.skip;
  ImportBatchResult? _result;
  String? _error;
  bool _busy = false;

  Future<void> _pickFile() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx'],
      );
      if (!mounted || picked.isEmpty) return;
      final file = picked.single;
      // A failed replacement must never leave the previous file importable.
      _continueImport();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final table = WordFileParser.parse(bytes: bytes, fileName: file.name);
      final auto = ImportFieldMapping.auto(table.headers);
      setState(() {
        _table = table;
        _bytes = bytes;
        _fileName = file.name;
        _mapping =
            auto ??
            ImportFieldMapping(
              word: table.headers.first,
              meaning: table.headers.length > 1
                  ? table.headers[1]
                  : table.headers.first,
            );
        _result = null;
        _error = null;
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = '文件读取或解析失败：$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  ImportFieldMapping _replaceMapping({
    String? word,
    String? meaning,
    String? phonetic,
    String? example,
  }) {
    final old = _mapping!;
    return ImportFieldMapping(
      word: word ?? old.word,
      meaning: meaning ?? old.meaning,
      phonetic: phonetic == '' ? null : (phonetic ?? old.phonetic),
      example: example == '' ? null : (example ?? old.example),
      exampleTranslation: old.exampleTranslation,
      phrase: old.phrase,
      note: old.note,
      tags: old.tags,
    );
  }

  Future<void> _import() async {
    final table = _table;
    final mapping = _mapping;
    final bytes = _bytes;
    final bookId = _bookId;
    if (table == null ||
        mapping == null ||
        bytes == null ||
        bookId == null ||
        _fileName == null) {
      setState(() => _error = '请先选择词书和文件');
      return;
    }
    if (mapping.word == mapping.meaning) {
      setState(() => _error = '单词和释义不能选择同一列');
      return;
    }
    final mapped = table.mapRows(mapping);
    if (mapped.rows.isEmpty) {
      setState(() => _error = '没有可导入的数据，请检查字段映射');
      return;
    }
    setState(() {
      _busy = true;
      _error = mapped.errors.isEmpty
          ? null
          : '已忽略 ${mapped.errors.length} 行缺少单词或释义的数据';
    });
    try {
      final result = await ref
          .read(vocabularyRepositoryProvider)
          .importRows(
            wordBookId: bookId,
            fileName: _fileName!,
            sourceType: _fileName!.toLowerCase().endsWith('.csv')
                ? 'csv'
                : 'xlsx',
            sourceFingerprint: sha256.convert(bytes).toString(),
            rows: mapped.rows,
            duplicateStrategy: _strategy,
          );
      if (!mounted) return;
      ref.invalidate(wordBooksProvider);
      setState(() => _result = result);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '导入失败：$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _continueImport() {
    setState(() {
      _table = null;
      _mapping = null;
      _bytes = null;
      _fileName = null;
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(wordBooksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('导入单词')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('可重复导入', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('每次选择文件都会建立独立批次；同一文件也可以再次导入。'),
          const SizedBox(height: 20),
          books.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('词书加载失败：$error'),
            data: (items) {
              if (items.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('请先返回“我的单词”新建一个词书。'),
                  ),
                );
              }
              final selected = items.any((item) => item.id == _bookId)
                  ? _bookId
                  : items.first.id;
              _bookId = selected;
              return DropdownButtonFormField<int>(
                initialValue: selected,
                decoration: const InputDecoration(
                  labelText: '导入到词书',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final item in items)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) => setState(() => _bookId = value),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFormatGuide(context),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(_fileName ?? '选择 CSV 或 Excel 文件'),
          ),
          if (_table != null && _mapping != null) ...[
            const SizedBox(height: 20),
            Text('字段映射', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _mappingDropdown(
              label: '单词（必填）',
              value: _mapping!.word,
              onChanged: (value) =>
                  setState(() => _mapping = _replaceMapping(word: value)),
            ),
            const SizedBox(height: 12),
            _mappingDropdown(
              label: '释义（必填）',
              value: _mapping!.meaning,
              onChanged: (value) =>
                  setState(() => _mapping = _replaceMapping(meaning: value)),
            ),
            const SizedBox(height: 12),
            if (_table!.headers.length > 2)
              ExpansionTile(
                title: const Text('更多字段（可选）'),
                children: [
                  _mappingDropdown(
                    label: '音标（可选）',
                    value: _mapping!.phonetic,
                    optional: true,
                    onChanged: (value) => setState(
                      () => _mapping = _replaceMapping(phonetic: value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _mappingDropdown(
                    label: '例句（可选）',
                    value: _mapping!.example,
                    optional: true,
                    onChanged: (value) => setState(
                      () => _mapping = _replaceMapping(example: value),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<DuplicateStrategy>(
              initialValue: _strategy,
              decoration: const InputDecoration(
                labelText: '遇到重复单词',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final strategy in DuplicateStrategy.values)
                  DropdownMenuItem(
                    value: strategy,
                    child: Text(strategy.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _strategy = value ?? _strategy),
            ),
            const SizedBox(height: 20),
            Text('前 5 行预览', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('单词')),
                    DataColumn(label: Text('意思')),
                  ],
                  rows: [
                    for (final row in _table!.mapRows(_mapping!).rows.take(5))
                      DataRow(
                        cells: [
                          DataCell(Text(row.word)),
                          DataCell(Text(row.meaning)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_result == null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy || _table == null ? null : _import,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: const Text('开始导入'),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本批次导入完成',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '成功 ${_result!.successCount} · 跳过 ${_result!.skippedCount} · 失败 ${_result!.failedCount}',
                    ),
                    const SizedBox(height: 4),
                    Text('批次号：${_result!.batchUuid}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _continueImport,
              icon: const Icon(Icons.add),
              label: const Text('继续导入下一批'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormatGuide(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.info_outline),
        title: const Text('Excel / CSV 格式要求'),
        subtitle: const Text('只需要两列：单词、意思'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• 支持 .xlsx 和 .csv，不支持旧版 .xls。'),
          const SizedBox(height: 6),
          const Text('• Excel 读取第一个工作表；不要合并单元格。'),
          const SizedBox(height: 6),
          const Text('• CSV 请保存为 UTF-8 编码；表头不可留空或重复。'),
          const SizedBox(height: 6),
          const Text('• 每行填写一个单词，单词或释义为空的行会被跳过。'),
          const SizedBox(height: 6),
          const Text('• 第一行填写“单词”和“意思”，从第二行开始填词汇。'),
          const SizedBox(height: 12),
          Text('格式示例', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('单词')),
                DataColumn(label: Text('意思')),
              ],
              rows: [
                DataRow(
                  cells: [DataCell(Text('persist')), DataCell(Text('坚持'))],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('也支持英文表头 word、meaning；不需要音标和例句。'),
        ],
      ),
    );
  }

  Widget _mappingDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool optional = false,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$value'),
      initialValue: value ?? '',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        if (optional)
          const DropdownMenuItem<String>(value: '', child: Text('不导入')),
        for (final header in _table!.headers)
          DropdownMenuItem(value: header, child: Text(header)),
      ],
      onChanged: onChanged,
    );
  }
}
