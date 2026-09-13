# iOS 工程准备与验收

## 当前工程

- iOS 工程目录：`ios/`
- Bundle Identifier：`com.learningbird.learningbird`
- 最低系统：iOS 13.0
- 显示名称：`Learning Bird`
- iOS 系统版本号：`1.0.0`；构建号沿用 `pubspec.yaml` 中的 `9`。应用内仍标识为 rc.2 候选状态
- 计划提醒与番茄钟通知已配置 iOS 权限申请、前台展示和通知分组
- 应用图标和启动图沿用 Android 版“鸟与书本”主题
- 数据库、词书、课表导入、备份与恢复继续使用本地离线存储

## Mac 首次构建

1. 安装当前稳定版 Flutter、Xcode 和 Xcode Command Line Tools。
2. 将完整项目复制到 Mac，保留 `assets/`、`ios/` 和 `pubspec.lock`。
3. 在项目根目录运行 `flutter doctor -v`，确保 iOS toolchain 无错误。
4. 运行 `flutter pub get`。
5. 先运行 `flutter build ios --debug --no-codesign --build-number=9` 检查编译。
6. 使用 Xcode 打开 `ios/Runner.xcworkspace`，不要直接打开 `Runner.xcodeproj`。
7. 在 Runner 的 Signing & Capabilities 中选择自己的 Apple Developer Team；若 Bundle Identifier 已被占用，改为本人唯一标识。
8. 连接 iPhone，在 Xcode 选择真机并运行。

## 真机验收

- 首次启动、浅色启动页、应用图标及中文名称。
- 创建带提醒的计划时，iOS 通知权限弹窗只在需要时出现。
- 通知允许、拒绝及之后在系统设置中修改权限的状态。
- 计划提醒和番茄钟结束提醒在前台、后台和锁屏状态下显示。
- Excel/CSV 词书导入、课程表 `.xlsx` 导入及取消文件选择。
- JSON 备份导出、从“文件”App 选择备份并恢复。
- 应用被系统结束后再次打开，计划、单词进度、番茄记录和设置仍保留。
- 周规划表、日列表、重叠课程选择以及左右滑动切周。
- 深色模式、动态字体和 iPhone 小屏幕布局。

## 发布前

- 在 Xcode 中设置正式签名、App Store Connect 应用记录及唯一 Bundle Identifier。
- 确认版本号和构建号递增。
- 在真机完成通知、文件选择和数据升级测试后，再执行 Archive。
- 不要把 Apple 证书、Provisioning Profile 或账号密码提交到源码或发送到聊天。
