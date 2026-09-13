# Learning Bird

完全离线的考研学习管理应用。当前版本为 **1.0.0+19**，覆盖计划、课表、单词、番茄钟和本地资料管理。学习数据只保存在设备本地。

> Android 正式安装包使用项目所有者的独立发布密钥签名。国内网络可从 [GitCode](https://gitcode.com/2403_87724616/learning-bird/releases) 下载，GitHub 用户可从 [GitHub Releases](https://github.com/Xbossjohnhacker/learning-bird/releases) 下载。调试签名包不会作为正式版公开。

![Learning Bird 品牌总览](release-assets/marketing/learning-bird-overview.png)

## 1.0 发布入口

- [使用说明](docs/USER_GUIDE.md)
- [Excel 导入模板](docs/templates/word-import-template.xlsx)：只填写“单词”和“意思”两列。
- [版本记录](docs/CHANGELOG.md)
- [发布签名与真机验收清单](docs/RELEASE_CHECKLIST.md)
- [隐私政策](docs/PRIVACY_POLICY.md)
- [应用商店文案与素材清单](docs/STORE_LISTING.md)
- [M8 交付及验证记录](docs/STAGE_8_DELIVERY.md)

Release 构建默认要求自有签名；未配置时会安全停止。内部测试签名入口见发布清单，不要把测试 APK 当作正式版分发。

## 安装

1. 国内网络直接下载 [GitCode 正式 APK](https://gitcode.com/2403_87724616/learning-bird/releases/download/v1.0.0/learning-bird-1.0.0-build19.apk)，也可以使用 [GitHub Releases](https://github.com/Xbossjohnhacker/learning-bird/releases)。
2. 核对发布说明或同目录 SHA-256 文件中的摘要。
3. 在 Android 8.0（API 26）或更高版本设备上允许浏览器或文件管理器“安装未知应用”，再打开 APK。

目前不提供 iOS 安装包。首次安装后，通知、精确闹钟和全屏提醒等能力会按功能需要在应用内引导授权；不同厂商还可能需要允许后台运行和关闭电池优化。

## 界面预览

| 今日 | 单词本 | 周计划 |
| --- | --- | --- |
| ![今日页面](release-assets/screenshots/01-today.png) | ![单词本页面](release-assets/screenshots/02-word-books.png) | ![周计划页面](release-assets/screenshots/04-week-plan.png) |

## 功能介绍图

| 计划与课表 | 背词与专注 |
| --- | --- |
| ![计划与课表介绍图](release-assets/marketing/learning-bird-plan-timetable.png) | ![背词与专注介绍图](release-assets/marketing/learning-bird-vocabulary-focus.png) |

## 当前能力

- Flutter Material 3 浅色/深色主题。
- Riverpod 状态管理与依赖注入。
- GoRouter 五个一级入口及独立设置页。
- Drift + SQLite Schema v2，支持从旧版本平滑升级。
- Android 8.0（API 26）及以上。
- CSV/Excel 多批次重复导入、字段映射与预览。
- 支持从教务系统网页读取课表，保留 Excel 导入；多个课表分开存储、切换、删除，并与计划叠加显示。
- 课程名、节次、上课周次、地点和教师拆分，冲突课程在周表中叠放查看。
- 词书管理和重复单词跳过/覆盖策略。
- 考研、四级、六级预置离线词书，一键添加且保留已有释义及进度（当前源码新增，[来源与词数](docs/BUILTIN_WORD_BOOKS.md)）。
- 单词学习卡片（当前源码已移除朗读按钮与调用）。
- 每本词书独立设置每日学习目标，按当天通过词数计数，达标后可继续学习（当前源码新增）。
- “认识 / 不认识”两档反馈、复习间隔计算和复习记录（保留旧四档历史数据）。
- 今日首页聚合计划、单词复习和番茄专注数据。
- 课程表式周规划、日列表切换，以及课程明细 Excel 的单双周/分段周次导入（[使用说明](docs/COURSE_IMPORT.md)）。
- 支持按日、周、月查看专注、计划和单词统计图表。
- 支持带完整性校验的全量 JSON 备份与事务恢复。
- 设置页可查看并申请系统通知权限。
- 已通过一万条单词与复习计划压力测试。
- Android 正式 Release 安装包已使用项目所有者的独立密钥签名并通过校验。

## 隐私与许可

- 无账号、无广告分析，计划、课表、单词进度和资料索引均保存在设备本地。
- 隐私说明见 [隐私政策](docs/PRIVACY_POLICY.md)。
- 预置词书数据来自 ECDICT 固定版本，来源与 MIT 许可见 [预置词书说明](docs/BUILTIN_WORD_BOOKS.md) 和 `assets/wordbooks/ECDICT-LICENSE.txt`。
- 本仓库目前没有为 Learning Bird 自有代码授予开源许可证；未经许可不得复制、修改或再分发项目代码。

## 目录

~~~text
lib/
├── app/
│   ├── router/       路由与底部导航
│   └── theme/        Material 3 主题
├── core/
│   ├── database/     Drift Schema、连接与 Provider
│   └── widgets/      共享界面组件
└── features/
    ├── dashboard/    今日
    ├── vocabulary/   单词
    ├── plans/        计划
    ├── pomodoro/     番茄钟
    └── settings/     设置
~~~

## 数据库代码生成

本机 AOT 临时快照在中文路径下可能丢失，使用 JIT 生成：

~~~powershell
dart run build_runner build --force-jit
~~~

## 验证

~~~powershell
dart format --output=none --set-exit-if-changed lib test
dart analyze lib test
flutter test
flutter build apk --debug
~~~

数据库生成文件 app_database.g.dart 已包含在工程中，普通运行无需先执行代码生成。


