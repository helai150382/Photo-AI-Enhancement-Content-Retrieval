import '../models/photo_model.dart';

abstract class MediaImporter {
  Future<List<Photo>> import();
}
