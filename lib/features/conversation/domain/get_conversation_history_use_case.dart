import 'package:photomanager/features/conversation/domain/conversation_message.dart';
import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class GetConversationHistoryUseCase {
  const GetConversationHistoryUseCase(this._repository);

  final ConversationRepository _repository;

  Future<List<ConversationMessage>> call(String conversationId) {
    return _repository.getConversationHistory(conversationId);
  }
}
