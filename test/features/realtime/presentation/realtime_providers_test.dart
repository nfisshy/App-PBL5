import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/realtime/data/mock_realtime_repository.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/domain/realtime_event.dart';
import 'package:photomanager/features/realtime/presentation/realtime_providers.dart';

void main() {
  test('connection status provider exposes mock repository transitions',
      () async {
    final repository = MockRealtimeRepository(
      connectionDelay: const Duration(milliseconds: 5),
    );
    final container = ProviderContainer(
      overrides: [
        realtimeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final connected = Completer<ConnectionStatus>();
    final subscription = container.listen(
      connectionStatusProvider,
      (previous, next) {
        if (next.valueOrNull == ConnectionStatus.connected &&
            !connected.isCompleted) {
          connected.complete(ConnectionStatus.connected);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(await connected.future, ConnectionStatus.connected);
  });

  test('realtime event provider exposes mock events', () async {
    final repository = MockRealtimeRepository(
      connectionDelay: const Duration(milliseconds: 5),
      eventInterval: const Duration(milliseconds: 5),
    );
    final container = ProviderContainer(
      overrides: [
        realtimeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final eventCompleter = Completer<RealtimeEvent>();
    final subscription = container.listen(
      realtimeEventProvider,
      (previous, next) {
        final event = next.valueOrNull;
        if (event != null && !eventCompleter.isCompleted) {
          eventCompleter.complete(event);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final event = await eventCompleter.future;

    expect(event.eventId, startsWith('mock-'));
    expect(event.payload['source'], 'mock');
  });
}
