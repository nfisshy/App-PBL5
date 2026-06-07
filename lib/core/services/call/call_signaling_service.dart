import 'package:photomanager/features/call/domain/signaling/call_signal.dart';
import 'package:photomanager/features/call/domain/signaling/call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

class CallSignalingService {
  const CallSignalingService(this._repository);

  final CallSignalingRepository _repository;

  Future<void> startCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) {
    return _repository.startCall(
      callerUsername: callerUsername,
      callerDisplayName: callerDisplayName,
      receiverUsername: receiverUsername,
      receiverDisplayName: receiverDisplayName,
    );
  }

  Future<void> acceptCall(CallSignal signal) => _repository.acceptCall(signal);

  Future<void> rejectCall(CallSignal signal) => _repository.rejectCall(signal);

  Future<void> endCall(CallSignal signal) => _repository.endCall(signal);

  Future<void> simulateIncomingCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) {
    return _repository.simulateIncomingCall(
      callerUsername: callerUsername,
      callerDisplayName: callerDisplayName,
      receiverUsername: receiverUsername,
      receiverDisplayName: receiverDisplayName,
    );
  }

  Future<void> simulateMissedCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) {
    return _repository.simulateMissedCall(
      callerUsername: callerUsername,
      callerDisplayName: callerDisplayName,
      receiverUsername: receiverUsername,
      receiverDisplayName: receiverDisplayName,
    );
  }

  Stream<CallSignal> signalStream() => _repository.signalStream();

  Stream<CallStatus> callStatusStream() => _repository.callStatusStream();
}
