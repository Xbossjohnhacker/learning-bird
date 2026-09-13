# Learning Bird 1.0 发布检查清单

## 当前状态与正式目标
当前 GitHub 发布版本：1.0.0+19。应用标识：com.learningbird.learning_bird。
Build 19 已使用项目所有者的首个正式发布密钥签名；内部历史 APK 仍为调试签名，不得作为正式版分发。

## 签名准备
1. 决定正式签名密钥归属及备份位置。若已有发布密钥，应继续使用原密钥。
2. 在本机安全目录保管密钥和密码，不发到聊天或提交源码。
3. 复制 android/key.properties.example 为 android/key.properties，填写本地密钥路径、别名和密码；Windows 路径建议用正斜杠。
4. 未配置签名时，普通 Release 构建必须失败，禁止默默回退到调试签名。
5. 正式构建时确保 allowDebugSigning 项目参数未开启，且 ORG_GRADLE_PROJECT_allowDebugSigning 环境变量未设置。
6. 运行 flutter build apk --release；若需要商店上传包，可运行 flutter build appbundle --release。
7. 用 Android SDK apksigner verify --verbose --print-certs 检查签名主体和证书指纹；核对版本、应用标识与文件 SHA-256。
8. 将 docs/PRIVACY_POLICY.md 发布到长期有效的 HTTPS 地址，并在商店资料填写同一地址和支持邮箱。
9. 核对商店“数据安全”声明与实际版本一致：无账号、无广告分析、不上传学习数据；说明关联应用列表的本地用途。

内部测试 Release 必须显式传入一次性 Gradle 参数。Flutter 在本机转发环境变量时未能可靠传递同名项目属性，因此采用下列已验证入口（项目根目录，已完成 flutter pub get，JAVA_HOME 指向可用 JDK）：

```powershell
flutter build apk --debug --build-name=1.0.0 --build-number=19
Push-Location android
try {
  .\gradlew.bat '-PallowDebugSigning=true' '-Ptarget-platform=android-arm,android-arm64,android-x64' '-Ptarget=lib/main.dart' ':app:assembleRelease'
} finally {
  Pop-Location
}
```

第一行用于把 Flutter 的本地构建元数据刷新为计划正式发布的 1.0.0（19）；省略后直接运行 Gradle 可能沿用上一次构建的旧版本号。生成后必须用 `aapt dump badging` 再次核对。

输出位于 build/app/outputs/apk/release/app-release.apk。复制交付时必须命名为含 debug-signed 的文件；若已配置正式密钥，正式密钥优先且必须再次核对证书。不得在用户/系统全局环境或 gradle.properties 持久化测试开关。

## 1.0.0（10）内部验收结果

- 包名：`com.learningbird.learning_bird`
- minSdk：26；targetSdk：36
- 应用名：Learning Bird
- Release 模式 R8 压缩、资源优化和签名校验通过
- 内部包证书：Android Debug，仅供验收，禁止公开分发
- APK SHA-256：`6394FD3B9DD766DA0AED92C5370E16FD1BE764792FA901DF5E18F905E6BEB0A0`
- AAB SHA-256：`32B5FFCC7BBA0E388447B88FB0A427CD4067F0CC6DA217D6CD61392692D8CB4B`

## 1.0.0（11）当前内部验收结果

- 包名：`com.learningbird.learning_bird`
- minSdk：26；compileSdk/targetSdk：36
- 应用名：Learning Bird
- Release 模式 R8 压缩、资源优化、JNI/CMake 构建与 16 KB ZIP 对齐通过
- 静态分析无问题；124 项自动化测试通过，另有 1 项个人课表样本测试按设计跳过
- 内部包证书：Android Debug，仅供验收，禁止上传商店或公开分发
- APK SHA-256：`49EBB6B63B0F55C18011E60DC231F220584301582E0881BB71516CD73A76E253`
- AAB SHA-256：`114752C4AC1602931A4D55068512B4F3C22F9E58314601325116B3B0820DB9B0`
- 无密钥源码快照 SHA-256：`ABBFBCD0D7AEBF5FD58FC5769F180FFF77BE5AEB4E3ED89A6713D4A70A7D9558`

## 1.0.0（19）GitHub 正式发布结果

- 包名：`com.learningbird.learning_bird`
- 版本：`1.0.0`；versionCode：`19`
- minSdk：26；compileSdk/targetSdk：36
- APK 大小：69,894,521 字节（约 66.66 MiB）
- APK SHA-256：`49EA21332F77C46F93E639B923A0A9F0A30834909421DBC880F29AD8F9E0C734`
- 正式证书 SHA-256：`B94AC4957B6F782F86833B5A6B3CFDFF2CDB015063C59685EF4B9864CEEDD3CD`
- APK Signature Scheme v2 校验通过；签名主体为 Learning Bird，不是 Android Debug。
- 16 KB ZIP 对齐校验通过。
- 141 项自动化测试通过，另有 1 项个人课表样本测试按设计跳过；静态分析无问题。

## Google Play 提交前的权限申报

- `USE_EXACT_ALARM` 属于受限制权限。提交时应说明 Learning Bird 的计划日历提醒与番茄计时器属于核心、用户主动设置且需要准时触发的功能；如果审核口径不接受，应改用由用户授权的 `SCHEDULE_EXACT_ALARM`。
- `USE_FULL_SCREEN_INTENT` 需要在 Play Console 的“应用内容”中申报。仅将其用于用户主动设置的闹钟式提醒；如果无法获批默认授权，必须保留当前的用户授权入口和普通顶部横幅降级路径，或在商店版本移除此权限。
- 完成“数据安全”、广告、目标受众、内容分级和隐私政策表单；声明应用无账号、无广告分析且学习数据不上传，并如实说明本地查询可启动应用的用途。
- 2026 年 8 月 31 日后新应用及更新需以 API 36 或更高版本为目标；当前构建已满足。

官方参考：
- https://docs.flutter.dev/deployment/android
- https://developer.android.com/develop/ui/views/launch/splash-screen
- https://support.google.com/googleplay/android-developer/answer/11926878
- https://support.google.com/googleplay/android-developer/answer/16558241
- https://support.google.com/googleplay/android-developer/answer/13392821

## 必须人工完成的真机验收
- Android 8–11 与 Android 12+ 图标、浅色/深色启动页、安装与升级。
- 通知允许/拒绝、锁屏、后台、省电、系统回收和设备重启后的提醒。
- 番茄钟暂停、恢复、前后台切换、结束时提醒和计划实际用时。
- 系统文件选择器选择、取消、读取失败；导入与备份恢复完整流程。
- 创建/删除词书（含取消删除）、分类弹窗、重复导入。
- 同签名覆盖升级与数据保留；换正式签名前的备份迁移。
- 至少 10 万词真实导入耗时、UI 响应与内存测试。当前既有压力测试仅覆盖 1 万词。
- 计划关联应用的列表、图标、启动成功及应用卸载后的错误提示。

## 当前公开说明中的限制

- 厂商省电策略可能延迟后台提醒，首次使用时需按设置页提示检查通知、精确闹钟和后台活动权限。
- JSON 数据备份不包含资料工具箱中的文件，用户需要保留资料原文件。
- PDF、Word、压缩包等文件可导入和管理，当前版本不提供应用内预览。
- iOS 工程已准备，但本次 Android 公开发布不包含 iOS 安装包。
