import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/photo_cubit.dart';

import 'album_tab.dart';
import 'home_tab.dart';
import 'setting_tab.dart';
import 'tool_tab.dart';

import '../Widgets/header.dart';
import '../Widgets/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {
  int currentIndex = 0;

  late final PageController
      _pageController;

  final pages = const [
    HomeTab(),
    SettingsTab(),
    AlbumTab(),
    ToolTab(),
  ];

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(
          initialPage: currentIndex,
        );

    /// =========================
    /// LOAD HOME RECENT STATUS
    /// =========================
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<PhotoCubit>()
          .loadRecentHomeStatus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _changePage(int index) {
    setState(() {
      currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(
        milliseconds: 280,
      ),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFE8DC),

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            /// HEADER
            const AppHeader(),

            /// PAGE VIEW
            Expanded(
              child: PageView(
                controller:
                    _pageController,

                physics:
                    const BouncingScrollPhysics(),

                onPageChanged: (
                  index,
                ) {
                  setState(() {
                    currentIndex =
                        index;
                  });

                  /// refresh recent status
                  context
                      .read<PhotoCubit>()
                      .loadRecentHomeStatus();
                },

                children: pages,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          CustomBottomNavBar(
        currentIndex: currentIndex,

        onTap: (index) {
          _changePage(index);
        },
      ),
    );
  }
}