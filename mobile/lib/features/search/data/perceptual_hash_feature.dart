import 'dart:typed_data';
import 'image_feature.dart';

/// 基于 8x8 块灰度均值二值化的感知哈希，输出 64 bit。
class PerceptualHashFeature implements ImageFeature {
  PerceptualHashFeature(this._bits);
  final List<int> _bits; // 0/1

  @override
  List<double> get vector => _bits.map((b) => b * 1.0).toList();
  @override
  int get dim => _bits.length;

  factory PerceptualHashFeature.fromRaster(Uint8List rgba, int w, int h) {
    const gw = 2, gh = 2; // 测试用 2x2；真实图片降采样到 8x8
    final cells = List<double>.filled(gw * gh, 0);
    for (var by = 0; by < gh; by++) {
      for (var bx = 0; bx < gw; bx++) {
        var s = 0.0, n = 0.0;
        for (var y = by * h ~/ gh; y < (by + 1) * h ~/ gh; y++) {
          for (var x = bx * w ~/ gw; x < (bx + 1) * w ~/ gw; x++) {
            final o = (y * w + x) * 4;
            s += 0.299 * rgba[o] + 0.587 * rgba[o + 1] + 0.114 * rgba[o + 2];
            n++;
          }
        }
        cells[by * gw + bx] = n == 0 ? 0 : s / n;
      }
    }
    final avg = cells.reduce((a, b) => a + b) / cells.length;
    // c > avg：常规 aHash；c == avg（纯色图方差为 0）时用绝对亮度 128 兜底，
    // 否则纯黑与纯白会得到相同的全 0 哈希。
    final bits = cells.map((c) => c > avg || (c == avg && c > 128) ? 1 : 0).toList();
    return PerceptualHashFeature(bits);
  }

  int hamming(PerceptualHashFeature other) {
    var d = 0;
    for (var i = 0; i < _bits.length; i++) {
      if (_bits[i] != other._bits[i]) d++;
    }
    return d;
  }

  @override
  double cosineSimilarity(ImageFeature other) {
    final o = other as PerceptualHashFeature;
    return 1 - hamming(o) / dim;
  }
}
