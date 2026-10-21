import 'dart:typed_data';

/// Web 场景下的图片数据单元：RGBA 像素 + 缩略图 + 元信息。
class PhotoData {
  const PhotoData({
    required this.key,
    required this.name,
    required this.rgba,
    required this.width,
    required this.height,
    required this.thumbnail,
    required this.thumbWidth,
    required this.thumbHeight,
  });

  /// 检索索引 key（如 'demo_0' / 'up_yyyymmdd_hhmmss'）。
  final String key;

  /// 展示名。
  final String name;

  /// 原始 RGBA 像素（宽 * 高 * 4 字节）。
  final Uint8List rgba;

  final int width;
  final int height;

  /// 缩略图 RGBA（最长边 ≤ 256px）。
  final Uint8List thumbnail;

  final int thumbWidth;
  final int thumbHeight;
}
