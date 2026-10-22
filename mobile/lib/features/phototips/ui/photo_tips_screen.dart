import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../gallery/data/image_codec.dart';
import '../data/photo_analyzer.dart';
import '../data/photo_tips_content.dart';

/// 美女拍照小技巧：图文技巧 + 上传照片自动给出拍照建议。
class PhotoTipsScreen extends StatefulWidget {
  const PhotoTipsScreen({super.key});

  @override
  State<PhotoTipsScreen> createState() => _PhotoTipsScreenState();
}

class _PhotoTipsScreenState extends State<PhotoTipsScreen> {
  PhotoAnalysisReport? _analysis;
  Uint8List? _previewPng;
  bool _busy = false;

  Future<void> _upload() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'],
    );
    final files = await openFiles(acceptedTypeGroups: const [typeGroup]);
    if (files.isEmpty) return;
    setState(() => _busy = true);
    final bytes = await files.first.readAsBytes();
    final src = decodeToRgba(bytes);
    if (src == null) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('未能解析所选图片')));
      }
      return;
    }
    // 先用缩略图做轻量分析，避免大图遍历过慢。
    final thumb = (src.width > 256 || src.height > 256)
        ? (makeThumbnail(src.rgba, src.width, src.height) ?? src)
        : src;
    final report = PhotoAnalyzer().analyze(thumb.rgba, thumb.width, thumb.height);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _analysis = report;
      _previewPng = encodePng(thumb.rgba, thumb.width, thumb.height);
    });
  }

  Color _levelColor(PhotoMetricLevel level) => switch (level) {
        PhotoMetricLevel.good => Colors.green,
        PhotoMetricLevel.warn => Colors.orange,
        PhotoMetricLevel.bad => Colors.red,
      };

  void _showDetail(PhotoTipCard card) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  card.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => SizedBox(
                    height: 160,
                    child: ColoredBox(
                      color: Colors.blueGrey.shade200,
                      child: const Center(child: Text('图片加载失败')),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(card.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(card.category,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
              const SizedBox(height: 10),
              Text(card.body,
                  style: const TextStyle(height: 1.6, fontSize: 14)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _analysisCard() {
    final analysis = _analysis;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('上传照片，获取拍照建议',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                FilledButton.icon(
                  onPressed: _busy ? null : _upload,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('上传分析'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '上传一张女孩照片（或任意自拍），系统会从亮度、对比度、肤色等维度给出提升拍照效果的建议。',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            if (_previewPng != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _previewPng!,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: analysis == null
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final m in analysis.metrics)
                                Chip(
                                  label: Text(
                                      '${m.label} ${m.value}'),
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: _levelColor(m.level)),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: _levelColor(m.level)
                                      .withValues(alpha: 0.08),
                                  side: BorderSide(
                                      color: _levelColor(m.level),
                                      width: 0.8),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
              if (analysis != null && analysis.suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final s in analysis.suggestions)
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    color: s.severity == SuggestionSeverity.warn
                        ? Colors.orange.withValues(alpha: 0.06)
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        s.severity == SuggestionSeverity.warn
                            ? Icons.warning_amber_rounded
                            : Icons.tips_and_updates_outlined,
                        color: s.severity == SuggestionSeverity.warn
                            ? Colors.orange
                            : Colors.deepPurple,
                      ),
                      title: Text(s.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(s.advice,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('美女拍照小技巧')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _analysisCard(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('拍照技巧（图文）',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 3 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.92,
                children: [
                  for (final card in kPhotoTips) _tipCard(card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tipCard(PhotoTipCard card) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showDetail(card),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  card.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: Colors.blueGrey.shade200,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.category,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
