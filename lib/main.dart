import 'package:flutter/material.dart';

import 'Tabs/mainscreen.dart';
import 'Tabs/recents_noti.dart';
import 'Widgets/streak/streak_scope.dart';
import 'Widgets/streak/streak_controller.dart';

void main() {
  runApp(
    StreakScope(
      controller: StreakController(),
      child: const PhotoApp(),
    ),
  );
}

class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhotoApp',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
      ),
      home: const MainScreen(),
    );
  }
}