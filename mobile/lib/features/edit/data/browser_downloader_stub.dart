import 'dart:typed_data';

/// 非 Web 平台（如 VM 测试）下的占位实现，下载操作不生效。
void downloadPng(Uint8List png, String fileName) {}
