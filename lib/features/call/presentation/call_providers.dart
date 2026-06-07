import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/features/call/data/mock_call_repository.dart';
import 'package:photomanager/features/call/domain/call_repository.dart';
import 'package:photomanager/features/call/domain/call_state.dart';
import 'package:photomanager/features/call/domain/get_call_state_use_case.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return MockCallRepository();
});

final getCallStateUseCaseProvider = Provider<GetCallStateUseCase>((ref) {
  return GetCallStateUseCase(ref.watch(callRepositoryProvider));
});

final callStateProvider = StateNotifierProvider.autoDispose
    .family<CallController, AsyncValue<CallState?>, String>((ref, username) {
  return CallController(
    username: username,
    getCallState: ref.watch(getCallStateUseCaseProvider),
  );
});

class CallController extends StateNotifier<AsyncValue<CallState?>> {
  CallController({
    required String username,
    required GetCallStateUseCase getCallState,
  })  : _username = username,
        _getCallState = getCallState,
        super(const AsyncValue.loading()) {
    load();
  }

  final String _username;
  final GetCallStateUseCase _getCallState;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getCallState(_username));
  }

  void toggleMic() {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isMicEnabled: !currentState.isMicEnabled),
    );
  }
}
