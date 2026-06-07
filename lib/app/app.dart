import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/app/router/app_router.dart';
import 'package:photomanager/app/theme/app_theme.dart';
import 'package:photomanager/core/constants/app_constants.dart';
import 'package:photomanager/shared/providers/dependency_providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add startup initialization here when infrastructure is implemented.
  runApp(
    ProviderScope(
      overrides: buildDependencyOverrides(),
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
