typedef Pixel = List<int>;

/// 裁剪 [grid] 中以 (row, col) 为左上角、rows x cols 大小的区域。
///
/// 返回浅拷贝，像素列表与原网格共享元素。
/// 任一参数为负时抛 [ArgumentError]。
List<List<Pixel>> cropPixels(
  List<List<Pixel>> grid, {
  required int row,
  required int col,
  required int rows,
  required int cols,
}) {
  if (row < 0 || col < 0 || rows < 0 || cols < 0) {
    final bad = <String>[
      if (row < 0) 'row',
      if (col < 0) 'col',
      if (rows < 0) 'rows',
      if (cols < 0) 'cols',
    ].join(', ');
    throw ArgumentError('参数不允许为负: $bad');
  }
  final out = <List<Pixel>>[];
  for (var y = row; y < row + rows && y < grid.length; y++) {
    final r = <Pixel>[];
    for (var x = col; x < col + cols && x < grid[y].length; x++) {
      r.add(grid[y][x]);
    }
    if (r.isNotEmpty) out.add(r);
  }
  return out;
}
