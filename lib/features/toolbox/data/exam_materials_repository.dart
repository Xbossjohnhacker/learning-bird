import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ExamVideo {
  const ExamVideo({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final DateTime modifiedAt;
}

enum ExamMaterialKind { video, text, other }

class ExamMaterial {
  const ExamMaterial({
    required this.name,
    required this.path,
    required this.relativePath,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.kind,
  });

  final String name;
  final String path;
  final String relativePath;
  final int sizeBytes;
  final DateTime modifiedAt;
  final ExamMaterialKind kind;
}

class ImportFolderResult {
  const ImportFolderResult({required this.folderName, required this.fileCount});
  final String folderName;
  final int fileCount;
}

class ExamMaterialsRepository {
  ExamMaterialsRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _defaultDirectory;

  final Future<Directory> Function() _directoryProvider;
  static const videoExtensions = {'mp4', 'mov', 'm4v', 'webm'};
  static const textExtensions = {'txt', 'md', 'markdown', 'csv', 'log', 'srt'};
  static const supportedExtensions = videoExtensions;

  static Future<Directory> _defaultDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'exam_materials'));
  }

  Future<Directory> _ensureDirectory() async {
    final directory = await _directoryProvider();
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  Future<List<ExamVideo>> listVideos() async {
    final directory = await _ensureDirectory();
    final videos = <ExamVideo>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final extension = p
          .extension(entity.path)
          .replaceFirst('.', '')
          .toLowerCase();
      if (!supportedExtensions.contains(extension)) continue;
      final stat = await entity.stat();
      videos.add(
        ExamVideo(
          name: p.basename(entity.path),
          path: entity.path,
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
        ),
      );
    }
    videos.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return videos;
  }

  Future<List<ExamMaterial>> listMaterials() async {
    final directory = await _ensureDirectory();
    final materials = <ExamMaterial>[];
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      materials.add(
        ExamMaterial(
          name: p.basename(entity.path),
          path: entity.path,
          relativePath: p.relative(entity.path, from: directory.path),
          sizeBytes: stat.size,
          modifiedAt: stat.modified,
          kind: _kindFor(entity.path),
        ),
      );
    }
    materials.sort((a, b) {
      final folder = p
          .dirname(a.relativePath)
          .compareTo(p.dirname(b.relativePath));
      return folder != 0
          ? folder
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return materials;
  }

  Future<ImportFolderResult> importDirectory(String sourcePath) async {
    final source = Directory(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('选择的文件夹已不可访问');
    }
    final root = await _ensureDirectory();
    final sourceAbsolute = p.normalize(p.absolute(source.path));
    final rootAbsolute = p.normalize(p.absolute(root.path));
    if (p.equals(sourceAbsolute, rootAbsolute) ||
        p.isWithin(sourceAbsolute, rootAbsolute) ||
        p.isWithin(rootAbsolute, sourceAbsolute)) {
      throw const FormatException('不能导入应用资料目录本身或其上级目录');
    }

    final safeName = _safeName(p.basename(sourceAbsolute), fallback: '考研资料');
    var folderName = safeName;
    var target = Directory(p.join(root.path, folderName));
    var suffix = 2;
    while (await target.exists()) {
      folderName = '$safeName ($suffix)';
      target = Directory(p.join(root.path, folderName));
      suffix++;
    }

    var count = 0;
    await target.create(recursive: true);
    try {
      await for (final entity in source.list(
        recursive: true,
        followLinks: false,
      )) {
        final relative = p.relative(entity.path, from: source.path);
        final destination = p.join(target.path, relative);
        if (entity is Directory) {
          await Directory(destination).create(recursive: true);
        } else if (entity is File) {
          await Directory(p.dirname(destination)).create(recursive: true);
          await entity.copy(destination);
          count++;
        }
      }
    } on Object {
      if (await target.exists()) await target.delete(recursive: true);
      rethrow;
    }
    if (count == 0) {
      await target.delete(recursive: true);
      throw const FormatException('所选文件夹中没有文件');
    }
    return ImportFolderResult(folderName: folderName, fileCount: count);
  }

  Future<String> readText(ExamMaterial material) async {
    if (material.kind != ExamMaterialKind.text) {
      throw const FormatException('该文件不是可阅读的文本资料');
    }
    if (material.sizeBytes > 5 * 1024 * 1024) {
      throw const FormatException('文本超过 5 MB，请使用其他阅读工具打开');
    }
    return File(material.path).readAsString();
  }

  Future<void> deleteMaterial(ExamMaterial material) async {
    final root = await _ensureDirectory();
    final rootAbsolute = p.normalize(p.absolute(root.path));
    final targetAbsolute = p.normalize(p.absolute(material.path));
    if (!p.isWithin(rootAbsolute, targetAbsolute)) {
      throw const FileSystemException('拒绝删除资料目录之外的文件');
    }
    final target = File(targetAbsolute);
    if (await target.exists()) await target.delete();
  }

  ExamMaterialKind _kindFor(String filePath) {
    final extension = p.extension(filePath).replaceFirst('.', '').toLowerCase();
    if (videoExtensions.contains(extension)) return ExamMaterialKind.video;
    if (textExtensions.contains(extension)) return ExamMaterialKind.text;
    return ExamMaterialKind.other;
  }

  String _safeName(String value, {required String fallback}) {
    final safe = value.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_').trim();
    return safe.isEmpty ? fallback : safe;
  }

  Future<ExamVideo> importVideo({
    required String sourcePath,
    required String originalName,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) throw const FileSystemException('选择的视频已不可访问');
    final extension = p
        .extension(originalName)
        .replaceFirst('.', '')
        .toLowerCase();
    if (!supportedExtensions.contains(extension)) {
      throw const FormatException('仅支持 MP4、MOV、M4V 或 WebM 视频');
    }
    final directory = await _ensureDirectory();
    final stem = _safeName(
      p.basenameWithoutExtension(originalName),
      fallback: '考研视频',
    );
    var name = '$stem.$extension';
    var target = File(p.join(directory.path, name));
    var suffix = 2;
    while (await target.exists()) {
      name = '$stem ($suffix).$extension';
      target = File(p.join(directory.path, name));
      suffix++;
    }
    await source.copy(target.path);
    final stat = await target.stat();
    return ExamVideo(
      name: name,
      path: target.path,
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
    );
  }

  Future<void> deleteVideo(ExamVideo video) async {
    final directory = await _ensureDirectory();
    final target = File(p.join(directory.path, p.basename(video.path)));
    if (await target.exists()) await target.delete();
  }
}
