import 'package:photomanager/features/conversation/domain/conversation_history.dart';
import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class GetAllConversationsUseCase {
  const GetAllConversationsUseCase(this._repository);

  final ConversationRepository _repository;

  Future<List<ConversationHistory>> call() {
    return _repository.getAllConversations();
  }
}
