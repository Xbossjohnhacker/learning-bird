import 'package:flutter/material.dart';

import '../../../core/widgets/module_page.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      eyebrow: 'VOCABULARY',
      title: '我的单词',
      description: '数据库结构已就绪，第三阶段将在这里接入导入、学习和复习闭环。',
      icon: Icons.translate,
      primaryAction: '导入单词',
      items: [
        ModuleItem(
          title: '考研核心词',
          subtitle: '1,238 词 · 今日待复习 42',
          icon: Icons.menu_book_outlined,
        ),
        ModuleItem(
          title: '重复导入记录',
          subtitle: '支持多个独立批次与重复词处理',
          icon: Icons.history,
        ),
      ],
    );
  }
}
