import 'package:photomanager/features/realtime/domain/realtime_event_type.dart';

class RealtimeEvent {
  const RealtimeEvent({
    required this.eventId,
    required this.timestamp,
    required this.type,
    required this.payload,
  });

  final String eventId;
  final DateTime timestamp;
  final RealtimeEventType type;
  final Map<String, Object?> payload;
}
