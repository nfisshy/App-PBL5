import 'dart:async';

import 'package:photomanager/features/realtime/domain/connection_status.dart';
import 'package:photomanager/features/realtime/domain/realtime_event.dart';
import 'package:photomanager/features/realtime/domain/realtime_event_type.dart';
import 'package:photomanager/features/realtime/domain/realtime_repository.dart';

class MockRealtimeRepository implements RealtimeRepository {
  MockRealtimeRepository({
    this.connectionDelay = const Duration(seconds: 1),
    this.eventInterval = const Duration(seconds: 3),
  });

  final Duration connectionDelay;
  final Duration eventInterval;

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final _eventController = StreamController<RealtimeEvent>.broadcast();
  final _eventTypes = const [
    RealtimeEventType.userOnline,
    RealtimeEventType.messageReceived,
    RealtimeEventType.messageSent,
    RealtimeEventType.callStarted,
    RealtimeEventType.callEnded,
    RealtimeEventType.userOffline,
  ];

  Timer? _eventTimer;
  Timer? _connectionTimer;
  Completer<void>? _connectionCompleter;
  int _eventIndex = 0;
  int _eventListeners = 0;
  int _connectionGeneration = 0;
  ConnectionStatus _status = ConnectionStatus.disconnected;

  @override
  Future<void> connect() async {
    if (_status == ConnectionStatus.connecting ||
        _status == ConnectionStatus.connected) {
      return;
    }

    final generation = ++_connectionGeneration;
    _emitStatus(ConnectionStatus.connecting);
    final completer = Completer<void>();
    _connectionCompleter = completer;
    _connectionTimer = Timer(connectionDelay, () {
      if (generation == _connectionGeneration) {
        _emitStatus(ConnectionStatus.connected);
        _startEventTimer();
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;
  }

  @override
  Future<void> disconnect() async {
    _connectionGeneration++;
    _connectionTimer?.cancel();
    _connectionTimer = null;
    final connectionCompleter = _connectionCompleter;
    if (connectionCompleter != null && !connectionCompleter.isCompleted) {
      connectionCompleter.complete();
    }
    _connectionCompleter = null;
    _eventTimer?.cancel();
    _eventTimer = null;
    _emitStatus(ConnectionStatus.disconnected);
  }

  @override
  Stream<ConnectionStatus> connectionStatusStream() {
    return Stream<ConnectionStatus>.multi(
      (controller) {
        controller.addSync(_status);
        final subscription = _statusController.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  @override
  Stream<RealtimeEvent> eventStream() {
    return Stream<RealtimeEvent>.multi(
      (controller) {
        _eventListeners++;
        _startEventTimer();
        final subscription = _eventController.stream.listen(controller.add);
        controller.onCancel = () async {
          await subscription.cancel();
          _eventListeners--;
          if (_eventListeners == 0) {
            _eventTimer?.cancel();
            _eventTimer = null;
          }
        };
      },
      isBroadcast: true,
    );
  }

  void _emitStatus(ConnectionStatus status) {
    _status = status;
    _statusController.add(status);
  }

  void _emitNextEvent() {
    final type = _eventTypes[_eventIndex % _eventTypes.length];
    _eventIndex++;
    final timestamp = DateTime.now();

    _eventController.add(
      RealtimeEvent(
        eventId: 'mock-${timestamp.microsecondsSinceEpoch}-$_eventIndex',
        timestamp: timestamp,
        type: type,
        payload: Map<String, Object?>.unmodifiable({
          'source': 'mock',
          'sequence': _eventIndex,
        }),
      ),
    );
  }

  void _startEventTimer() {
    if (_status != ConnectionStatus.connected ||
        _eventListeners == 0 ||
        _eventTimer != null) {
      return;
    }

    _eventTimer = Timer.periodic(eventInterval, (_) => _emitNextEvent());
  }
}
