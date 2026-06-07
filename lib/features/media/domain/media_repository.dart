import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';

abstract interface class MediaRepository {
  Future<void> initializeCamera();

  Future<void> disposeCamera();

  Future<void> enableCamera();

  Future<void> disableCamera();

  Future<void> switchCamera();

  Future<void> initializeMicrophone();

  Future<void> disposeMicrophone();

  Future<void> muteMicrophone();

  Future<void> unmuteMicrophone();

  Future<void> startVideoStream();

  Future<void> stopVideoStream();

  Future<void> startAudioStream();

  Future<void> stopAudioStream();

  Stream<CameraState> cameraStateStream();

  Stream<MicrophoneState> microphoneStateStream();

  Stream<VideoStreamState> videoStreamStateStream();

  Stream<AudioStreamState> audioStreamStateStream();
}
