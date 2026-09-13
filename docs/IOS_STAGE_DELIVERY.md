# iOS 适配阶段交付记录

## 阶段目标

在不改变 Android 本地数据和现有业务流程的前提下，为 `learning bird` 建立可交给 macOS/Xcode 继续构建、签名和真机测试的 iOS 工程。

## 已完成

- 生成 Flutter 官方 iOS 13.0+ 工程、Runner Target、Workspace 和测试 Target。
- 设置 Bundle Identifier：`com.learningbird.learningbird`。
- iOS 系统版本号设为 `1.0.0`，构建号沿用 Flutter 构建号 `9`。
- iPhone 仅使用竖屏；iPad 保留系统支持的四种方向。
- 计划通知和番茄钟通知支持 iOS 延迟申请权限、检查权限、前台展示和通知分组。
- AppDelegate 已设置 `UNUserNotificationCenter` 代理。
- 生成全部 iPhone、iPad 和 App Store 尺寸的“鸟与书本”应用图标。
- 生成品牌启动图并使用浅灰白启动背景。
- iOS 插件清单已识别文件选择、本地通知和应用目录插件。
- 移除已经没有调用的 `flutter_tts` 依赖。
- 增加 Mac/Xcode 构建、签名与真机验收说明。

## Windows 端验证

- `flutter pub get --offline` 成功。
- Flutter 静态分析无问题。
- 全部可运行的 Dart/Flutter 自动化测试通过。
- iOS 工程结构、应用信息、图标文件及通知入口由自动化测试检查。
- Android Debug APK 继续构建，确认跨平台改动没有破坏 Android。

## 必须在 Mac 完成

- Xcode 编译和 Swift 链接。
- Apple Developer Team、证书和 Provisioning Profile 配置。
- iPhone 真机通知、文件选择、备份恢复、数据库持久化和界面验收。
- Archive、App Store Connect 校验及 TestFlight。

Windows 无法安装 Xcode，因此本阶段不宣称 iOS 已完成签名、真机运行或 App Store 发布。
