import 'package:photomanager/features/conversation/domain/conversation_message.dart';
import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class SaveMessageUseCase {
  const SaveMessageUseCase(this._repository);

  final ConversationRepository _repository;

  Future<void> call(ConversationMessage message) {
    return _repository.saveMessage(message);
  }
}
