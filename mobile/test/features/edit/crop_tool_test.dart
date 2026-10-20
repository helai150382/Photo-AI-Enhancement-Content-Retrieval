import 'package:flutter_test/flutter_test.dart';
import 'package:ai_photo_app/features/edit/data/crop_tool.dart';

void main() {
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

  test('裁剪输出指定区域', () {
    final cropped = cropPixels(grid, row: 0, col: 0, rows: 2, cols: 2);
    expect(cropped.length, 2);
    expect(cropped[0].length, 2);
    expect(cropped[0][0], equals([1, 1, 1]));
    expect(cropped[1][1], equals([5, 5, 5]));
  });

  test('正向越界截断返回右下角 2x2', () {
    final cropped = cropPixels(grid, row: 1, col: 1, rows: 5, cols: 5);
    expect(cropped.length, 2);
    expect(cropped[0].length, 2);
    expect(cropped[0][0], equals([5, 5, 5]));
    expect(cropped[0][1], equals([6, 6, 6]));
    expect(cropped[1][0], equals([8, 8, 8]));
    expect(cropped[1][1], equals([9, 9, 9]));
  });

  test('负参数抛 ArgumentError', () {
    expect(
      () => cropPixels(grid, row: -1, col: 0, rows: 1, cols: 1),
      throwsArgumentError,
    );
    expect(
      () => cropPixels(grid, row: 0, col: -1, rows: 1, cols: 1),
      throwsArgumentError,
    );
    expect(
      () => cropPixels(grid, row: 0, col: 0, rows: -1, cols: 1),
      throwsArgumentError,
    );
    expect(
      () => cropPixels(grid, row: 0, col: 0, rows: 1, cols: -1),
      throwsArgumentError,
    );
  });

  test('完全越界返回空列表', () {
    final cropped = cropPixels(grid, row: 10, col: 10, rows: 2, cols: 2);
    expect(cropped, isEmpty);
  });
}
