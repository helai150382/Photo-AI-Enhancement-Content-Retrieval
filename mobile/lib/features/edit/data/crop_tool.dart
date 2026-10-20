typedef Pixel = List<int>;

List<List<Pixel>> cropPixels(
  List<List<Pixel>> grid, {
  required int row,
  required int col,
  required int rows,
  required int cols,
}) {
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
