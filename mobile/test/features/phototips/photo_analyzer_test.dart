import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_photo_app/features/phototips/data/photo_analyzer.dart';

Uint8List _solid(int w, int h, List<int> rgb) {
  final out = Uint8List(w * h * 4);
  for (var i = 0; i < w * h; i++) {
    final o = i * 4;
    out[o] = rgb[0];
    out[o + 1] = rgb[1];
    out[o + 2] = rgb[2];
    out[o + 3] = 255;
  }
  return out;
}

/// 生成左半皮肤色、右半黑色的贴边图。
Uint8List _offCenterSkin(int w, int h) {
  final out = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final o = (y * w + x) * 4;
      final skin = x < w ~/ 4;
      out[o] = skin ? 220 : 0;
      out[o + 1] = skin ? 160 : 0;
      out[o + 2] = skin ? 120 : 0;
      out[o + 3] = 255;
    }
  }
  return out;
}

List<String> _titles(PhotoAnalysisReport r) =>
    r.suggestions.map((s) => s.title).toList();

void main() {
  final analyzer = PhotoAnalyzer();

  test('全亮图：亮度过高提示过曝', () {
    final r = analyzer.analyze(_solid(8, 8, [255, 255, 255]), 8, 8);
    final brightness = r.metrics.firstWhere((m) => m.label == '亮度');
    expect(brightness.level, PhotoMetricLevel.bad);
    expect(_titles(r), contains('过曝'));
    expect(_titles(r), contains('色彩平淡'));
  });

  test('全暗图：提示曝光不足', () {
    final r = analyzer.analyze(_solid(8, 8, [10, 10, 10]), 8, 8);
    expect(_titles(r), contains('曝光不足'));
  });

  test('中灰图：对比度为 0 提示发灰', () {
    final r = analyzer.analyze(_solid(8, 8, [128, 128, 128]), 8, 8);
    expect(_titles(r), contains('画面发灰'));
  });

  test('全脸肤色居中：肤色占比高且构图通过', () {
    final r = analyzer.analyze(_solid(8, 8, [220, 160, 120]), 8, 8);
    final skin = r.metrics.firstWhere((m) => m.label == '肤色占比');
    expect(skin.level, PhotoMetricLevel.good);
    expect(_titles(r), contains('构图不错'));
  });

  test('肤色贴边：提示人物贴边', () {
    final r = analyzer.analyze(_offCenterSkin(16, 8), 16, 8);
    expect(_titles(r), contains('人物贴边'));
  });

  test('非法尺寸返回空报告', () {
    final r = analyzer.analyze(Uint8List(0), 0, 0);
    expect(r.metrics, isEmpty);
    expect(r.suggestions, isEmpty);
  });
}
