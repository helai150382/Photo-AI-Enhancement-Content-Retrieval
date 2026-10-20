import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/gallery/models/photo_model.dart';

void main() {
  test('Photo 正确构造与序列化', () {
    final p = Photo(
      id: 1,
      sourcePath: '/img/a.jpg',
      width: 100,
      height: 80,
      takenAt: DateTime(2024, 1, 1),
      thumbnailPath: '/thumb/a.jpg',
    );
    expect(p.width, 100);
    expect(p.height, 80);
    expect(p.takenAt, DateTime(2024, 1, 1));
    final map = p.toMap();
    expect(map['source_path'], '/img/a.jpg');
    expect(Photo.fromMap(map).width, 100);
  });
}
