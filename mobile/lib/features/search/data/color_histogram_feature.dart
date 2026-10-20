import 'dart:math';
import 'dart:typed_data';
import 'image_feature.dart';

/// 三通道量化直方图（每通道 4 级 -> 64 维），对尺寸不变。
class ColorHistogramFeature implements ImageFeature {
  ColorHistogramFeature(this.vector);
  @override
  final List<double> vector;
  @override
  int get dim => vector.length;

  factory ColorHistogramFeature.fromImage(Uint8List rgba, int w, int h) {
    const bucket = 4;
    final hist = List<double>.filled(bucket * bucket * bucket, 0);
    var total = 0;
    for (var i = 0; i < w * h; i++) {
      final o = i * 4;
      final r = rgba[o] ~/ (256 ~/ bucket);
      final g = rgba[o + 1] ~/ (256 ~/ bucket);
      final b = rgba[o + 2] ~/ (256 ~/ bucket);
      hist[(r * bucket + g) * bucket + b] += 1;
      total++;
    }
    final v = hist.map((c) => c / (total == 0 ? 1 : total)).toList();
    return ColorHistogramFeature(v);
  }

  /// 目标颜色 -> 最近采集桶的 one-hot 向量，作为查询特征。
  factory ColorHistogramFeature.fromColor(List<double> rgb) {
    const bucket = 4;
    final v = List<double>.filled(bucket * bucket * bucket, 0);
    final q = rgb
        .map((c) => (c * (bucket - 0.001)).floor().clamp(0, bucket - 1))
        .toList();
    v[(q[0] * bucket + q[1]) * bucket + q[2]] = 1;
    return ColorHistogramFeature(v);
  }

  @override
  double cosineSimilarity(ImageFeature other) => cosineBetween(vector, other.vector);
}

/// 通用余弦相似度（线程安全、纯 Dart），供检索服务复用。
double cosineBetween(List<double> a, List<double> b) {
  var dot = 0.0, na = 0.0, nb = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  final denom = sqrt(na) * sqrt(nb);
  if (denom == 0) return 0;
  return dot / denom;
}
