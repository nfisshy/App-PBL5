import 'package:photomanager/features/call/domain/call_repository.dart';
import 'package:photomanager/features/call/domain/call_state.dart';

class GetCallStateUseCase {
  const GetCallStateUseCase(this._repository);

  final CallRepository _repository;

  Future<CallState?> call(String username) {
    return _repository.getCallState(username);
  }
}
