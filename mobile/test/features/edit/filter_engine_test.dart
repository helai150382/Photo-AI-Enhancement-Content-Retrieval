import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/edit/data/filter_engine.dart';
import 'package:ai_photo_app/features/edit/data/filters.dart';

void main() {
  test('亮度提升后像素更亮', () {
    final engine = FilterEngine();
    final src = [
      [120, 120, 120]
    ];
    final out = engine.applyBrightness(src, 30);
    expect(out[0][0], greaterThan(120));
  });

  test('内置滤镜列表非空', () {
    expect(kBuiltInFilters, isNotEmpty);
    expect(kBuiltInFilters.first.name, isNotEmpty);
  });
}
