import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/realtime/data/mock_realtime_repository.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';

void main() {
  test('emits connecting, connected, events, and disconnected', () async {
    final repository = MockRealtimeRepository(
      connectionDelay: const Duration(milliseconds: 5),
      eventInterval: const Duration(milliseconds: 5),
    );
    final statuses = <ConnectionStatus>[];
    final statusSubscription =
        repository.connectionStatusStream().listen(statuses.add);
    final firstEvent = repository.eventStream().first;

    await repository.connect();
    final event = await firstEvent;
    await repository.disconnect();
    await Future<void>.delayed(Duration.zero);

    expect(
      statuses,
      containsAllInOrder([
        ConnectionStatus.disconnected,
        ConnectionStatus.connecting,
        ConnectionStatus.connected,
        ConnectionStatus.disconnected,
      ]),
    );
    expect(event.payload['source'], 'mock');

    await statusSubscription.cancel();
  });

  test('disconnect prevents an in-progress connection from completing',
      () async {
    final repository = MockRealtimeRepository(
      connectionDelay: const Duration(milliseconds: 20),
    );
    final statuses = <ConnectionStatus>[];
    final subscription =
        repository.connectionStatusStream().listen(statuses.add);

    final connecting = repository.connect();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository.disconnect();
    await connecting;

    expect(statuses.last, ConnectionStatus.disconnected);
    expect(statuses.where((status) => status == ConnectionStatus.connected),
        isEmpty);

    await subscription.cancel();
  });
}
