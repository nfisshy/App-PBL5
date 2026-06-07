import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/domain/realtime_event.dart';

abstract interface class RealtimeRepository {
  Future<void> connect();

  Future<void> disconnect();

  Stream<ConnectionStatus> connectionStatusStream();

  Stream<RealtimeEvent> eventStream();
}
