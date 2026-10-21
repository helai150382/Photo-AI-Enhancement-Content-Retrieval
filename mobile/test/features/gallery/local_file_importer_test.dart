import 'dart:typed_data';

import 'package:ai_photo_app/features/gallery/data/local_file_importer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('导入器将字节解码为 PhotoData（含缩略图）', () async {
    final src = img.Image(width: 8, height: 6);
    img.fillRect(
      src,
      x1: 0,
      y1: 0,
      x2: 8,
      y2: 6,
      color: img.ColorRgb8(0, 0, 255),
    );
    final png = Uint8List.fromList(img.encodePng(src));

    final items = await const LocalFileImporter().importFiles([
      ImportFile(name: 'a.png', bytes: png),
    ]);

    expect(items, hasLength(1));
    expect(items.first.key, startsWith('up_'));
    expect(items.first.name, 'a.png');
    expect(items.first.width, 8);
    expect(items.first.height, 6);
    expect(items.first.rgba.length, 8 * 6 * 4);
    expect(items.first.thumbnail.length, greaterThan(0));
  });

  test('非法字节返回空列表', () async {
    final items = await const LocalFileImporter().importFiles([
      ImportFile(name: 'bad.png', bytes: Uint8List.fromList([1, 2, 3])),
    ]);
    expect(items, isEmpty);
  });
}
