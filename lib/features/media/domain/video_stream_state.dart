import 'package:photomanager/features/media/domain/media_connection_state.dart';

class VideoStreamState {
  const VideoStreamState({
    required this.isStreaming,
    required this.fps,
    required this.resolution,
    required this.connectionState,
  });

  const VideoStreamState.idle()
      : isStreaming = false,
        fps = 0,
        resolution = '640x480',
        connectionState = MediaConnectionState.idle;

  final bool isStreaming;
  final int fps;
  final String resolution;
  final MediaConnectionState connectionState;

  VideoStreamState copyWith({
    bool? isStreaming,
    int? fps,
    String? resolution,
    MediaConnectionState? connectionState,
  }) {
    return VideoStreamState(
      isStreaming: isStreaming ?? this.isStreaming,
      fps: fps ?? this.fps,
      resolution: resolution ?? this.resolution,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
