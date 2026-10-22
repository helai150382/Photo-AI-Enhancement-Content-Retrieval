import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../gallery/data/image_codec.dart';
import '../data/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<SearchHit> _results = const [];
  bool _loading = false;

  Future<void> _search() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    setState(() => _loading = true);
    final hits = await widget.state.search(text);
    if (!mounted) return;
    setState(() {
      _results = hits;
      _loading = false;
    });
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
    // 图片已不在集合中时回退为分数色块。
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
      appBar: AppBar(title: const Text('对话检索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: '例如：找蓝色的照片 / 找海边的图片',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loading ? null : _search,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
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
      ),
    );
  }
}
