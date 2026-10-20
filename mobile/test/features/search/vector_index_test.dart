import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/vector_index.dart';
import 'package:ai_photo_app/features/search/data/image_feature.dart';

class _F implements ImageFeature {
  _F(this.vector);
  @override
  final List<double> vector;
  @override
  int get dim => vector.length;
  @override
  double cosineSimilarity(ImageFeature other) =>
      _dot(vector, other.vector) / (_norm(vector) * _norm(other.vector));

  static double _dot(List<double> a, List<double> b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  static double _norm(List<double> v) {
    var s = 0.0;
    for (final x in v) {
      s += x * x;
    }
    return s == 0 ? 0 : _sqrt(s);
  }

  static double _sqrt(double x) {
    var g = x / 2;
    for (var i = 0; i < 20; i++) {
      g = (g + x / g) / 2;
    }
    return g;
  }
}

void main() {
  test('插入后按余弦相似度返回 top-k', () {
    final idx = VectorIndex();
    idx.add('a', _F([1, 0]));
    idx.add('b', _F([0, 1]));
    idx.add('c', _F([0.9, 0.1]));
    final hits = idx.search(_F([1, 0]), k: 2);
    expect(hits.length, 2);
    expect(hits.first.key, 'a');
    expect(hits[1].key, 'c');
  });
}
