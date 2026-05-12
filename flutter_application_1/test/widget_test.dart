import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/app/photo_cleaner_app.dart';
import 'package:flutter_application_1/shared/streak/streak_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Loads shell with streak header and navigation', (tester) async {
    final streakController = StreakController();
    await streakController.load();
    await tester.pumpWidget(
      PhotoCleanerApp(streakController: streakController),
    );
    await tester.pumpAndSettle();

    expect(find.text('photocleaner'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // streak pill initial
  });
}
