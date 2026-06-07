import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/media_repository.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';

class MediaService {
  const MediaService(this._repository);

  final MediaRepository _repository;

  Future<void> initializeCamera() => _repository.initializeCamera();

  Future<void> disposeCamera() => _repository.disposeCamera();

  Future<void> enableCamera() => _repository.enableCamera();

  Future<void> disableCamera() => _repository.disableCamera();

  Future<void> switchCamera() => _repository.switchCamera();

  Future<void> initializeMicrophone() => _repository.initializeMicrophone();

  Future<void> disposeMicrophone() => _repository.disposeMicrophone();

  Future<void> muteMicrophone() => _repository.muteMicrophone();

  Future<void> unmuteMicrophone() => _repository.unmuteMicrophone();

  Future<void> startVideoStream() => _repository.startVideoStream();

  Future<void> stopVideoStream() => _repository.stopVideoStream();

  Future<void> startAudioStream() => _repository.startAudioStream();

  Future<void> stopAudioStream() => _repository.stopAudioStream();

  Stream<CameraState> cameraStateStream() => _repository.cameraStateStream();

  Stream<MicrophoneState> microphoneStateStream() {
    return _repository.microphoneStateStream();
  }

  Stream<VideoStreamState> videoStreamStateStream() {
    return _repository.videoStreamStateStream();
  }

  Stream<AudioStreamState> audioStreamStateStream() {
    return _repository.audioStreamStateStream();
  }
}
