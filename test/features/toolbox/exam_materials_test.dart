import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bird/features/toolbox/data/exam_materials_repository.dart';
import 'package:learning_bird/features/toolbox/data/toolbox_providers.dart';
import 'package:learning_bird/features/toolbox/presentation/exam_materials_page.dart';
import 'package:learning_bird/features/toolbox/presentation/exam_text_reader_page.dart';

class _MemoryExamMaterialsRepository extends ExamMaterialsRepository {
  _MemoryExamMaterialsRepository()
    : super(directoryProvider: () async => Directory.systemTemp);
  final materials = <ExamMaterial>[];

  @override
  Future<List<ExamMaterial>> listMaterials() async => List.of(materials);

  @override
  Future<ImportFolderResult> importDirectory(String sourcePath) async {
    final modifiedAt = DateTime(2026, 9, 2);
    materials.addAll([
      ExamMaterial(
        name: '数学基础.mp4',
        path: 'memory/数学考研/视频/数学基础.mp4',
        relativePath: '数学考研/视频/数学基础.mp4',
        sizeBytes: 3,
        modifiedAt: modifiedAt,
        kind: ExamMaterialKind.video,
      ),
      ExamMaterial(
        name: '复习说明.txt',
        path: 'memory/数学考研/复习说明.txt',
        relativePath: '数学考研/复习说明.txt',
        sizeBytes: 18,
        modifiedAt: modifiedAt,
        kind: ExamMaterialKind.text,
      ),
      ExamMaterial(
        name: '讲义.pdf',
        path: 'memory/数学考研/讲义.pdf',
        relativePath: '数学考研/讲义.pdf',
        sizeBytes: 30,
        modifiedAt: modifiedAt,
        kind: ExamMaterialKind.other,
      ),
    ]);
    return const ImportFolderResult(folderName: '数学考研', fileCount: 3);
  }

  @override
  Future<void> deleteMaterial(ExamMaterial material) async {
    materials.removeWhere((item) => item.path == material.path);
  }

  @override
  Future<String> readText(ExamMaterial material) async => '第一章 高等数学';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late ExamMaterialsRepository repository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('learning_bird_materials_');
    repository = ExamMaterialsRepository(directoryProvider: () async => root);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('导入资料文件夹会保留层级、识别类型并保留原文件', () async {
    final source = await Directory.systemTemp.createTemp(
      'learning_bird_material_source_',
    );
    addTearDown(() async {
      if (await source.exists()) await source.delete(recursive: true);
    });
    final videos = await Directory(
      '${source.path}${Platform.pathSeparator}视频',
    ).create();
    final notes = await Directory(
      '${source.path}${Platform.pathSeparator}笔记',
    ).create();
    final video = File('${videos.path}${Platform.pathSeparator}课程.mp4');
    final sourceText = File('${notes.path}${Platform.pathSeparator}说明.txt');
    final pdf = File('${source.path}${Platform.pathSeparator}讲义.pdf');
    await video.writeAsBytes([0, 1, 2, 3]);
    await sourceText.writeAsString('复习说明');
    await pdf.writeAsBytes([4, 5, 6]);

    final first = await repository.importDirectory(source.path);
    final second = await repository.importDirectory(source.path);
    expect(first.fileCount, 3);
    expect(second.fileCount, 3);
    expect(second.folderName, '${first.folderName} (2)');

    final materials = await repository.listMaterials();
    expect(materials, hasLength(6));
    final importedText = materials.firstWhere(
      (item) => item.relativePath.endsWith('笔记${Platform.pathSeparator}说明.txt'),
    );
    expect(importedText.kind, ExamMaterialKind.text);
    expect(await repository.readText(importedText), '复习说明');
    expect(
      materials.where((item) => item.kind == ExamMaterialKind.video),
      hasLength(2),
    );
    expect(
      materials.where((item) => item.kind == ExamMaterialKind.other),
      hasLength(2),
    );
    await repository.deleteMaterial(importedText);
    expect(await File(importedText.path).exists(), isFalse);
    expect(await sourceText.exists(), isTrue);
  });

  test('空文件夹和资料库自身不能被导入', () async {
    final empty = await Directory.systemTemp.createTemp(
      'learning_bird_empty_materials_',
    );
    addTearDown(() async {
      if (await empty.exists()) await empty.delete(recursive: true);
    });
    expect(
      repository.importDirectory(empty.path),
      throwsA(isA<FormatException>()),
    );
    expect(
      repository.importDirectory(root.path),
      throwsA(isA<FormatException>()),
    );
  });

  testWidgets('考研资料页面可导入文件夹、列出多种文件并确认删除', (tester) async {
    final memoryRepository = _MemoryExamMaterialsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examMaterialsRepositoryProvider.overrideWithValue(memoryRepository),
          examFolderPickerProvider.overrideWithValue(
            () async => const PickedExamFolder(path: 'memory/source'),
          ),
        ],
        child: const MaterialApp(home: ExamMaterialsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('还没有考研资料'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('import-exam-folder')));
    await tester.pumpAndSettle();
    expect(find.text('数学基础.mp4'), findsOneWidget);
    expect(find.text('复习说明.txt'), findsOneWidget);
    expect(find.text('讲义.pdf'), findsOneWidget);
    expect(find.byTooltip('删除资料'), findsNWidgets(3));
    await tester.tap(find.byTooltip('删除资料').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('此操作只删除应用内保存的副本'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(memoryRepository.materials, hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('文本资料可在应用内阅读和选择', (tester) async {
    final memoryRepository = _MemoryExamMaterialsRepository();
    final material = ExamMaterial(
      name: '复习说明.txt',
      path: 'memory/复习说明.txt',
      relativePath: '数学考研/复习说明.txt',
      sizeBytes: 18,
      modifiedAt: DateTime(2026, 9, 2),
      kind: ExamMaterialKind.text,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examMaterialsRepositoryProvider.overrideWithValue(memoryRepository),
        ],
        child: MaterialApp(home: ExamTextReaderPage(material: material)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('第一章 高等数学'), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
