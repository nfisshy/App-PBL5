import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/media/media_service.dart';
import 'package:photomanager/features/media/data/mock_media_repository.dart';
import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/media_repository.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MockMediaRepository();
});

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService(ref.watch(mediaRepositoryProvider));
});

final mediaActionsProvider = Provider<MediaActions>((ref) {
  return MediaActions(ref.watch(mediaServiceProvider));
});

final cameraStateProvider = StreamProvider<CameraState>((ref) {
  return ref.watch(mediaServiceProvider).cameraStateStream();
});

final microphoneStateProvider = StreamProvider<MicrophoneState>((ref) {
  return ref.watch(mediaServiceProvider).microphoneStateStream();
});

final videoStreamStateProvider = StreamProvider<VideoStreamState>((ref) {
  return ref.watch(mediaServiceProvider).videoStreamStateStream();
});

final audioStreamStateProvider = StreamProvider<AudioStreamState>((ref) {
  return ref.watch(mediaServiceProvider).audioStreamStateStream();
});

class MediaActions {
  const MediaActions(this._service);

  final MediaService _service;

  Future<void> initialize() async {
    await Future.wait([
      _service.initializeCamera(),
      _service.initializeMicrophone(),
    ]);
  }

  Future<void> dispose() async {
    await Future.wait([
      _service.disposeCamera(),
      _service.disposeMicrophone(),
    ]);
  }

  Future<void> enableCamera() => _service.enableCamera();

  Future<void> disableCamera() => _service.disableCamera();

  Future<void> switchCamera() => _service.switchCamera();

  Future<void> muteMicrophone() => _service.muteMicrophone();

  Future<void> unmuteMicrophone() => _service.unmuteMicrophone();

  Future<void> startStreams() async {
    await Future.wait([
      _service.startVideoStream(),
      _service.startAudioStream(),
    ]);
  }

  Future<void> stopStreams() async {
    await Future.wait([
      _service.stopVideoStream(),
      _service.stopAudioStream(),
    ]);
  }
}
