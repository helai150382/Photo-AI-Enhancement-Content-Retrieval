import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/color_histogram_feature.dart';

void main() {
  test('同为纯红图相似度高，纯红 vs 纯蓝相似度低', () {
    final red = ColorHistogramFeature.fromImage(_solid(255, 0, 0), 1, 1);
    final blue = ColorHistogramFeature.fromImage(_solid(0, 0, 255), 1, 1);
    final same = red.cosineSimilarity(red);
    final diff = red.cosineSimilarity(blue);
    expect(same, greaterThan(0.99));
    expect(diff, lessThan(same));
  });
}

Uint8List _solid(int r, int g, int b) {
  final buf = Uint8List(4); // RGBA 单像素
  buf[0] = r; buf[1] = g; buf[2] = b; buf[3] = 255;
  return buf;
}
