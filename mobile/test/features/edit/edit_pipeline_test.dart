import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/edit/data/edit_pipeline.dart';
import 'package:ai_photo_app/features/edit/data/filters.dart';

void main() {
  test('管线对 2x2 全黑 RGBA 应用亮化滤镜后非纯黑', () {
    final pipeline = EditPipeline();
    final input = Uint8List(2 * 2 * 4); // 全 0
    final filter = kBuiltInFilters.firstWhere((f) => f.name == '清新');
    final out = pipeline.applyRgba(input, 2, 2, filter);
    expect(out.length, input.length);
    expect(out[0], greaterThan(0));
    expect(out[1], greaterThan(0));
    expect(out[2], greaterThan(0));
  });
}
