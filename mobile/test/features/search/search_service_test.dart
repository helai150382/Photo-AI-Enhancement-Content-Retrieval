import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/search_service.dart';

void main() {
  test('蓝色优先查询返回蓝色图', () async {
    final svc = SearchService()
      ..indexPhoto('img_red', _solid(255, 0, 0), 1, 1)
      ..indexPhoto('img_blue', _solid(0, 0, 255), 1, 1);
    final hits = await svc.searchText('找蓝色照片');
    expect(hits.first.key, 'img_blue');
    expect(hits.first.score, greaterThan(0.5));
  });
}

Uint8List _solid(int r, int g, int b) {
  final buf = Uint8List(4);
  buf[0] = r;
  buf[1] = g;
  buf[2] = b;
  buf[3] = 255;
  return buf;
}
