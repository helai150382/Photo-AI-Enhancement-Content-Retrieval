import 'package:ai_photo_app/features/gallery/data/demo_media_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('示例图生成若干张可检索的 PhotoData', () async {
    final items = await const DemoMediaImporter().loadDemo();
    expect(items.length, greaterThanOrEqualTo(6));
    expect(items.first.key, startsWith('demo_'));
    expect(items.first.rgba.length, greaterThan(0));
  });
}
