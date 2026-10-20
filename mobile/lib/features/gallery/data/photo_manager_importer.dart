import 'package:photo_manager/photo_manager.dart';
import '../models/photo_model.dart';
import 'media_importer.dart';

class PhotoManagerImporter implements MediaImporter {
  @override
  Future<List<Photo>> import() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) return const [];
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return const [];
    final assets = await albums.first.getAssetListPaged(
      page: 0,
      size: 10000,
    );
    final photos = <Photo>[];
    for (final a in assets) {
      final origin = await a.originFile;
      if (origin == null) continue;
      photos.add(Photo(
        sourcePath: origin.path,
        width: a.width,
        height: a.height,
        takenAt: a.createDateTime,
      ));
    }
    return photos;
  }
}
