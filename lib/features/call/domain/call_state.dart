import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/conversation_message.dart';

class CallState {
  const CallState({
    required this.participant,
    required this.messages,
    this.isMicEnabled = true,
  });

  final bool isMicEnabled;
  final CallParticipant participant;
  final List<ConversationMessage> messages;

  CallState copyWith({
    bool? isMicEnabled,
    CallParticipant? participant,
    List<ConversationMessage>? messages,
  }) {
    return CallState(
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      participant: participant ?? this.participant,
      messages: messages ?? this.messages,
    );
  }
}
