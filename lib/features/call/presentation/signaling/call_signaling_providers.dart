import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/call/call_signaling_service.dart';
import 'package:photomanager/features/call/data/signaling/mock_call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/call_participant.dart';
import 'package:photomanager/features/call/domain/signaling/call_session.dart';
import 'package:photomanager/features/call/domain/signaling/call_signal.dart';
import 'package:photomanager/features/call/domain/signaling/call_signal_type.dart';
import 'package:photomanager/features/call/domain/signaling/call_signaling_repository.dart';
import 'package:photomanager/features/call/domain/signaling/call_status.dart';

final callSignalingRepositoryProvider =
    Provider<CallSignalingRepository>((ref) {
  return MockCallSignalingRepository();
});

final callSignalingServiceProvider = Provider<CallSignalingService>((ref) {
  return CallSignalingService(ref.watch(callSignalingRepositoryProvider));
});

final callStatusProvider = StreamProvider<CallStatus>((ref) {
  return ref.watch(callSignalingServiceProvider).callStatusStream();
});

final callSignalProvider = StreamProvider<CallSignal>((ref) {
  return ref.watch(callSignalingServiceProvider).signalStream();
});

final callSessionHistoryProvider = StateProvider<List<CallSession>>((ref) {
  return const [];
});

final currentCallSessionProvider =
    StateNotifierProvider<CurrentCallSessionController, CallSession?>((ref) {
  return CurrentCallSessionController(
    service: ref.watch(callSignalingServiceProvider),
    onSessionCompleted: (session) {
      final history = ref.read(callSessionHistoryProvider.notifier);
      history.state = [...history.state, session];
    },
  );
});

class CurrentCallSessionController extends StateNotifier<CallSession?> {
  CurrentCallSessionController({
    required CallSignalingService service,
    required void Function(CallSession session) onSessionCompleted,
  })  : _service = service,
        _onSessionCompleted = onSessionCompleted,
        super(null) {
    _statusSubscription = _service.callStatusStream().listen(_handleStatus);
    _signalSubscription = _service.signalStream().listen((signal) {
      _latestSignal = signal;
    });
  }

  final CallSignalingService _service;
  final void Function(CallSession session) _onSessionCompleted;
  late final StreamSubscription<CallStatus> _statusSubscription;
  late final StreamSubscription<CallSignal> _signalSubscription;
  final _recordedSessionIds = <String>{};
  CallSignal? _latestSignal;

  Future<void> startOutgoingCall(CallParticipant participant) async {
    if (_isActiveSessionFor(participant.username)) {
      return;
    }

    _latestSignal = null;
    state = _newSession(participant, CallStatus.calling);
    await _service.startCall(
      callerUsername: 'huy',
      callerDisplayName: 'HUY',
      receiverUsername: participant.username,
      receiverDisplayName: participant.displayName,
    );
  }

  Future<void> simulateIncomingCall(CallParticipant caller) async {
    _latestSignal = null;
    state = _newSession(caller, CallStatus.incoming);
    await _service.simulateIncomingCall(
      callerUsername: caller.username,
      callerDisplayName: caller.displayName,
      receiverUsername: 'huy',
      receiverDisplayName: 'HUY',
    );
  }

  Future<void> simulateMissedCall(CallParticipant caller) async {
    _latestSignal = null;
    state = _newSession(caller, CallStatus.missed);
    await _service.simulateMissedCall(
      callerUsername: caller.username,
      callerDisplayName: caller.displayName,
      receiverUsername: 'huy',
      receiverDisplayName: 'HUY',
    );
  }

  Future<void> acceptCall() async {
    final signal = _activeSignal();
    if (signal != null) {
      await _service.acceptCall(signal);
    }
  }

  Future<void> rejectCall() async {
    final signal = _activeSignal();
    if (signal != null) {
      await _service.rejectCall(signal);
    }
  }

  Future<void> endCall() async {
    final signal = _activeSignal();
    if (signal != null) {
      await _service.endCall(signal);
    }
  }

  bool _isActiveSessionFor(String username) {
    final session = state;
    if (session == null || session.participantUsername != username) {
      return false;
    }

    return switch (session.status) {
      CallStatus.calling ||
      CallStatus.ringing ||
      CallStatus.accepted ||
      CallStatus.incoming =>
        true,
      _ => false,
    };
  }

  CallSession _newSession(CallParticipant participant, CallStatus status) {
    final now = DateTime.now();
    return CallSession(
      sessionId: 'session-${now.microsecondsSinceEpoch}',
      participantUsername: participant.username,
      participantDisplayName: participant.displayName,
      status: status,
      startedAt: now,
    );
  }

  void _handleStatus(CallStatus status) {
    final session = state;
    if (session == null) {
      return;
    }

    final terminal = status == CallStatus.ended ||
        status == CallStatus.rejected ||
        status == CallStatus.missed;
    final updated = session.copyWith(
      status: status,
      endedAt: terminal ? DateTime.now() : null,
    );
    state = updated;

    if (terminal && _recordedSessionIds.add(updated.sessionId)) {
      _onSessionCompleted(updated);
    }
  }

  CallSignal? _activeSignal() {
    final latestSignal = _latestSignal;
    final session = state;
    if (latestSignal != null || session == null) {
      return latestSignal;
    }

    return CallSignal(
      signalId: 'local-${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now(),
      callerUsername: 'huy',
      callerDisplayName: 'HUY',
      receiverUsername: session.participantUsername,
      receiverDisplayName: session.participantDisplayName,
      type: CallSignalType.callRequest,
    );
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    _signalSubscription.cancel();
    super.dispose();
  }
}
