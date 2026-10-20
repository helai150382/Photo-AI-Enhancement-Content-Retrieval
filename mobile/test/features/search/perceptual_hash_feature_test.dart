import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/perceptual_hash_feature.dart';

void main() {
  test('相同图像哈希一致，纯黑 vs 纯白汉明距离大', () {
    final black = Uint8List(16); // 2x2 RGBA = 全 0(黑)
    final white = Uint8List(16);
    for (var i = 0; i < white.length; i += 4) {
      white[i] = 255; white[i + 1] = 255; white[i + 2] = 255; white[i + 3] = 255;
    }
    final a = PerceptualHashFeature.fromRaster(black, 2, 2);
    final b = PerceptualHashFeature.fromRaster(black, 2, 2);
    final c = PerceptualHashFeature.fromRaster(white, 2, 2);
    expect(a.hamming(b), 0);
    expect(a.hamming(c), greaterThan(0));
  });
}
