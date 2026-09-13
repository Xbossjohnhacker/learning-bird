import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: const [
          Text(
            'Learning Bird 隐私政策',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('生效日期：2026 年 9 月 6 日 · 适用版本：1.0.0-rc.3'),
          SizedBox(height: 22),
          _PolicySection(
            title: '本地保存的数据',
            body:
                '词书、单词、学习进度、计划、课表、番茄钟记录、设置以及你选择导入的资料保存在设备本地。应用不要求注册账号，不设置广告或分析服务，也不主动把这些数据上传到服务器。',
          ),
          _PolicySection(
            title: '文件与备份',
            body:
                '只有在你主动选择文件、文件夹、导出位置或备份文件时，应用才会读取或写入相应内容。数据备份由你保存到所选位置，备份文件未加密；资料文件不包含在 JSON 数据备份中。',
          ),
          _PolicySection(
            title: '通知与后台提醒',
            body:
                '应用使用通知、精确闹钟和开机完成能力来显示计划及番茄钟提醒，并在设备重启后恢复尚未到期的提醒。这些能力只用于你创建或启动的提醒。',
          ),
          _PolicySection(
            title: '关联其他应用',
            body:
                '当你选择为计划关联应用时，Learning Bird 会读取设备上具有桌面入口、可直接启动的应用名称、图标和包名。所选应用的名称与包名会随计划保存在本地，用于显示图标和点击跳转；应用列表不会上传或用于画像、广告。',
          ),
          _PolicySection(
            title: '第三方内容',
            body: '预置词书来自 ECDICT 的固定开源版本，随应用附带相应许可说明。应用不会因打开关联应用而向该应用发送你的学习记录。',
          ),
          _PolicySection(
            title: '管理和删除',
            body:
                '你可以在应用中删除词书、单词和计划，或从备份恢复数据。卸载应用会删除其设备本地数据；卸载前请先导出备份，并另行保留已导入资料的原文件。',
          ),
          _PolicySection(
            title: '联系我们',
            body: '隐私问题和数据请求请通过公开下载页或应用商店详情页中公布的开发者联系方式提出。',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
