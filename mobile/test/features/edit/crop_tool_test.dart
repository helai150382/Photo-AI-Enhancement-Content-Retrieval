import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/edit/data/crop_tool.dart';

void main() {
  test('裁剪输出指定区域', () {
    final grid = <List<List<int>>>[
      [
        [1, 1, 1],
        [2, 2, 2],
        [3, 3, 3]
      ],
      [
        [4, 4, 4],
        [5, 5, 5],
        [6, 6, 6]
      ],
      [
        [7, 7, 7],
        [8, 8, 8],
        [9, 9, 9]
      ],
    ];
    final cropped = cropPixels(grid, row: 0, col: 0, rows: 2, cols: 2);
    expect(cropped.length, 2);
    expect(cropped[0].length, 2);
    expect(cropped[0][0], equals([1, 1, 1]));
    expect(cropped[1][1], equals([5, 5, 5]));
  });
}
