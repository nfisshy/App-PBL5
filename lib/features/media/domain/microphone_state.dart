import 'package:photomanager/features/media/domain/media_connection_state.dart';

class MicrophoneState {
  const MicrophoneState({
    required this.isMuted,
    required this.connectionState,
  });

  const MicrophoneState.idle()
      : isMuted = true,
        connectionState = MediaConnectionState.idle;

  final bool isMuted;
  final MediaConnectionState connectionState;

  MicrophoneState copyWith({
    bool? isMuted,
    MediaConnectionState? connectionState,
  }) {
    return MicrophoneState(
      isMuted: isMuted ?? this.isMuted,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
