import '../models/photo_data.dart';
import 'image_codec.dart';

/// 内置示例图兜底：程序化生成多色渐变图，保证无上传图片时功能可演示。
class DemoMediaImporter {
  const DemoMediaImporter();

  Future<List<PhotoData>> loadDemo() async {
    return buildDemoImages().map((e) {
      final d = decodeToRgba(e.$2)!;
      final thumb = makeThumbnail(d.rgba, d.width, d.height) ?? d;
      return PhotoData(
        key: e.$1,
        name: e.$1,
        rgba: d.rgba,
        width: d.width,
        height: d.height,
        thumbnail: thumb.rgba,
        thumbWidth: thumb.width,
        thumbHeight: thumb.height,
      );
    }).toList();
  }
}
