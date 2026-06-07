import 'package:photomanager/features/call/domain/signaling/call_status.dart';

class CallSession {
  const CallSession({
    required this.sessionId,
    required this.participantUsername,
    required this.participantDisplayName,
    required this.status,
    required this.startedAt,
    this.endedAt,
  });

  final String sessionId;
  final String participantUsername;
  final String participantDisplayName;
  final CallStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;

  CallSession copyWith({
    CallStatus? status,
    DateTime? endedAt,
  }) {
    return CallSession(
      sessionId: sessionId,
      participantUsername: participantUsername,
      participantDisplayName: participantDisplayName,
      status: status ?? this.status,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
