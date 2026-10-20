import 'dart:typed_data';
import 'filter_engine.dart';
import 'filters.dart';

class EditPipeline {
  final _engine = FilterEngine();

  /// 输入 RGBA 字节流，返回应用滤镜后的 RGBA 字节流。
  Uint8List applyRgba(Uint8List rgba, int w, int h, PhotoFilterScheme f) {
    final out = Uint8List(rgba.length);
    for (var i = 0; i < w * h; i++) {
      final o = i * 4;
      final res = _engine.applyPixel([rgba[o], rgba[o + 1], rgba[o + 2]], f);
      out[o] = res[0];
      out[o + 1] = res[1];
      out[o + 2] = res[2];
      out[o + 3] = rgba[o + 3];
    }
    return out;
  }
}
