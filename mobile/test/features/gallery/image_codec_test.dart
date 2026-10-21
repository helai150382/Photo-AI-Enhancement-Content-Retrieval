import 'dart:typed_data';

import 'package:ai_photo_app/features/gallery/data/image_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('decodeToRgba 解析 PNG 并返回 RGBA 与尺寸', () {
    final src = img.Image(width: 4, height: 3);
    img.fillRect(
      src,
      x1: 0,
      y1: 0,
      x2: 4,
      y2: 3,
      color: img.ColorRgb8(255, 0, 0),
    );
    final png = Uint8List.fromList(img.encodePng(src));

    final r = decodeToRgba(png);
    expect(r, isNotNull);
    expect(r!.width, 4);
    expect(r.height, 3);
    expect(r.rgba.length, 4 * 3 * 4);
    // 左上角像素为红色
    expect(r.rgba[0], 255);
    expect(r.rgba[1], 0);
    expect(r.rgba[2], 0);
    expect(r.rgba[3], 255);
  });

  test('encodePng 与 decodeToRgba 往返一致', () {
    final rgba = Uint8List(4 * 2 * 2);
    for (var i = 0; i < 4; i++) {
      rgba[i * 4] = 0;
      rgba[i * 4 + 1] = 255;
      rgba[i * 4 + 2] = 0;
      rgba[i * 4 + 3] = 255;
    }
    final png = encodePng(rgba, 2, 2);
    final back = decodeToRgba(png);
    expect(back!.width, 2);
    // 绿色分量保留
    expect(back.rgba[1], 255);
  });

  test('makeThumbnail 缩小超过 maxSide 的图', () {
    final rgba = Uint8List(100 * 100 * 4);
    final t = makeThumbnail(rgba, 100, 100, maxSide: 32);
    expect(t!.width, 32);
    expect(t.height, 32);
  });
}
