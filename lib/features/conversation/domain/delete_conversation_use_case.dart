import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class DeleteConversationUseCase {
  const DeleteConversationUseCase(this._repository);

  final ConversationRepository _repository;

  Future<void> call(String conversationId) {
    return _repository.deleteConversation(conversationId);
  }
}
