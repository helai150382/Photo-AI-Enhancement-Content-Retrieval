import 'dart:typed_data';

import 'package:ai_photo_app/core/app_state.dart';
import 'package:ai_photo_app/features/gallery/models/photo_data.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _rgba(int r, int g, int b, {int n = 4}) {
  final out = Uint8List(n * n * 4);
  for (var i = 0; i < n * n; i++) {
    out[i * 4] = r;
    out[i * 4 + 1] = g;
    out[i * 4 + 2] = b;
    out[i * 4 + 3] = 255;
  }
  return out;
}

PhotoData solid(String key, int r, int g, int b) => PhotoData(
      key: key,
      name: key,
      rgba: _rgba(r, g, b),
      width: 4,
      height: 4,
      thumbnail: _rgba(r, g, b, n: 2),
      thumbWidth: 2,
      thumbHeight: 2,
    );

void main() {
  test('addPhotos 建立索引并通知监听者', () {
    final state = AppState();
    var notified = 0;
    state.addListener(() => notified++);
    state.addPhotos([solid('red', 255, 0, 0), solid('blue', 0, 0, 255)]);
    expect(notified, 1);
    expect(state.all(), hasLength(2));
  });

  test('search 返回颜色匹配结果并可回查图片', () async {
    final state = AppState()
      ..addPhotos([solid('red', 255, 0, 0), solid('blue', 0, 0, 255)]);
    final hits = await state.search('蓝色');
    expect(hits, isNotEmpty);
    expect(hits.first.key, 'blue');
    expect(state.photoByKey('blue'), isNotNull);
    expect(state.photoByKey('nope'), isNull);
  });

  test('重复 key 不重复入列表', () {
    final state = AppState();
    state.addPhotos([solid('a', 1, 1, 1)]);
    state.addPhotos([solid('a', 1, 1, 1)]);
    expect(state.all(), hasLength(1));
  });
}
