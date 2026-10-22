import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../gallery/data/image_codec.dart';
import '../../gallery/models/photo_data.dart';
import '../../search/data/search_service.dart';

/// 标注检索：设置目标图片 → 拖拽框选标注 → 查找与标注区域内容相似的图片。
class AnnotateScreen extends StatefulWidget {
  const AnnotateScreen({super.key, required this.state});

  final AppState state;

  @override
  State<AnnotateScreen> createState() => _AnnotateScreenState();
}

class _AnnotateScreenState extends State<AnnotateScreen> {
  String? _photoKey;
  Rect? _region;
  List<SearchHit> _results = const [];

  /// 当前生效的目标图片；_photoKey 失效时回退到第一张。
  PhotoData? _effectivePhoto(List<PhotoData> photos) {
    if (photos.isEmpty) return null;
    if (_photoKey != null) {
      for (final p in photos) {
        if (p.key == _photoKey) return p;
      }
    }
    return photos.first;
  }

  void _selectPhoto(String? key) {
    setState(() {
      _photoKey = key;
      _region = null;
      _results = const [];
    });
  }

  void _onRegion(Rect? region) {
    setState(() {
      _region = region;
      _results = const [];
    });
  }

  void _search() {
    final p = widget.state.photoByKey(_photoKey ?? '');
    final region = _region;
    if (p == null || region == null) return;
    final w = p.width;
    final h = p.height;
    final x = (region.left * w).floor().clamp(0, w - 1).toInt();
    final y = (region.top * h).floor().clamp(0, h - 1).toInt();
    final rw = (region.width * w).ceil().clamp(1, w - x).toInt();
    final rh = (region.height * h).ceil().clamp(1, h - y).toInt();
    final cropped = cropRgba(p.rgba, w, h, x, y, rw, rh);
    if (cropped == null) {
      _showSnack('标注区域无效，请重新框选');
      return;
    }
    final hits = widget.state.searchRegion(cropped, rw, rh);
    setState(() => _results = hits);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _resultTile(SearchHit r) {
    final p = widget.state.photoByKey(r.key);
    if (p != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              encodePng(p.thumbnail, p.thumbWidth, p.thumbHeight),
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '${(r.score * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ColoredBox(
      color: Colors.blueGrey.shade200,
      child: Center(
        child: Text('${(r.score * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.black54)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('标注检索')),
      body: ListenableBuilder(
        listenable: widget.state,
        builder: (context, _) {
          final photos = widget.state.all();
          final current = _effectivePhoto(photos);
          if (current == null) {
            return const Center(child: Text('先去「相册」上传图片或加载示例图'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: DropdownButton<String>(
                  value: current.key,
                  isExpanded: true,
                  hint: const Text('选择目标图片'),
                  items: [
                    for (final p in photos)
                      DropdownMenuItem(
                        value: p.key,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: _selectPhoto,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: RegionSelector(
                    key: ValueKey(current.key),
                    pngBytes: encodePng(
                        current.thumbnail, current.thumbWidth, current.thumbHeight),
                    imageWidth: current.width,
                    imageHeight: current.height,
                    onRegion: _onRegion,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _region == null
                            ? '在图片上拖拽框选标注区域'
                            : '已框选区域，点击下方按钮检索相似图',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _region == null ? null : _search,
                      icon: const Icon(Icons.search),
                      label: const Text('检索相似'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text('框选标注后，将按区域颜色内容查找相似图片'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (_, i) => _resultTile(_results[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 可拖拽框选的目标图展示区。
/// [onRegion] 回调归一化矩形（各分量 0..1），框选被清空时回调 null。
class RegionSelector extends StatefulWidget {
  const RegionSelector({
    super.key,
    required this.pngBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.onRegion,
  });

  final Uint8List pngBytes;
  final int imageWidth;
  final int imageHeight;
  final ValueChanged<Rect?> onRegion;

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  static const double _maxDisplayHeight = 340;

  Rect? _region;
  Offset? _dragStart;

  void _normalizeAndEmit() {
    final region = _region;
    if (region == null || widget.imageWidth <= 0 || widget.imageHeight <= 0) {
      return;
    }
    if (region.width < 6 || region.height < 6) {
      widget.onRegion(null);
      return;
    }
    final left = (region.left / widget.imageWidth).clamp(0.0, 1.0);
    final top = (region.top / widget.imageHeight).clamp(0.0, 1.0);
    final right = (region.right / widget.imageWidth).clamp(0.0, 1.0);
    final bottom = (region.bottom / widget.imageHeight).clamp(0.0, 1.0);
    widget.onRegion(Rect.fromLTRB(left, top, right, bottom));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight.isFinite
            ? math.min(_maxDisplayHeight, constraints.maxHeight)
            : _maxDisplayHeight;
        final scale = math.min(
          maxW / widget.imageWidth,
          maxH / widget.imageHeight,
        );
        final dispW = widget.imageWidth * scale;
        final dispH = widget.imageHeight * scale;
        final region = _region;
        return SizedBox(
          width: dispW,
          height: dispH,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  widget.pngBytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (d) {
                    setState(() {
                      _dragStart = d.localPosition;
                      _region = Rect.fromPoints(d.localPosition, d.localPosition);
                    });
                  },
                  onPanUpdate: (d) {
                    final start = _dragStart;
                    if (start == null) return;
                    setState(() {
                      _region = Rect.fromPoints(start, d.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    _dragStart = null;
                    _normalizeAndEmit();
                  },
                ),
              ),
              if (region != null && region.width > 1 && region.height > 1)
                Positioned.fromRect(
                  rect: Rect.fromLTRB(
                    region.left,
                    region.top,
                    region.right,
                    region.bottom,
                  ),
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SelectionPainter(rect: Offset.zero & region.size),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({required this.rect});

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.lightBlue.withValues(alpha: 0.25);
    final border = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) =>
      oldDelegate.rect != rect;
}
