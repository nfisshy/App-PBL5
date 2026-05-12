import 'package:flutter/material.dart';

import '../../shared/widgets/photocleaner_header.dart';
import '../settings/settings_tab.dart';
import '../tabs/middle_placeholder_tab.dart';
import '../tabs/swipe_entry_tab.dart';

/// Shell một màn hình với [NavigationBar]; header chung PhotoCleaner + streak.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PhotoCleanerHeader(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                SwipeEntryTab(),
                MiddlePlaceholderTab(),
                SettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Ảnh',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
