import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/call/domain/call_state.dart';
import 'package:photomanager/features/call/presentation/call_providers.dart';

void main() {
  test('call state provider loads mock call state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(callStateProvider('dat')).isLoading, isTrue);

    final state = await _waitForCallState(container, 'dat');

    expect(state, isNotNull);
    expect(state!.participant.username, 'dat');
    expect(state.messages, hasLength(3));
  });

  test('call controller toggles mic state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initialState = await _waitForCallState(container, 'linh');
    expect(initialState!.isMicEnabled, isTrue);

    container.read(callStateProvider('linh').notifier).toggleMic();

    expect(
      container.read(callStateProvider('linh')).valueOrNull?.isMicEnabled,
      isFalse,
    );
  });
}

Future<CallState?> _waitForCallState(
  ProviderContainer container,
  String username,
) {
  final completer = Completer<CallState?>();
  late final ProviderSubscription<AsyncValue<CallState?>> subscription;

  subscription = container.listen(
    callStateProvider(username),
    (previous, next) {
      if (!next.isLoading && !completer.isCompleted) {
        next.when(
          data: completer.complete,
          error: completer.completeError,
          loading: () {},
        );
      }
    },
    fireImmediately: true,
  );

  return completer.future.whenComplete(subscription.close);
}
