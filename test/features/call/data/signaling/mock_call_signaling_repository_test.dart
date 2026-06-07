import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/call/data/signaling/mock_call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/signaling/call_signal_type.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

void main() {
  test('outgoing call emits calling, ringing, and accepted', () async {
    final repository = MockCallSignalingRepository(
      transitionDelay: const Duration(milliseconds: 5),
    );
    final statuses = <CallStatus>[];
    final signals = <CallSignalType>[];
    final accepted = Completer<void>();
    final statusSubscription = repository.callStatusStream().listen((status) {
      statuses.add(status);
      if (status == CallStatus.accepted && !accepted.isCompleted) {
        accepted.complete();
      }
    });
    final signalSubscription =
        repository.signalStream().listen((signal) => signals.add(signal.type));

    await repository.startCall(
      callerUsername: 'huy',
      callerDisplayName: 'HUY',
      receiverUsername: 'dat',
      receiverDisplayName: 'Nguyen Tien Dat',
    );
    await accepted.future;

    expect(
      statuses,
      containsAllInOrder([
        CallStatus.idle,
        CallStatus.calling,
        CallStatus.ringing,
        CallStatus.accepted,
      ]),
    );
    expect(
      signals,
      containsAllInOrder([
        CallSignalType.callRequest,
        CallSignalType.callAccepted,
      ]),
    );

    await statusSubscription.cancel();
    await signalSubscription.cancel();
  });

  test('incoming call can be rejected', () async {
    final repository = MockCallSignalingRepository();
    final signal = repository.signalStream().first;

    await repository.simulateIncomingCall(
      callerUsername: 'dat001',
      callerDisplayName: 'DAT',
      receiverUsername: 'huy',
      receiverDisplayName: 'HUY',
    );
    await repository.rejectCall(await signal);

    expect(await repository.callStatusStream().first, CallStatus.rejected);
  });

  test('missed call emits missed status and signal', () async {
    final repository = MockCallSignalingRepository();
    final signal = repository.signalStream().first;

    await repository.simulateMissedCall(
      callerUsername: 'dat001',
      callerDisplayName: 'DAT',
      receiverUsername: 'huy',
      receiverDisplayName: 'HUY',
    );

    expect(await repository.callStatusStream().first, CallStatus.missed);
    expect((await signal).type, CallSignalType.callMissed);
  });
}
