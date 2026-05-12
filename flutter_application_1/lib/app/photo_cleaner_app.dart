import 'package:flutter/material.dart';

import '../features/shell/main_shell.dart';
import '../shared/streak/streak_controller.dart';
import '../shared/streak/streak_scope.dart';

class PhotoCleanerApp extends StatelessWidget {
  const PhotoCleanerApp({super.key, required this.streakController});

  final StreakController streakController;

  @override
  Widget build(BuildContext context) {
    return StreakScope(
      controller: streakController,
      child: MaterialApp(
        title: 'Photo Cleaner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MainShell(),
      ),
    );
  }
}
