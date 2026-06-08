import 'package:photomanager/features/speech_output/domain/speech_message.dart';

class SpeechQueueItem {
  const SpeechQueueItem({
    required this.queueId,
    required this.message,
    required this.enqueuedAt,
  });

  final String queueId;
  final SpeechMessage message;
  final DateTime enqueuedAt;
}
