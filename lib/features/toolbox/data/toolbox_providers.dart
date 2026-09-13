import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exam_materials_repository.dart';

class PickedExamFolder {
  const PickedExamFolder({required this.path});
  final String path;
}

final examMaterialsRepositoryProvider = Provider<ExamMaterialsRepository>((
  ref,
) {
  return ExamMaterialsRepository();
});

final examMaterialsProvider = FutureProvider.autoDispose<List<ExamMaterial>>((
  ref,
) {
  return ref.watch(examMaterialsRepositoryProvider).listMaterials();
});

final examFolderPickerProvider = Provider<Future<PickedExamFolder?> Function()>(
  (ref) {
    return () async {
      final path = await FilePicker.getDirectoryPath(dialogTitle: '选择考研资料文件夹');
      if (path == null) return null;
      if (path.isEmpty) throw const FileSystemException('无法读取所选文件夹路径');
      return PickedExamFolder(path: path);
    };
  },
);
