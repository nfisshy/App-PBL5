import 'package:flutter/material.dart';
import 'package:photomanager/core/constants/app_constants.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppConstants.appName),
            SizedBox(height: 24),
            AppLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
