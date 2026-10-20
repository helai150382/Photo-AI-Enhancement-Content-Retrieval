import 'package:flutter/material.dart';
import '../data/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = SearchService();
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
                      final r = _results[i];
                      return Card(
                        child: Center(
                          child: Text(
                              '${r.key}\n${(r.score * 100).toStringAsFixed(0)}%'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
