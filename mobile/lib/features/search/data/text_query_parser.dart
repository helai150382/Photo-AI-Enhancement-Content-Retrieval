class QueryCondition {
  const QueryCondition({this.colorBucket, this.semanticTag});

  /// 归一化三维颜色（R,G,B 各 0-1），查询特征用其映射颜色桶。
  final List<double>? colorBucket;

  /// MVP 恒为 null；二期接入语义 embedding 后填充。
  final String? semanticTag;
}

class TextQueryParser {
  static const _colorWords = <String, List<double>>{
    '红': [1, 0, 0],
    '蓝': [0, 0, 1],
    '绿': [0, 1, 0],
    '天蓝': [0.4, 0.7, 1],
    '白': [1, 1, 1],
    '黑': [0, 0, 0],
    '夕阳': [1, 0.5, 0.2],
    '海': [0.2, 0.5, 0.9],
    '海蓝': [0.1, 0.4, 0.9],
    '日落': [1, 0.55, 0.2],
  };

  QueryCondition parse(String text) {
    List<double>? color;
    for (final e in _colorWords.entries) {
      if (text.contains(e.key)) {
        color = e.value;
        break;
      }
    }
    return QueryCondition(colorBucket: color);
  }
}
