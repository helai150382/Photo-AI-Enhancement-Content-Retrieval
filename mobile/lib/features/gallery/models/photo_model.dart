class Photo {
  const Photo({
    this.id,
    required this.sourcePath,
    required this.width,
    required this.height,
    required this.takenAt,
    this.thumbnailPath,
    this.featureKey,
  });

  final int? id; // SQLite 自增主键
  final String sourcePath; // 本地原图路径
  final int width;
  final int height;
  final DateTime takenAt;
  final String? thumbnailPath;
  final String? featureKey; // 特征向量索引键

  Map<String, Object?> toMap() => {
        'id': id,
        'source_path': sourcePath,
        'width': width,
        'height': height,
        'taken_at': takenAt.toIso8601String(),
        'thumbnail_path': thumbnailPath,
        'feature_key': featureKey,
      };

  factory Photo.fromMap(Map<String, Object?> map) => Photo(
        id: map['id'] as int?,
        sourcePath: map['source_path'] as String,
        width: map['width'] as int,
        height: map['height'] as int,
        takenAt: DateTime.parse(map['taken_at'] as String),
        thumbnailPath: map['thumbnail_path'] as String?,
        featureKey: map['feature_key'] as String?,
      );
}
