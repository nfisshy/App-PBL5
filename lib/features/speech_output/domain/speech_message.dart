import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';

class SpeechMessage {
  const SpeechMessage({
    required this.messageId,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  final String messageId;
  final String text;
  final SpeechMessageType type;
  final DateTime createdAt;
}
