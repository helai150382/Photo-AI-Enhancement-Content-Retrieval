import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/search_service.dart';

void main() {
  test('索引 10000 张后单次检索 < 2 秒', () async {
    final rng = Random(42);
    final svc = SearchService();
    for (var i = 0; i < 10000; i++) {
      final buf = Uint8List(4);
      buf[0] = rng.nextInt(256);
      buf[1] = rng.nextInt(256);
      buf[2] = rng.nextInt(256);
      svc.indexPhoto('p$i', buf, 1, 1);
    }
    final sw = Stopwatch()..start();
    final hits = await svc.searchText('找蓝色照片');
    final ms = sw.elapsedMilliseconds;
    expect(hits, isNotEmpty);
    expect(ms, lessThan(2000), reason: '检索耗时 ${ms}ms');
  });
}
