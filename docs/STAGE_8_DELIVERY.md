# M8 发布准备交付记录

日期：2026-08-30。版本：1.0.0-rc.1+8。

本文件保留 rc.1 阶段的历史验收结果。后续 rc.2 已将模板简化为单张表两列并新增手动添加，详见 CHANGELOG.md；下方 Excel 校验值对应 outputs/stage8-20260830/word-import-template.xlsx 历史副本，不再对应 docs/templates 中的最新简化模板。

结论：发布准备和本机自动化验证完成，提供内部测试候选包；M8 的正式发布门槛仍未全部满足。没有生成正式密钥、上架应用、安装或卸载手机应用，也没有删除用户数据。

## 已完成

- 鸟与书本主题的 Android 自适应图标、主题单色图标、浅/深色启动背景与 Android 12+ 启动主题。
- 独立通知图标及 Release 资源保留规则。
- 设置中的版本、候选状态、开源许可入口。
- 正式签名配置入口；缺少签名时阻止普通 Release 构建。内部测试必须明确传入单次调试签名参数。
- 分类弹窗生命周期修复；词书创建、文件读取及页面退出后的异常保护。
- CSV 重复表头、空文件和无效 UTF-8 拒绝；单词/释义同列映射提示。
- 部分标准 XLSX 的命名空间前缀、内部绝对链接兼容修复，保留原文件不变。
- 双工作表 Excel 模板、使用说明、版本记录、正式发布及真机验收清单。

## 验证记录

| 检查 | 结果 |
| --- | --- |
| Dart 格式检查 | 56 个文件，0 个需变更 |
| Flutter 静态分析 | No issues found |
| 全量自动化测试 | 38 项全部通过 |
| 既有压力测试 | 1 万词及复习计划查询通过；不是 10 万词真机导入测试 |
| Excel 模板 | 两张表已渲染检查；实际导入器识别 2 条样例及扩展字段 |
| Excel 兼容 | 普通工作簿、命名空间前缀、绝对链接与重复转换回归通过 |
| Debug APK | 本阶段资源与签名配置可构建 |
| 未配置正式签名的普通 Release | 按预期被保护检查拒绝 |
| 最终候选 Release | 显式调试签名构建成功，签名 v2 校验通过 |
| APK 元信息 | com.learningbird.learning_bird；版本 1.0.0-rc.1（8）；minSdk 26 / targetSdk 36 |
| APK 架构 | arm64-v8a、armeabi-v7a、x86_64 |
| Release 图标资源 | 启动图、自适应图及通知图标均保留 |
| 真机 | ADB 未检测到连接设备，未执行本轮真机验收 |

## 交付文件

- 测试安装包：[learning-bird-1.0.0-rc.1-debug-signed.apk](../releases/learning-bird-1.0.0-rc.1-debug-signed.apk)，65,689,713 字节。
- [Excel 模板](templates/word-import-template.xlsx)
- [使用说明](USER_GUIDE.md)
- [发布清单](RELEASE_CHECKLIST.md)
- [版本记录](CHANGELOG.md)

APK SHA-256：`2502CD7E896C1DF951A438F741A2ECA603D3794E171AAC1B78C6F515B0E406ED`

签名主体：`C=US, O=Android, CN=Android Debug`，不是正式发布证书。

证书 SHA-256：`2039e43ec24701edf5b34eb9b2d11019e20f52666cdaa8ab904bce77853c367a`

Excel SHA-256：`4D3BB331B5C21911743D5734E2058063E23542010A8DC7F276AC0B662E32DF2B`

## 尚待完成

1. 用户确定正式签名密钥归属、保管及备份方案，再生成正式签名包。不要把密码或密钥发送到聊天。
2. 按发布清单完成不同 Android 版本的图标/启动、通知权限、锁屏后台、重启、系统文件选择器、离线 TTS 与数据保留升级验收。
3. 10 万词真机导入与内存/界面响应验收。
4. flutter_tts 的 KGP、Gradle/Android 旧配置兼容警告仍存在；当前构建成功，但升级 Flutter/AGP 前必须处理并回归。没有为了消除警告而未经验证升级整套工具链。

本机通过显式 Gradle `-PallowDebugSigning=true` 参数构建内部包，详见发布清单；没有持久化调试签名开关。正式版切换签名可能无法覆盖现有测试版，必须先备份并确认迁移方案。
