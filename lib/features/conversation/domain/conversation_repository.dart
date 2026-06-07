import 'package:photomanager/features/conversation/domain/conversation_history.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';

abstract interface class ConversationRepository {
  Future<void> saveMessage(ConversationMessage message);

  Future<List<ConversationMessage>> getConversationHistory(
    String conversationId,
  );

  Future<List<ConversationHistory>> getAllConversations();

  Future<void> deleteConversation(String conversationId);

  Future<void> clearAllHistory();
}
