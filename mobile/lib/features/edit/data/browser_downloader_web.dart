import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// 浏览器端实现：Blob + ObjectURL + 隐藏锚点触发下载。
void downloadPng(Uint8List png, String fileName) {
  final blob = web.Blob(
    [png.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..click();
  web.URL.revokeObjectURL(url);
}
