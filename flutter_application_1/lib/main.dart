import 'package:flutter/material.dart';

import 'app/photo_cleaner_app.dart';
import 'shared/streak/streak_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final streakController = StreakController();
  await streakController.load();
  runApp(PhotoCleanerApp(streakController: streakController));
}
