import 'dart:async';

import 'package:photomanager/features/call/domain/signaling/call_signal.dart';
import 'package:photomanager/features/call/domain/signaling/call_signal_type.dart';
import 'package:photomanager/features/call/domain/signaling/call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

class MockCallSignalingRepository implements CallSignalingRepository {
  MockCallSignalingRepository({
    this.transitionDelay = const Duration(seconds: 2),
  });

  final Duration transitionDelay;

  final _statusController = StreamController<CallStatus>.broadcast();
  final _signalController = StreamController<CallSignal>.broadcast();
  final _transitionTimers = <Timer>[];

  CallStatus _status = CallStatus.idle;
  int _signalSequence = 0;

  @override
  Future<void> startCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) async {
    _cancelTransitions();
    final request = _createSignal(
      callerUsername: callerUsername,
      callerDisplayName: callerDisplayName,
      receiverUsername: receiverUsername,
      receiverDisplayName: receiverDisplayName,
      type: CallSignalType.callRequest,
    );

    _emitStatus(CallStatus.calling);
    _signalController.add(request);
    _scheduleTransition(
      transitionDelay,
      () => _emitStatus(CallStatus.ringing),
    );
    _scheduleTransition(
      transitionDelay * 2,
      () {
        _emitStatus(CallStatus.accepted);
        _signalController.add(
          _copySignal(request, CallSignalType.callAccepted),
        );
      },
    );
  }

  @override
  Future<void> acceptCall(CallSignal signal) async {
    _cancelTransitions();
    _emitStatus(CallStatus.accepted);
    _signalController.add(_copySignal(signal, CallSignalType.callAccepted));
  }

  @override
  Future<void> rejectCall(CallSignal signal) async {
    _cancelTransitions();
    _emitStatus(CallStatus.rejected);
    _signalController.add(_copySignal(signal, CallSignalType.callRejected));
  }

  @override
  Future<void> endCall(CallSignal signal) async {
    _cancelTransitions();
    _emitStatus(CallStatus.ended);
    _signalController.add(_copySignal(signal, CallSignalType.callEnded));
  }

  @override
  Future<void> simulateIncomingCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) async {
    _cancelTransitions();
    _emitStatus(CallStatus.incoming);
    _signalController.add(
      _createSignal(
        callerUsername: callerUsername,
        callerDisplayName: callerDisplayName,
        receiverUsername: receiverUsername,
        receiverDisplayName: receiverDisplayName,
        type: CallSignalType.callRequest,
      ),
    );
  }

  @override
  Future<void> simulateMissedCall({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
  }) async {
    _cancelTransitions();
    _emitStatus(CallStatus.missed);
    _signalController.add(
      _createSignal(
        callerUsername: callerUsername,
        callerDisplayName: callerDisplayName,
        receiverUsername: receiverUsername,
        receiverDisplayName: receiverDisplayName,
        type: CallSignalType.callMissed,
      ),
    );
  }

  @override
  Stream<CallSignal> signalStream() => _signalController.stream;

  @override
  Stream<CallStatus> callStatusStream() {
    return Stream<CallStatus>.multi(
      (controller) {
        controller.addSync(_status);
        final subscription = _statusController.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  void _emitStatus(CallStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void _scheduleTransition(Duration delay, void Function() transition) {
    _transitionTimers.add(Timer(delay, transition));
  }

  void _cancelTransitions() {
    for (final timer in _transitionTimers) {
      timer.cancel();
    }
    _transitionTimers.clear();
  }

  CallSignal _createSignal({
    required String callerUsername,
    required String callerDisplayName,
    required String receiverUsername,
    required String receiverDisplayName,
    required CallSignalType type,
  }) {
    final timestamp = DateTime.now();
    _signalSequence++;
    return CallSignal(
      signalId: 'signal-${timestamp.microsecondsSinceEpoch}-$_signalSequence',
      timestamp: timestamp,
      callerUsername: callerUsername,
      callerDisplayName: callerDisplayName,
      receiverUsername: receiverUsername,
      receiverDisplayName: receiverDisplayName,
      type: type,
    );
  }

  CallSignal _copySignal(CallSignal signal, CallSignalType type) {
    return _createSignal(
      callerUsername: signal.callerUsername,
      callerDisplayName: signal.callerDisplayName,
      receiverUsername: signal.receiverUsername,
      receiverDisplayName: signal.receiverDisplayName,
      type: type,
    );
  }
}
