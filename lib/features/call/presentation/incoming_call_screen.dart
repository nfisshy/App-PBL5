import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';
import 'package:photomanager/features/call/presentation/signaling/call_signaling_providers.dart';
import 'package:photomanager/features/call/presentation/widgets/incoming_call_card.dart';

class IncomingCallScreen extends ConsumerWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentCallSessionProvider);

    if (session == null || session.status != CallStatus.incoming) {
      return const Scaffold(
        body: Center(child: Text('No incoming call.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Call')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: IncomingCallCard(
                session: session,
                onAccept: () async {
                  await ref
                      .read(currentCallSessionProvider.notifier)
                      .acceptCall();
                  if (context.mounted) {
                    context.pushReplacement(
                      AppRoutes.callRoute(session.participantUsername),
                    );
                  }
                },
                onReject: () async {
                  await ref
                      .read(currentCallSessionProvider.notifier)
                      .rejectCall();
                  if (context.mounted) {
                    context.pop();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
