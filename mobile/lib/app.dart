import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'features/annotate/ui/annotate_screen.dart';
import 'features/edit/ui/edit_screen.dart';
import 'features/gallery/ui/gallery_screen.dart';
import 'features/phototips/ui/photo_tips_screen.dart';
import 'features/search/ui/search_screen.dart';

class AiPhotoApp extends StatelessWidget {
  AiPhotoApp({super.key, AppState? state}) : state = state ?? AppState();

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 识图P图',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: HomeShell(state: state),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final _pages = <Widget>[
    GalleryScreen(state: widget.state),
    SearchScreen(state: widget.state),
    AnnotateScreen(state: widget.state),
    EditScreen(state: widget.state),
    const PhotoTipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final body = _pages[_index];
    if (!wide) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.photo_library), label: '相册'),
            NavigationDestination(icon: Icon(Icons.search), label: '检索'),
            NavigationDestination(icon: Icon(Icons.touch_app), label: '标注'),
            NavigationDestination(icon: Icon(Icons.auto_fix_high), label: '美化'),
            NavigationDestination(icon: Icon(Icons.camera_alt), label: '技巧'),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.photo_library), label: Text('相册')),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text('检索')),
              NavigationRailDestination(icon: Icon(Icons.touch_app), label: Text('标注')),
              NavigationRailDestination(icon: Icon(Icons.auto_fix_high), label: Text('美化')),
              NavigationRailDestination(icon: Icon(Icons.camera_alt), label: Text('技巧')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
