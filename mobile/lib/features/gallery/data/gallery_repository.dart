import 'dart:typed_data';

import '../../../core/result.dart';
import '../models/photo_model.dart';
import 'demo_media_importer.dart';
import 'media_importer.dart';

class GalleryRepository {
  GalleryRepository() : _importer = const DemoMediaImporter(), persist = false;
  GalleryRepository.withImporter(this._importer, {this.persist = false});
  final MediaImporter _importer;
  final bool persist;

  final Map<String, Uint8List> _thumbnails = {};

  void registerThumbnail(String key, Uint8List bytes) {
    _thumbnails[key] = bytes;
  }

  Uint8List? thumbnailFor(String key) => _thumbnails[key];

  Future<Result<String>> importAndStore() async {
    try {
      final photos = await _importer.import();
      final seen = <String>{};
      final unique = <Photo>[];
      for (final p in photos) {
        if (seen.add(p.sourcePath)) unique.add(p);
      }
      return Ok('新增 ${unique.length} 张，去重 ${photos.length - unique.length} 张');
    } catch (e) {
      return Err('导入失败：$e');
    }
  }
}
