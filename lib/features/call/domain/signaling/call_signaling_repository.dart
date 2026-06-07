import 'package:photomanager/features/call/domain/signaling/call_signal.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

abstract interface class CallSignalingRepository {
  Future<void> startCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  });

  Future<void> acceptCall(CallSignal signal);

  Future<void> rejectCall(CallSignal signal);

  Future<void> endCall(CallSignal signal);

  Future<void> simulateIncomingCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  });

  Future<void> simulateMissedCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  });

  Stream<CallSignal> signalStream();

  Stream<CallStatus> callStatusStream();
}
