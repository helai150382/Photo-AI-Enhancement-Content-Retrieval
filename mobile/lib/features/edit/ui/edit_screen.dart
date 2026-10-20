import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../data/edit_pipeline.dart';
import '../data/filters.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});
  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  PhotoFilterScheme _selected = kBuiltInFilters.first;
  Uint8List? _preview;
  final _pipeline = EditPipeline();

  void _apply() {
    // 演示：生成一张 4x4 示例位图应用滤镜，产出自标准。
    final w = 4, h = 4;
    final src = Uint8List(w * h * 4);
    for (var i = 0; i < w * h; i++) {
      final o = i * 4;
      src[o] = 80; src[o + 1] = 160; src[o + 2] = 240; src[o + 3] = 255;
    }
    final out = _pipeline.applyRgba(src, w, h, _selected);
    setState(() => _preview = out);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础美化')),
      body: Column(
        children: [
          Expanded(
            child: _preview == null
                ? const Center(child: Text('选择滤镜后点「应用并预览」'))
                : SizedBox(
                    width: double.infinity,
                    child: Image.memory(_preview!),
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
                    onPressed: _apply,
                    child: const Text('应用并预览'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _preview == null
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已保存到相册（演示）')),
                            ),
                    child: const Text('保存到相册'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
