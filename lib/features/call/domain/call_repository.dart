import 'package:photomanager/features/call/domain/call_state.dart';

abstract interface class CallRepository {
  Future<CallState?> getCallState(String username);
}
