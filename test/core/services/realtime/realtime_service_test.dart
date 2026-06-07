import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/realtime/realtime_service.dart';
import 'package:photomanager/features/realtime/data/mock_realtime_repository.dart';
import 'package:photomanager/features/realtime/domain/connection_status.dart';

void main() {
  test('delegates connection and streams to the repository', () async {
    final repository = MockRealtimeRepository(
      connectionDelay: const Duration(milliseconds: 5),
    );
    final service = RealtimeService(repository);
    final connected = service
        .connectionStatusStream()
        .firstWhere((status) => status == ConnectionStatus.connected);

    await service.connect();

    expect(await connected, ConnectionStatus.connected);

    await service.disconnect();
    expect(
      await service.connectionStatusStream().first,
      ConnectionStatus.disconnected,
    );
  });
}
