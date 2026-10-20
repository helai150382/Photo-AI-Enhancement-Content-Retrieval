import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../data/search_service.dart';
import '../../gallery/data/gallery_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = SearchService();
  final _gallery = GalleryRepository();
  List<SearchHit> _results = const [];
  bool _loading = false;

  Future<void> _search() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    setState(() => _loading = true);
    final hits = await _service.searchText(text);
    if (!mounted) return;
    setState(() {
      _results = hits;
      _loading = false;
    });
  }

  Widget _resultTile(SearchHit r) {
    final Uint8List? thumb = _gallery.thumbnailFor(r.key);
    if (thumb != null) {
      return Image.memory(thumb, fit: BoxFit.cover);
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      return _resultTile(_results[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
