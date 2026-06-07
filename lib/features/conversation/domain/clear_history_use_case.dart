import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class ClearHistoryUseCase {
  const ClearHistoryUseCase(this._repository);

  final ConversationRepository _repository;

  Future<void> call() {
    return _repository.clearAllHistory();
  }
}
