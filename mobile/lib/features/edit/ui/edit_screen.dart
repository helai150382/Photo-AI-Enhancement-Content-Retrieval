import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../gallery/data/image_codec.dart';
import '../../gallery/models/photo_data.dart';
import '../data/browser_downloader.dart';
import '../data/edit_pipeline.dart';
import '../data/filters.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.state});

  final AppState state;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _pipeline = EditPipeline();
  PhotoFilterScheme _selected = kBuiltInFilters.first;
  String? _photoKey;
  Uint8List? _previewPng;

  /// 当前生效的待美化图片；_photoKey 失效时回退到第一张。
  PhotoData? _effectivePhoto(List<PhotoData> photos) {
    if (photos.isEmpty) return null;
    if (_photoKey != null) {
      for (final p in photos) {
        if (p.key == _photoKey) return p;
      }
    }
    return photos.first;
  }

  void _apply(PhotoData p) {
    final out = _pipeline.applyRgba(p.rgba, p.width, p.height, _selected);
    setState(() => _previewPng = encodePng(out, p.width, p.height));
  }

  void _download(PhotoData p) {
    final png = _previewPng;
    if (png == null) return;
    downloadPng(png, '${p.name}_${_selected.name}.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础美化')),
      body: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          final photos = widget.state.all();
          final current = _effectivePhoto(photos);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButton<String>(
                  value: current?.key,
                  isExpanded: true,
                  hint: const Text('选择要美化的图片'),
                  items: [
                    for (final p in photos)
                      DropdownMenuItem(
                        value: p.key,
                        child: Text(p.name,
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (k) => setState(() {
                    _photoKey = k;
                    _previewPng = null;
                  }),
                ),
              ),
              Expanded(
                child: _previewPng == null
                    ? const Center(child: Text('选择图片和滤镜后点「应用并预览」'))
                    : Center(
                        child: Image.memory(
                          _previewPng!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: kBuiltInFilters.length,
                  itemBuilder: (_, i) {
                    final f = kBuiltInFilters[i];
                    return Padding(
                      padding: const EdgeInsets.all(6),
                      child: ChoiceChip(
                        label: Text(f.name),
                        selected: f.name == _selected.name,
                        onSelected: (_) => setState(() => _selected = f),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            current == null ? null : () => _apply(current),
                        child: const Text('应用并预览'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (current == null || _previewPng == null)
                            ? null
                            : () => _download(current),
                        child: const Text('下载图片'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
