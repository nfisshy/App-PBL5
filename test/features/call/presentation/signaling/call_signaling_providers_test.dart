import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/call/data/signaling/mock_call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/signaling/call_session.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';
import 'package:photomanager/features/call/presentation/signaling/call_signaling_providers.dart';

void main() {
  test('providers expose outgoing call status transitions', () async {
    final container = _container();
    addTearDown(container.dispose);
    final accepted = _waitForStatus(container, CallStatus.accepted);

    await container
        .read(currentCallSessionProvider.notifier)
        .startOutgoingCall(_participant);

    expect(await accepted, CallStatus.accepted);
    expect(
      container.read(currentCallSessionProvider)?.status,
      CallStatus.accepted,
    );
  });

  test('incoming call flow accepts the current session', () async {
    final container = _container();
    addTearDown(container.dispose);
    final incoming = _waitForSessionStatus(container, CallStatus.incoming);

    await container
        .read(currentCallSessionProvider.notifier)
        .simulateIncomingCall(_participant);
    expect((await incoming).participantUsername, 'dat001');

    final accepted = _waitForSessionStatus(container, CallStatus.accepted);
    await container.read(currentCallSessionProvider.notifier).acceptCall();

    expect((await accepted).status, CallStatus.accepted);
  });

  test('ended calls are stored in memory', () async {
    final container = _container();
    addTearDown(container.dispose);
    final incoming = _waitForSessionStatus(container, CallStatus.incoming);
    await container
        .read(currentCallSessionProvider.notifier)
        .simulateIncomingCall(_participant);
    await incoming;

    final ended = _waitForSessionStatus(container, CallStatus.ended);
    await container.read(currentCallSessionProvider.notifier).endCall();
    await ended;

    final history = container.read(callSessionHistoryProvider);
    expect(history, hasLength(1));
    expect(history.single.status, CallStatus.ended);
    expect(history.single.endedAt, isNotNull);
  });
}

const _participant = CallParticipant(
  username: 'dat001',
  displayName: 'DAT',
);

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      callSignalingRepositoryProvider.overrideWithValue(
        MockCallSignalingRepository(
          transitionDelay: const Duration(milliseconds: 5),
        ),
      ),
    ],
  );
}

Future<CallStatus> _waitForStatus(
  ProviderContainer container,
  CallStatus expected,
) {
  final completer = Completer<CallStatus>();
  late final ProviderSubscription<AsyncValue<CallStatus>> subscription;
  subscription = container.listen(
    callStatusProvider,
    (previous, next) {
      if (next.valueOrNull == expected && !completer.isCompleted) {
        completer.complete(expected);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<CallSession> _waitForSessionStatus(
  ProviderContainer container,
  CallStatus expected,
) {
  final completer = Completer<CallSession>();
  late final ProviderSubscription<CallSession?> subscription;
  subscription = container.listen(
    currentCallSessionProvider,
    (previous, next) {
      if (next?.status == expected && !completer.isCompleted) {
        completer.complete(next);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
