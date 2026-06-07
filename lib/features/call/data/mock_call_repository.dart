import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/call_repository.dart';
import 'package:photomanager/features/call/domain/call_state.dart';
import 'package:photomanager/features/call/domain/conversation_message.dart';

class MockCallRepository implements CallRepository {
  static const _participants = {
    'dat': CallParticipant(
      username: 'dat',
      displayName: 'Nguyen Tien Dat',
    ),
    'linh': CallParticipant(
      username: 'linh',
      displayName: 'Tran Thi Linh',
    ),
    'an': CallParticipant(
      username: 'an',
      displayName: 'Le Van An',
    ),
    'minh': CallParticipant(
      username: 'minh',
      displayName: 'Pham Duc Minh',
    ),
  };

  static const _messages = [
    ConversationMessage(sender: 'HUY', text: 'Xin chào'),
    ConversationMessage(sender: 'DAT', text: 'Chào bạn'),
    ConversationMessage(sender: 'HUY', text: 'Bạn khỏe không?'),
  ];

  @override
  Future<CallState?> getCallState(String username) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final participant = _participants[username];
    if (participant == null) {
      return null;
    }

    return CallState(
      participant: participant,
      messages: List<ConversationMessage>.unmodifiable(_messages),
    );
  }
}
