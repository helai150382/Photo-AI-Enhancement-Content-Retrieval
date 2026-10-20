import 'dart:math';
import 'image_feature.dart';

class VectorHit {
  const VectorHit(this.key, this.score);
  final String key;
  final double score;
}

/// 纯 Dart 内存索引：依赖特征自身的 cosineSimilarity。
class VectorIndex {
  final Map<String, ImageFeature> _items = {};

  void add(String key, ImageFeature f) => _items[key] = f;

  int get size => _items.length;

  List<VectorHit> search(ImageFeature query, {int? k}) {
    final scored = _items.entries
        .map((e) => (key: e.key, score: query.cosineSimilarity(e.value)))
        .where((e) => e.score.isFinite)
        .toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    final limit = k ?? scored.length;
    return scored
        .take(min(limit, scored.length))
        .map((e) => VectorHit(e.key, e.score))
        .toList();
  }
}
