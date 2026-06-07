import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/domain/realtime_event.dart';
import 'package:photomanager/features/realtime/domain/realtime_repository.dart';

class RealtimeService {
  const RealtimeService(this._repository);

  final RealtimeRepository _repository;

  Future<void> connect() => _repository.connect();

  Future<void> disconnect() => _repository.disconnect();

  Stream<ConnectionStatus> connectionStatusStream() {
    return _repository.connectionStatusStream();
  }

  Stream<RealtimeEvent> eventStream() {
    return _repository.eventStream();
  }
}
