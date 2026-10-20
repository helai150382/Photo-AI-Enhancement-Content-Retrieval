# Task 5 构建关卡验证笔记（build-gate-notes）

- 日期：2026-10-20
- 执行环境：Windows Server 2022（Windows 10.0.20348），PowerShell 5，无管理员权限

## 1. 环境版本

| 组件 | 版本 | 位置/说明 |
| --- | --- | --- |
| Flutter | 3.47.7（stable，引擎 deb287481e） | `C:\Users\Administrator\flutter` |
| Dart | 3.13.5 | 随 Flutter 内置 |
| JDK | Temurin 17.0.17+10 | `C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot`（`JAVA_HOME` 用户变量已设，但**当前进程内需手动 `$env:JAVA_HOME=...`** 才会被 sdkmanager/Gradle 识别） |
| Android SDK | 见下表 | `%LOCALAPPDATA%\Android\Sdk`（C 盘根目录无写权限，装于用户目录） |
| Gradle | 9.3.1（wrapper） | 发行包经腾讯镜像下载，见第 4 节 |
| AGP | 9.1.0 | `android/settings.gradle.kts` |
| Kotlin Gradle Plugin | 2.4.0 | 同上 |

Android SDK 已安装组件（`sdkmanager --list_installed`）：

- `cmdline-tools;latest`（commandlinetools-win-11076708）
- `platform-tools` 37.0.1
- `platforms;android-36`（Flutter 3.47.7 默认 compileSdk=36；android-35 为 Gradle 自动补装）
- `build-tools;36.0.0`
- `ndk;28.2.13676358`（Flutter 默认 NDK，AGP 首次构建时自动调 sdkmanager 安装）
- `cmake;3.22.1`（AGP 自动安装）

用户级环境变量已写入：`ANDROID_HOME`、`ANDROID_SDK_ROOT` 均指向 `C:\Users\Administrator\AppData\Local\Android\Sdk`；`flutter config --android-sdk` 已配置。所有 SDK 许可已接受。

`flutter doctor -v` 结果：Android toolchain `[√]`（Platform android-36, build-tools 36.0.0，licenses all accepted）；Visual Studio 未安装（仅影响 Windows 桌面构建，非本任务范围）；Network resources 检查报 maven.google.com/github.com 超时，但实际构建经由镜像完成，见第 4 节。

## 2. 安卓构建结果：成功

- 命令：`flutter build apk --debug`
- 产物：`mobile/build/app/outputs/flutter-apk/app-debug.apk`
- 大小：146.68 MB（153,800,350 字节，debug 包含 armeabi-v7a / arm64-v8a / x86_64 三套引擎，体积属正常范围）
- 末次成功构建耗时：约 107 秒（依赖与 NDK 均已在之前构建中缓存）

## 3. 鸿蒙（HarmonyOS / ohos）构建结果：未执行，记为已知风险

- DevEco Studio 未安装，本机无鸿蒙工具链，无法执行 ohos 平台添加与 HAP 构建。
- 按设计文档第 10 节的既定策略推进：**安卓完整功能 + 纯 Dart 逻辑双端通用 + 鸿蒙骨架可同步**。
- 后续若恢复鸿蒙验证，需先安装 DevEco Studio 并准备鸿蒙签名证书。

## 4. 构建过程中踩过的坑（对后续开发与 CI 有参考价值）

1. **Gradle 发行包下载超时**：`services.gradle.org` 不可达。已将 `android/gradle/wrapper/gradle-wrapper.properties` 的 `distributionUrl` 改为腾讯镜像 `https://mirrors.cloud.tencent.com/gradle/gradle-9.3.1-all.zip`（阿里云镜像无 9.3.1）。
2. **项目路径含中文**：AGP 9 默认拒绝非 ASCII 路径构建。已在 `android/gradle.properties` 增加 `android.overridePathCheck=true`。
3. **Kotlin 增量编译跨盘符崩溃**：项目在 D: 盘而 pub 缓存在 C: 盘，`photo_manager` 插件触发 `this and base files have different roots`。已在 `android/gradle.properties` 增加 `kotlin.incremental=false`。
4. **CMake 元数据 JSON 编码**：Windows 中文系统默认 GBK，CMake 生成的 `build_model.json` 含中文路径导致 Gson 解析失败（`MalformedJsonException`）。已在 `org.gradle.jvmargs` 增加 `-Dfile.encoding=UTF-8`，并清理旧的 `.cxx` 目录后重建成功。
5. **Flutter 引擎 artifact 下载停滞**：`storage.googleapis.com/download.flutter.io` 的大 jar（单文件 100–170 MB）经 Gradle 下载器多次停滞。构建时设置环境变量 `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn` 走国内镜像后解决（4 个引擎 jar 已完整落入 Gradle 缓存，后续增量构建不再依赖网络）。
6. **NDK 体积大**：NDK 28.2 约 2.1 GB，首次安装耗时约 35 分钟，属一次性成本。
7. **`flutter analyze` 在中文路径下崩溃**（Task 4 已发现）：需以 `dart analyze` 替代；CI 脚本同样应使用 `dart analyze`。
8. **当前 Shell 进程不继承用户级 `JAVA_HOME`**：每次新会话执行 sdkmanager/Gradle 前需先 `$env:JAVA_HOME="C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"`。

### 可复用的构建命令（PowerShell 5）

```powershell
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_HOME = $sdk; $env:ANDROID_SDK_ROOT = $sdk
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"  # 首次/清理缓存后需要
C:\Users\Administrator\flutter\bin\flutter.bat build apk --debug
```

## 5. 一期 MVP 最终全量验证（Task 22，2026-10-20）

一期 MVP 收尾质量关卡，双端构建与全量验证最终状态：

- **静态分析**：`dart analyze` → `No issues found!`（零 issue）。
- **全量测试**：`flutter test` → 18 个测试全部 PASS（覆盖裁剪、编辑管线、滤镜引擎、图库仓库、Photo 模型、颜色直方图、感知哈希、万级索引检索性能 < 2s、搜索服务、文本查询解析、向量索引、Result 冒烟等）。
- **安卓 APK debug 构建**：成功。
  - 产物：`mobile/build/app/outputs/flutter-apk/app-debug.apk`
  - 大小：163.4 MB
  - 增量构建耗时：Gradle `assembleDebug` 约 13.7 秒（引擎 artifact 已缓存）
  - 已知告警：`photo_manager` 插件仍使用 KGP，未来 Flutter 版本需插件迁移至 Built-in Kotlin（仅警告，不阻塞）。
- **鸿蒙 HAP**：未构建，为已知风险。DevEco Studio 未安装，一期仅交付鸿蒙骨架说明，纯 Dart 逻辑层保持双端通用，待 DevEco 就绪后补做 HAP 验证。

## 6. 遗留事项

- release 构建未验证（签名配置未做，Task 范围外）。
- 鸿蒙端工具链与构建验证待 DevEco Studio 就绪后补做。
- `gradle-wrapper.properties` 与 `gradle.properties` 的上述修改为环境适配项，是否随仓库提交由维护者决定；CI/其他机器若为英文路径且网络可达 Google，则仅需 SDK 与 licenses。
