import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../data/demo_media_importer.dart';
import '../data/image_codec.dart';
import '../data/local_file_importer.dart';
import '../models/photo_data.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, required this.state});

  final AppState state;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _busy = false;

  Future<void> _upload() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'],
    );
    final files = await openFiles(acceptedTypeGroups: const [typeGroup]);
    if (files.isEmpty) return;
    final items = <PhotoData>[];
    for (final f in files) {
      final bytes = await f.readAsBytes();
      items.addAll(await const LocalFileImporter().importFiles([
        ImportFile(name: f.name, bytes: bytes),
      ]));
    }
    if (items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('未能解析所选图片')));
      }
      return;
    }
    widget.state.addPhotos(items);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加 ${items.length} 张图片')),
      );
    }
  }

  Future<void> _loadDemo() async {
    setState(() => _busy = true);
    final items = await const DemoMediaImporter().loadDemo();
    widget.state.addPhotos(items);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相册')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _upload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('上传图片'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _loadDemo,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('加载示例图'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.state,
              builder: (context, _) {
                final photos = widget.state.all();
                if (photos.isEmpty) {
                  return const Center(child: Text('还没有图片，点上方按钮上传或加载示例'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (_, i) {
                    final p = photos[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        encodePng(p.thumbnail, p.thumbWidth, p.thumbHeight),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
