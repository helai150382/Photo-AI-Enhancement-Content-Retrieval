class PhotoFilterScheme {
  const PhotoFilterScheme({
    required this.name,
    required this.brightness,
    required this.saturation,
    required this.contrast,
  });
  final String name;
  final double brightness; // -50..50
  final double saturation; // 0..3
  final double contrast; // 0.5..2
}

const kBuiltInFilters = <PhotoFilterScheme>[
  PhotoFilterScheme(name: '原图', brightness: 0, saturation: 1.0, contrast: 1.0),
  PhotoFilterScheme(name: '清新', brightness: 8, saturation: 1.15, contrast: 1.05),
  PhotoFilterScheme(name: '复古', brightness: -6, saturation: 0.8, contrast: 1.2),
  PhotoFilterScheme(name: '黑白', brightness: 0, saturation: 0.0, contrast: 1.1),
];
