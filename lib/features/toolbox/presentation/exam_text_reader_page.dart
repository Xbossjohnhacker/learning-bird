import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exam_materials_repository.dart';
import '../data/toolbox_providers.dart';

class ExamTextReaderPage extends ConsumerWidget {
  const ExamTextReaderPage({required this.material, super.key});
  final ExamMaterial material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(material.name)),
      body: FutureBuilder<String>(
        future: ref.read(examMaterialsRepositoryProvider).readText(material),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '文本无法读取：${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SelectionArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  snapshot.data ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.65),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
