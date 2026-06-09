import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/core/network/presentation/api_diagnostics_screen.dart';
import 'package:photomanager/features/audio_upload/presentation/audio_upload_diagnostics_screen.dart';
import 'package:photomanager/features/auth/presentation/auth_controller.dart';
import 'package:photomanager/features/auth/presentation/home_screen.dart';
import 'package:photomanager/features/auth/presentation/login_screen.dart';
import 'package:photomanager/features/call/presentation/call_screen.dart';
import 'package:photomanager/features/call/presentation/incoming_call_screen.dart';
import 'package:photomanager/features/contacts/presentation/contact_detail_screen.dart';
import 'package:photomanager/features/contacts/presentation/contacts_screen.dart';
import 'package:photomanager/features/conversation/presentation/conversation_history_detail_screen.dart';
import 'package:photomanager/features/conversation/presentation/history_screen.dart';
import 'package:photomanager/features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).user != null;

      final requiresAuthentication = state.matchedLocation == AppRoutes.home ||
          state.matchedLocation == AppRoutes.apiDiagnostics ||
          state.matchedLocation == AppRoutes.audioUploadDiagnostics ||
          state.matchedLocation.startsWith(AppRoutes.contacts) ||
          state.matchedLocation.startsWith('/call') ||
          state.matchedLocation == AppRoutes.incomingCall ||
          state.matchedLocation.startsWith(AppRoutes.conversation);

      if (requiresAuthentication && !isAuthenticated) {
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
      GoRoute(
        path: AppRoutes.apiDiagnostics,
        builder: (context, state) => const ApiDiagnosticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioUploadDiagnostics,
        builder: (context, state) => const AudioUploadDiagnosticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.contacts,
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactDetails,
        builder: (context, state) => ContactDetailScreen(
          username: state.pathParameters['username']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.call,
        builder: (context, state) => CallScreen(
          username: state.pathParameters['username']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.incomingCall,
        builder: (context, state) => const IncomingCallScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversation,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversationDetails,
        builder: (context, state) => ConversationHistoryDetailScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      // Register future feature routes here when their screens are implemented.
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
