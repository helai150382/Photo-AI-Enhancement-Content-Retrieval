import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 解码后的 RGBA 位图数据。
class DecodedImage {
  const DecodedImage({
    required this.rgba,
    required this.width,
    required this.height,
  });

  final Uint8List rgba;
  final int width;
  final int height;
}

/// 将任意图片字节（PNG/JPEG 等）解码为 RGBA 字节流 + 尺寸。
DecodedImage? decodeToRgba(Uint8List bytes) {
  final src = img.decodeImage(bytes);
  if (src == null) return null;
  final rgba = Uint8List(src.width * src.height * 4);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final o = (y * src.width + x) * 4;
      rgba[o] = p.r.toInt();
      rgba[o + 1] = p.g.toInt();
      rgba[o + 2] = p.b.toInt();
      rgba[o + 3] = p.a.toInt();
    }
  }
  return DecodedImage(rgba: rgba, width: src.width, height: src.height);
}

/// 将 RGBA 字节流编码为 PNG。
Uint8List encodePng(Uint8List rgba, int w, int h) {
  final dst = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final o = (y * w + x) * 4;
      dst.setPixelRgb(x, y, rgba[o], rgba[o + 1], rgba[o + 2]);
    }
  }
  return Uint8List.fromList(img.encodePng(dst));
}

/// 等比缩小 RGBA 图到最大边长 [maxSide]，返回新 RGBA。
DecodedImage? makeThumbnail(
  Uint8List rgba,
  int w,
  int h, {
  int maxSide = 256,
}) {
  final scaled = img.copyResize(
    _rgbaToImage(rgba, w, h),
    width: w > h ? maxSide : null,
    height: h >= w ? maxSide : null,
    interpolation: img.Interpolation.average,
  );
  return _imageToRgba(scaled);
}

/// 从 RGBA 图中裁剪以 (x, y) 为左上角、rw x rh 的矩形区域（越界自动截断）。
/// 区域为空时返回 null。
Uint8List? cropRgba(
  Uint8List rgba,
  int w,
  int h,
  int x,
  int y,
  int rw,
  int rh,
) {
  final x0 = x < 0 ? 0 : x;
  final y0 = y < 0 ? 0 : y;
  final x1 = (x + rw).clamp(0, w);
  final y1 = (y + rh).clamp(0, h);
  if (x1 <= x0 || y1 <= y0) return null;
  final out = Uint8List((x1 - x0) * (y1 - y0) * 4);
  var o = 0;
  for (var yy = y0; yy < y1; yy++) {
    final row = yy * w * 4;
    for (var xx = x0; xx < x1; xx++) {
      final s = row + xx * 4;
      out[o++] = rgba[s];
      out[o++] = rgba[s + 1];
      out[o++] = rgba[s + 2];
      out[o++] = rgba[s + 3];
    }
  }
  return out;
}

/// 程序化生成 n 张内置示例图（横向多色渐变，便于颜色检索）。
/// 返回 [(key, pngBytes)] 列表，key 形如 'demo_0'。
List<(String, Uint8List)> buildDemoImages() {
  final colors = <List<int>>[
    [255, 60, 60], // 红
    [60, 130, 255], // 蓝
    [60, 200, 90], // 绿
    [255, 180, 60], // 橙（夕阳/日落）
    [90, 160, 220], // 海蓝
    [20, 20, 20], // 黑
    [245, 245, 245], // 白
  ];
  return [
    for (var i = 0; i < colors.length; i++)
      ('demo_$i', _gradientPng(colors[i])),
  ];
}

/// 以基准色生成 96x72 横向渐变 PNG 字节。
Uint8List _gradientPng(List<int> rgb) {
  const w = 96, h = 72;
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final mx = (x / (w - 1)) * 40;
      im.setPixelRgb(
        x,
        y,
        (rgb[0] * 0.75 + mx).clamp(0, 255).toInt(),
        (rgb[1] * 0.75 + mx).clamp(0, 255).toInt(),
        (rgb[2] * 0.75 + mx).clamp(0, 255).toInt(),
      );
    }
  }
  return Uint8List.fromList(img.encodePng(im));
}

img.Image _rgbaToImage(Uint8List rgba, int w, int h) {
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final o = (y * w + x) * 4;
      im.setPixelRgb(x, y, rgba[o], rgba[o + 1], rgba[o + 2]);
    }
  }
  return im;
}

DecodedImage _imageToRgba(img.Image src) {
  final rgba = Uint8List(src.width * src.height * 4);
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final o = (y * src.width + x) * 4;
      rgba[o] = p.r.toInt();
      rgba[o + 1] = p.g.toInt();
      rgba[o + 2] = p.b.toInt();
      rgba[o + 3] = p.a.toInt();
    }
  }
  return DecodedImage(rgba: rgba, width: src.width, height: src.height);
}
