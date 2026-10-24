# AI 识图P图 — 项目总结

## 一、项目背景

面向普通个人用户的**相册 AI 工具**：用自然语言批量「找照片」和「修照片」。核心诉求是隐私优先、零门槛、纯浏览器可用。项目经历了两期演进：

- **一期（MVP，2026-10-20）**：Flutter 移动端（安卓 + 鸿蒙 NEXT），端侧向量检索 + 基础美化。
- **二期（Web 迁移，2026-10-21）**：改为**浏览器直接访问的 Web 应用**（PC 网页 + H5 手机网页），图片来源改为本地文件上传 + 内置示例图兜底。
- **三期（近期迭代）**：文字指令美化、上传进度环、相册多选删除、标注检索、拍照技巧、检索空态等。

## 二、技术架构

整体是「**Flutter Web 前端 + 本地 Python 代理**」的单体同源部署：

```
浏览器 (Flutter Web SPA)  ──同源 fetch──▶  Python 本地服务 (server/app.py, 端口 8040)
   ├─ 纯 Dart 算法层（检索/滤镜/变形，全离线）      ├─ 静态托管 build/web
   ├─ MediaPipe JS Bridge（人脸/人体关键点）         ├─ /api/chat   → DeepSeek 代理（Key 仅存服务端）
   └─ 共享状态 AppState                              └─ /api/health → 健康检查
```

**前端（`mobile/`，Flutter Web）**

技术栈：Flutter / Dart `^3.13.5`、`image ^4.2.0`（纯 Dart 编解码）、`file_selector`（Web 文件选择）、`package:web`（浏览器下载、fetch）。依赖极简，见 [pubspec.yaml](file:///d:/AI%20program/AI识图P图/mobile/pubspec.yaml)。

- **入口与外壳**：[main.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/main.dart) → [app.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/app.dart)，5 个 Tab，**响应式布局**（≥840px 用 `NavigationRail` 侧栏，窄屏用 `NavigationBar` 底栏）。
- **共享状态**：[app_state.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/core/app_state.dart)（`ChangeNotifier`），统一持有照片集合 + 检索索引，串联相册/检索/编辑/标注各页。
- **条件导入适配层**：`landmark_service_{web,stub}.dart`、`llm_transport_{web,stub}.dart`，Web 与非 Web 分离实现，便于测试注入。
- **纯 Dart 算法层**（可离线、可单测）：颜色直方图、向量索引、滤镜引擎、编辑渲染管线、人脸变形等。

**后端（`server/app.py`）**

- **仅用 Python 标准库**，零第三方依赖；静态托管 + 反向代理。
- `/api/chat`：把中文指令 + 当前参数交给 `deepseek-flash`（JSON Output、temperature 0.2）解析成结构化操作，失败重试 2 次并做白名单/clamp 归一化。
- **密钥安全**：API Key 只从环境变量 `DEEPSEEK_API_KEY` 或 `server/config.json` 读取，前端不可见；同源转发规避 CORS。
- 操作注册表（`OPS`/`PRESETS`）与前端 [beautify_ops.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/edit/data/beautify_ops.dart) 保持一致。

**跨端 AI 能力**：[beauty_bridge.js](file:///d:/AI%20program/AI识图P图/mobile/web/beauty_bridge.js) 用 MediaPipe Tasks Vision 1.1.1 在浏览器内做人脸/人体关键点检测，供瘦脸/大眼/瘦身等几何操作使用。

## 三、系统功能

| 模块 | 位置 | 能力 |
|---|---|---|
| **相册** | [gallery_screen.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/gallery/ui/gallery_screen.dart) | 本地图片多选上传（实时进度环）、内置示例图、网格展示、长按进入多选、批量删除 |
| **检索** | [search_screen.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/search/ui/search_screen.dart) | 自然语言找图（"蓝色的照片/海边/夕阳"），端侧颜色直方图相似度匹配、Top-20 排序、缩略图结果，未识别时给空态反馈 |
| **标注** | [annotate_screen.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/annotate/ui/annotate_screen.dart) | 在图片上拖拽框选区域 → 按区域颜色内容检索相似图（以图搜图） |
| **美化** | [edit_screen.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/edit/ui/edit_screen.dart) | **文字指令驱动**修图：磨皮/美白/红润/清晰度/瘦脸/大眼/瘦身 + 亮度/对比度/饱和度/色温/色调/锐化/暗角；8 种滤镜预设；滑杆 + 撤销栈；实时预览；下载 PNG |
| **技巧** | [photo_tips_screen.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/phototips/ui/photo_tips_screen.dart) | 图文拍照技巧卡；上传照片后基于颜色统计启发式分析（亮度/对比度/饱和度/色温/肤色占比）给出改进建议 |

关键流程：**检索**为全离线（导入即建向量索引 → 文本转颜色查询 → 余弦相似度排序）；**美化**为本地代理解析 + 端侧纯 Dart 渲染，仅指令解析走云端。

> 说明：[perceptual_hash_feature.dart](file:///d:/AI%20program/AI识图P图/mobile/lib/features/search/data/perceptual_hash_feature.dart) 当前无业务引用，属二期预留能力。

## 四、安装部署说明

**环境要求**

- Flutter SDK（Dart `^3.13.5`），Windows + PowerShell。
- Python 3（标准库即可）。
- 可选：DeepSeek API Key（不配置则美化指令解析不可用，其余功能正常）。
- 首次运行会自动下载 MediaPipe 运行时与模型（人脸/人体），需要外网。

**部署步骤**

1. 获取 MediaPipe 静态资源（`start_h5.ps1` 会按需自动调用 [fetch_mediapipe_assets.ps1](file:///d:/AI%20program/AI识图P图/scripts/fetch_mediapipe_assets.ps1)，也可单独执行）：
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\fetch_mediapipe_assets.ps1
   ```
2. 配置 DeepSeek Key（二选一，`server/config.json` 已被 gitignore）：
   ```powershell
   # 方式 A：环境变量
   $env:DEEPSEEK_API_KEY = "sk-..."
   # 方式 B：server/config.json → {"api_key":"sk-..."}
   ```
3. 一键构建并启动（固定端口 **8040**）：
   ```powershell
   powershell -ExecutionPolicy Bypass -File start_h5.ps1 -Build   # 首次/改动后重建
   powershell -ExecutionPolicy Bypass -File start_h5.ps1         # 复用已有 build/web
   ```
   访问：本机 `http://localhost:8040`，手机同局域网 `http://<LAN-IP>:8040`。
4. 健康检查：`http://localhost:8040/api/health`，返回 `{ok, model, keyConfigured}`。

**说明与注意事项**

- [start_h5.ps1](file:///d:/AI%20program/AI识图P图/start_h5.ps1) 中硬编码了本机路径：Flutter `C:\Users\Administrator\flutter\bin\flutter.bat`、Python `C:\Program Files\PyManager\python.exe`；换机需按需修改。
- 脚本会自动释放被占用的 8040 端口（仅限 python 进程），并在缺少 `config.json` 时给出告警。
- **测试**：前端 `flutter test`（`mobile/` 下）；后端 `python -m unittest discover -s server`。静态分析请用 `dart analyze`（中文路径下 `flutter analyze` 会崩溃）。
- 服务为**开发用本地服务**：无鉴权、单机部署，图片不上云（仅指令文本发往 DeepSeek）。
