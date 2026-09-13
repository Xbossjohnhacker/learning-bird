import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/exam_materials_repository.dart';
import '../data/toolbox_providers.dart';

class ExamMaterialsPage extends ConsumerStatefulWidget {
  const ExamMaterialsPage({super.key});

  @override
  ConsumerState<ExamMaterialsPage> createState() => _ExamMaterialsPageState();
}

class _ExamMaterialsPageState extends ConsumerState<ExamMaterialsPage> {
  bool _importing = false;

  Future<void> _importFolder() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final picked = await ref.read(examFolderPickerProvider)();
      if (picked == null) return;
      final result = await ref
          .read(examMaterialsRepositoryProvider)
          .importDirectory(picked.path);
      ref.invalidate(examMaterialsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导入“${result.folderName}”，共 ${result.fileCount} 个文件'),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('文件夹导入失败：$error')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _deleteMaterial(ExamMaterial material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除资料'),
        content: Text('确定从考研资料中删除“${material.name}”吗？\n此操作只删除应用内保存的副本。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(examMaterialsRepositoryProvider).deleteMaterial(material);
      ref.invalidate(examMaterialsProvider);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败：$error')));
    }
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  IconData _iconFor(ExamMaterialKind kind) => switch (kind) {
    ExamMaterialKind.video => Icons.play_arrow_rounded,
    ExamMaterialKind.text => Icons.description_outlined,
    ExamMaterialKind.other => Icons.insert_drive_file_outlined,
  };

  void _openMaterial(ExamMaterial material) {
    switch (material.kind) {
      case ExamMaterialKind.video:
        context.push('/tools/materials/video', extra: material);
      case ExamMaterialKind.text:
        context.push('/tools/materials/text', extra: material);
      case ExamMaterialKind.other:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('该文件已保存，当前版本暂不支持应用内预览')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final materials = ref.watch(examMaterialsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('考研资料')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'exam-materials-import-fab',
        key: const ValueKey('import-exam-folder'),
        onPressed: _importing ? null : _importFolder,
        icon: _importing
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.create_new_folder_outlined),
        label: Text(_importing ? '正在导入' : '导入文件夹'),
      ),
      body: materials.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(examMaterialsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
          ),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyMaterials()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final material = items[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      key: ValueKey('exam-material-${material.path}'),
                      contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                      leading: CircleAvatar(
                        child: Icon(_iconFor(material.kind)),
                      ),
                      title: Text(
                        material.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${material.relativePath}\n${_formatSize(material.sizeBytes)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openMaterial(material),
                      trailing: IconButton(
                        tooltip: '删除资料',
                        onPressed: () => _deleteMaterial(material),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyMaterials extends StatelessWidget {
  const _EmptyMaterials();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('还没有考研资料', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('点击“导入文件夹”，视频、文本和其他文件会一起保存。', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('文件夹层级会保留，原文件不会被移动或删除。', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            '资料文件不包含在 JSON 数据备份中，卸载应用前请保留原文件。',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
