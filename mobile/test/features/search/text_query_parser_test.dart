import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/search/data/text_query_parser.dart';

void main() {
  test('解析颜色词生成目标颜色向量', () {
    final q = TextQueryParser().parse('找海边的蓝色天空照片');
    expect(q.colorBucket, isNotNull);
    expect(q.colorBucket![2], greaterThan(0)); // 蓝色分量
  });

  test('无语义词时不出语义条件（MVP 定位）', () {
    final q = TextQueryParser().parse('找温馨的照片');
    expect(q.semanticTag, isNull);
  });
}
