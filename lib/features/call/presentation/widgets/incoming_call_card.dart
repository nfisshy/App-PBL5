import 'package:flutter/material.dart';
import 'package:photomanager/features/call/domain/signaling/call_session.dart';
import 'package:photomanager/features/call/presentation/widgets/call_action_button.dart';

class IncomingCallCard extends StatelessWidget {
  const IncomingCallCard({
    required this.session,
    required this.onAccept,
    required this.onReject,
    super.key,
  });

  final CallSession session;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              child: Text(
                session.participantDisplayName.characters.first,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              session.participantDisplayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text('@${session.participantUsername}'),
            const SizedBox(height: 28),
            Row(
              children: [
                CallActionButton(
                  icon: Icons.call,
                  label: 'Accept',
                  color: Colors.green,
                  onPressed: onAccept,
                ),
                const SizedBox(width: 12),
                CallActionButton(
                  icon: Icons.call_end,
                  label: 'Reject',
                  color: Theme.of(context).colorScheme.error,
                  onPressed: onReject,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
