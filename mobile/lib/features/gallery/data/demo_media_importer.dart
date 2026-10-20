import '../models/photo_model.dart';
import 'media_importer.dart';

class DemoMediaImporter implements MediaImporter {
  const DemoMediaImporter();
  @override
  Future<List<Photo>> import() async => [
        Photo(
          sourcePath: 'demo:sunset',
          width: 800,
          height: 600,
          takenAt: DateTime(2024, 6, 1),
        ),
      ];
}
