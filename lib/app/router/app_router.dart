import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/auth/presentation/auth_controller.dart';
import 'package:photomanager/features/auth/presentation/home_screen.dart';
import 'package:photomanager/features/auth/presentation/login_screen.dart';
import 'package:photomanager/features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).user != null;

      if (state.matchedLocation == AppRoutes.home && !isAuthenticated) {
        return AppRoutes.login;
      }

      if (state.matchedLocation == AppRoutes.login && isAuthenticated) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // Register future feature routes here when their screens are implemented.
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
