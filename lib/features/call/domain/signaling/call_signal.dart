import 'package:photomanager/features/call/domain/signaling/call_signal_type.dart';

class CallSignal {
  const CallSignal({
    required this.signalId,
    required this.timestamp,
    required this.callerUsername,
    required this.callerDisplayName,
    required this.receiverUsername,
    required this.receiverDisplayName,
    required this.type,
  });

  final String signalId;
  final DateTime timestamp;
  final String callerUsername;
  final String callerDisplayName;
  final String receiverUsername;
  final String receiverDisplayName;
  final CallSignalType type;
}
