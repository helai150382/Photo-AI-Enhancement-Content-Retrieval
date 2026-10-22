import 'package:flutter/foundation.dart';

import '../features/gallery/models/photo_data.dart';
import '../features/search/data/search_service.dart';

/// 全局共享状态：照片集合 + 检索索引 + 变更通知。
class AppState extends ChangeNotifier {
  final List<PhotoData> _photos = [];
  final SearchService _search = SearchService();

  List<PhotoData> all() => List.unmodifiable(_photos);

  void addPhotos(List<PhotoData> items) {
    var changed = false;
    for (final p in items) {
      if (_photos.any((e) => e.key == p.key)) continue;
      _photos.add(p);
      _search.indexPhoto(p.key, p.rgba, p.width, p.height);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  PhotoData? photoByKey(String key) {
    for (final p in _photos) {
      if (p.key == key) return p;
    }
    return null;
  }

  Future<List<SearchHit>> search(String text) => _search.searchText(text);
}
