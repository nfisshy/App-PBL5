import 'package:flutter/material.dart';

import 'home_tab.dart';
import '../Widgets/navbar.dart';
import '../Widgets/header.dart';

import 'setting_tab.dart';
import 'album_tab.dart';
import 'tool_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late double _dragStartX;

  final pages = const [
    HomeTab(),
    SettingsTab(),
    AlbumTab(),
    ToolTab(),
  ];

  void _onHorizontalDrag(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const double dragThreshold = 50.0;

    final dragDistance =
        _dragStartX - details.globalPosition.dx;

    /// SWIPE LEFT
    if (dragDistance > dragThreshold &&
        currentIndex < pages.length - 1) {
      setState(() {
        currentIndex++;
      });
    }

    /// SWIPE RIGHT
    if (dragDistance < -dragThreshold &&
        currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8DC),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// HEADER FIXED
            const AppHeader(),

            /// CONTENT SCROLL
            Expanded(
              child: GestureDetector(
                onHorizontalDragStart:
                    _onHorizontalDrag,

                onHorizontalDragEnd:
                    _onHorizontalDragEnd,

                child: IndexedStack(
                  index: currentIndex,
                  children: pages,
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
      ),
    );
  }
}