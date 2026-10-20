import 'package:flutter/material.dart';
import 'features/gallery/ui/gallery_screen.dart';
import 'features/search/ui/search_screen.dart';
import 'features/edit/ui/edit_screen.dart';

class AiPhotoApp extends StatelessWidget {
  const AiPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 识图P图',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _pages = [GalleryScreen(), SearchScreen(), EditScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.photo_library), label: '相册'),
          NavigationDestination(icon: Icon(Icons.search), label: '检索'),
          NavigationDestination(icon: Icon(Icons.auto_fix_high), label: '美化'),
        ],
      ),
    );
  }
}
