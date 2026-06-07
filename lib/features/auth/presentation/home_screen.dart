import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photomanager/app/router/app_routes.dart';
import 'package:photomanager/features/auth/presentation/auth_controller.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/presentation/signaling/call_signaling_providers.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/presentation/realtime_providers.dart';
import 'package:photomanager/features/realtime/presentation/widgets/connection_status_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final realtimeStatus = ref.watch(connectionStatusProvider).valueOrNull ??
        ConnectionStatus.disconnected;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.username ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _RealtimeStatusCard(status: realtimeStatus),
                const SizedBox(height: 12),
                _DevelopmentCallCard(
                  onSimulateIncoming: () async {
                    await ref
                        .read(currentCallSessionProvider.notifier)
                        .simulateIncomingCall(_developmentCaller);
                    if (context.mounted) {
                      context.push(AppRoutes.incomingCall);
                    }
                  },
                  onSimulateMissed: () async {
                    await ref
                        .read(currentCallSessionProvider.notifier)
                        .simulateMissedCall(_developmentCaller);
                  },
                ),
                const SizedBox(height: 32),
                _FeatureButton(
                  icon: Icons.contacts_outlined,
                  label: 'Contacts',
                  onPressed: () => context.push(AppRoutes.contacts),
                ),
                const SizedBox(height: 12),
                _FeatureButton(
                  icon: Icons.history_outlined,
                  label: 'Conversation History',
                  onPressed: () => context.push(AppRoutes.conversation),
                ),
                const SizedBox(height: 12),
                const _FeatureButton(
                  icon: Icons.person_outline,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _developmentCaller = CallParticipant(
  username: 'dat001',
  displayName: 'DAT',
);

class _DevelopmentCallCard extends StatelessWidget {
  const _DevelopmentCallCard({
    required this.onSimulateIncoming,
    required this.onSimulateMissed,
  });

  final VoidCallback onSimulateIncoming;
  final VoidCallback onSimulateMissed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Call Signaling Test',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onSimulateIncoming,
              child: const Text('Simulate Incoming Call'),
            ),
            OutlinedButton(
              onPressed: onSimulateMissed,
              child: const Text('Simulate Missed Call'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealtimeStatusCard extends StatelessWidget {
  const _RealtimeStatusCard({required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text('Realtime Status'),
            ),
            ConnectionStatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
