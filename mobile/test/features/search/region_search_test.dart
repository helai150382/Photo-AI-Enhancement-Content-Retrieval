import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_photo_app/core/app_state.dart';
import 'package:ai_photo_app/features/gallery/data/image_codec.dart';
import 'package:ai_photo_app/features/gallery/models/photo_data.dart';
import 'package:ai_photo_app/features/search/data/search_service.dart';

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

void main() {
  group('cropRgba', () {
    test('基本区域裁剪', () {
      final rgba = _solid(4, 4, [40, 80, 240]);
      final out = cropRgba(rgba, 4, 4, 1, 1, 2, 2);
      expect(out, isNotNull);
      expect(out!.length, 2 * 2 * 4);
      expect(out[0], 40);
      expect(out[1], 80);
      expect(out[2], 240);
      expect(out[3], 255);
    });

    test('越界自动截断', () {
      final rgba = _solid(4, 4, [40, 80, 240]);
      final out = cropRgba(rgba, 4, 4, 3, 2, 10, 10);
      expect(out, isNotNull);
      // 有效区域为 1 列 x 2 行。
      expect(out!.length, 1 * 2 * 4);
    });

    test('空区域返回 null', () {
      final rgba = _solid(4, 4, [40, 80, 240]);
      expect(cropRgba(rgba, 4, 4, 0, 0, 0, 4), isNull);
      expect(cropRgba(rgba, 4, 4, 4, 0, 2, 2), isNull);
    });
  });

  group('SearchService.searchRegion', () {
    test('返回与区域色彩相似的图片', () {
      final svc = SearchService()
        ..indexPhoto('red', _solid(8, 8, [240, 40, 40]), 8, 8)
        ..indexPhoto('blue', _solid(8, 8, [40, 80, 240]), 8, 8);
      final q = _solid(4, 4, [250, 30, 30]); // 红色标注区域
      final hits = svc.searchRegion(q, 4, 4);
      expect(hits, isNotEmpty);
      expect(hits.first.key, 'red');
      expect(hits.first.score, greaterThan(0.9));
    });

    test('非法区域返回空', () {
      final svc = SearchService()
        ..indexPhoto('red', _solid(8, 8, [240, 40, 40]), 8, 8);
      expect(svc.searchRegion(Uint8List(0), 0, 0), isEmpty);
    });
  });

  group('AppState 接线', () {
    test('addPhotos 后 searchRegion 命中相同颜色图', () {
      final red = PhotoData(
        key: 'r',
        name: 'red',
        rgba: _solid(8, 8, [240, 40, 40]),
        width: 8,
        height: 8,
        thumbnail: _solid(8, 8, [240, 40, 40]),
        thumbWidth: 8,
        thumbHeight: 8,
      );
      final blue = PhotoData(
        key: 'b',
        name: 'blue',
        rgba: _solid(8, 8, [40, 80, 240]),
        width: 8,
        height: 8,
        thumbnail: _solid(8, 8, [40, 80, 240]),
        thumbWidth: 8,
        thumbHeight: 8,
      );
      final state = AppState()..addPhotos([red, blue]);
      final hits = state.searchRegion(_solid(4, 4, [250, 30, 30]), 4, 4);
      expect(hits, isNotEmpty);
      expect(hits.first.key, 'r');
      expect(hits.first.score, greaterThan(0.9));
    });
  });

  group('裁剪→检索 端到端', () {
    test('从大图中裁剪红色区域后可命中红色图', () {
      // 左半红 右半蓝 的 16x8 目标图。
      final target = Uint8List(16 * 8 * 4);
      for (var y = 0; y < 8; y++) {
        for (var x = 0; x < 16; x++) {
          final o = (y * 16 + x) * 4;
          final isRed = x < 8;
          target[o] = isRed ? 240 : 40;
          target[o + 1] = 40;
          target[o + 2] = isRed ? 40 : 240;
          target[o + 3] = 255;
        }
      }
      final redPhoto = PhotoData(
        key: 'red',
        name: 'red',
        rgba: _solid(8, 8, [240, 40, 40]),
        width: 8,
        height: 8,
        thumbnail: _solid(8, 8, [240, 40, 40]),
        thumbWidth: 8,
        thumbHeight: 8,
      );
      final state = AppState()..addPhotos([redPhoto]);

      // 标注目标图左侧红色区域（0,0,8,8）。
      final region = cropRgba(target, 16, 8, 0, 0, 8, 8)!;
      final hits = state.searchRegion(region, 8, 8);
      expect(hits, isNotEmpty);
      expect(hits.first.key, 'red');
    });
  });
}
