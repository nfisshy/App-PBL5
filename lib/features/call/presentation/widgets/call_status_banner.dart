import 'package:flutter/material.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

class CallStatusBanner extends StatelessWidget {
  const CallStatusBanner({
    required this.status,
    super.key,
  });

  final CallStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

extension CallStatusLabel on CallStatus {
  String get label => switch (this) {
        CallStatus.idle => 'Idle',
        CallStatus.calling => 'Calling...',
        CallStatus.incoming => 'Incoming Call',
        CallStatus.ringing => 'Ringing...',
        CallStatus.accepted => 'Connected',
        CallStatus.rejected => 'Rejected',
        CallStatus.ended => 'Ended',
        CallStatus.missed => 'Missed Call',
      };
}
