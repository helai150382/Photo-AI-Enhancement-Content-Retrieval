import 'dart:typed_data';

import 'browser_downloader_stub.dart'
    if (dart.library.js_interop) 'browser_downloader_web.dart' as impl;

/// 浏览器下载 PNG 文件。Web 平台走 Blob 下载，其它平台（测试/桌面）为空操作。
void downloadPng(Uint8List png, String fileName) =>
    impl.downloadPng(png, fileName);
