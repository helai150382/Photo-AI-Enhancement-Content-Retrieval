import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/core/result.dart';
import 'package:ai_photo_app/features/gallery/data/gallery_repository.dart';
import 'package:ai_photo_app/features/gallery/models/photo_model.dart';
import 'package:ai_photo_app/features/gallery/data/media_importer.dart';

class _FakeImporter implements MediaImporter {
  _FakeImporter(this.photos);
  final List<Photo> photos;
  @override
  Future<List<Photo>> import() async => photos;
}

void main() {
  test('Repository 接收导入结果并去除重复源路径', () async {
    final repo = GalleryRepository.withImporter(
      _FakeImporter([
        Photo(
            sourcePath: '/a.jpg',
            width: 1,
            height: 1,
            takenAt: DateTime(2024)),
        Photo(
            sourcePath: '/a.jpg',
            width: 1,
            height: 1,
            takenAt: DateTime(2024)),
      ]),
    );
    final result = await repo.importAndStore();
    expect(result, isA<Ok<String>>()); // 返回 human 摘要
    expect((result as Ok<String>).value, '新增 1 张，去重 1 张');
  });
}
