import 'package:photomanager/features/media/domain/media_connection_state.dart';

class CameraState {
  const CameraState({
    required this.isEnabled,
    required this.isFrontCamera,
    required this.connectionState,
  });

  const CameraState.idle()
      : isEnabled = false,
        isFrontCamera = true,
        connectionState = MediaConnectionState.idle;

  final bool isEnabled;
  final bool isFrontCamera;
  final MediaConnectionState connectionState;

  CameraState copyWith({
    bool? isEnabled,
    bool? isFrontCamera,
    MediaConnectionState? connectionState,
  }) {
    return CameraState(
      isEnabled: isEnabled ?? this.isEnabled,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
