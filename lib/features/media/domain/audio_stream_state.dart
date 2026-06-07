import 'package:photomanager/features/media/domain/media_connection_state.dart';

class AudioStreamState {
  const AudioStreamState({
    required this.isStreaming,
    required this.sampleRate,
    required this.connectionState,
  });

  const AudioStreamState.idle()
      : isStreaming = false,
        sampleRate = 16000,
        connectionState = MediaConnectionState.idle;

  final bool isStreaming;
  final int sampleRate;
  final MediaConnectionState connectionState;

  AudioStreamState copyWith({
    bool? isStreaming,
    int? sampleRate,
    MediaConnectionState? connectionState,
  }) {
    return AudioStreamState(
      isStreaming: isStreaming ?? this.isStreaming,
      sampleRate: sampleRate ?? this.sampleRate,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
