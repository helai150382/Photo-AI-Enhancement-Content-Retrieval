import 'filters.dart';

typedef Pixel = List<int>; // [r,g,b]

class FilterEngine {
  Pixel applyPixel(Pixel p, PhotoFilterScheme f) {
    var r = p[0].toDouble();
    var g = p[1].toDouble();
    var b = p[2].toDouble();
    r += f.brightness;
    g += f.brightness;
    b += f.brightness;
    final l = 0.299 * r + 0.587 * g + 0.114 * b;
    r = l + (r - l) * f.saturation;
    g = l + (g - l) * f.saturation;
    b = l + (b - l) * f.saturation;
    r = (r - 128) * f.contrast + 128;
    g = (g - 128) * f.contrast + 128;
    b = (b - 128) * f.contrast + 128;
    int cl(double v) => v.round().clamp(0, 255).toInt();
    return [cl(r), cl(g), cl(b)];
  }

  List<Pixel> apply(List<Pixel> pixels, PhotoFilterScheme f) =>
      pixels.map((p) => applyPixel(p, f)).toList();

  List<Pixel> applyBrightness(List<Pixel> pixels, double delta) => apply(
        pixels,
        PhotoFilterScheme(
            name: '亮度', brightness: delta, saturation: 1, contrast: 1),
      );
}
