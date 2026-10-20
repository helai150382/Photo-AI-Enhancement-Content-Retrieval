import 'dart:typed_data';
import 'color_histogram_feature.dart';
import 'vector_index.dart';
import 'text_query_parser.dart';

class SearchHit {
  const SearchHit(this.key, this.score);
  final String key;
  final double score;
}

/// 端侧检索编排：建索引 + 文本查询。
class SearchService {
  final VectorIndex _colorIndex = VectorIndex();
  final _parser = TextQueryParser();

  void indexPhoto(String key, Uint8List rgba, int w, int h) {
    final f = ColorHistogramFeature.fromImage(rgba, w, h);
    _colorIndex.add(key, f);
  }

  Future<List<SearchHit>> searchText(String text) async {
    final cond = _parser.parse(text);
    if (cond.colorBucket == null) return const [];
    final query = ColorHistogramFeature.fromColor(cond.colorBucket!);
    final hits = _colorIndex.search(query, k: 20);
    return hits.map((h) => SearchHit(h.key, h.score)).toList();
  }
}
