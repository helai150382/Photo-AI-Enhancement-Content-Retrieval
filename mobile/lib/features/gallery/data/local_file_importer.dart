import 'dart:typed_data';

import '../models/photo_data.dart';
import 'image_codec.dart';

/// 一个待导入文件。
class ImportFile {
  const ImportFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// 将浏览器本地文件字节解码为 [PhotoData] 列表。
class LocalFileImporter {
  const LocalFileImporter();

  Future<List<PhotoData>> importFiles(List<ImportFile> files) async {
    final out = <PhotoData>[];
    var seq = 0;
    for (final f in files) {
      final d = decodeToRgba(f.bytes);
      if (d == null) continue;
      final thumb = makeThumbnail(d.rgba, d.width, d.height) ?? d;
      final now = DateTime.now();
      final key = 'up_${now.year}${_p2(now.month)}${_p2(now.day)}_'
          '${_p2(now.hour)}${_p2(now.minute)}${_p2(now.second)}_${seq++}';
      out.add(PhotoData(
        key: key,
        name: f.name,
        rgba: d.rgba,
        width: d.width,
        height: d.height,
        thumbnail: thumb.rgba,
        thumbWidth: thumb.width,
        thumbHeight: thumb.height,
      ));
    }
    return out;
  }

  String _p2(int v) => v.toString().padLeft(2, '0');
}
