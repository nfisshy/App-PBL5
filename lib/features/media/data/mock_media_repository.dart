import 'dart:async';
import 'dart:math';

import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/media_connection_state.dart';
import 'package:photomanager/features/media/domain/media_repository.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';

class MockMediaRepository implements MediaRepository {
  MockMediaRepository({
    this.initializationDelay = const Duration(milliseconds: 300),
    Random? random,
  }) : _random = random ?? Random();

  final Duration initializationDelay;
  final Random _random;

  final _cameraController = StreamController<CameraState>.broadcast();
  final _microphoneController = StreamController<MicrophoneState>.broadcast();
  final _videoController = StreamController<VideoStreamState>.broadcast();
  final _audioController = StreamController<AudioStreamState>.broadcast();
  final _initializationTimers = <String, Timer>{};
  final _initializationCompleters = <String, Completer<void>>{};

  CameraState _cameraState = const CameraState.idle();
  MicrophoneState _microphoneState = const MicrophoneState.idle();
  VideoStreamState _videoState = const VideoStreamState.idle();
  AudioStreamState _audioState = const AudioStreamState.idle();

  @override
  Future<void> initializeCamera() {
    if (_cameraState.connectionState == MediaConnectionState.ready ||
        _cameraState.connectionState == MediaConnectionState.initializing) {
      return _initializationCompleters['camera']?.future ?? Future.value();
    }

    _emitCamera(
      _cameraState.copyWith(connectionState: MediaConnectionState.initializing),
    );
    return _scheduleInitialization('camera', () {
      _emitCamera(
        _cameraState.copyWith(connectionState: MediaConnectionState.ready),
      );
      _emitVideo(
        _videoState.copyWith(connectionState: MediaConnectionState.ready),
      );
    });
  }

  @override
  Future<void> disposeCamera() async {
    _cancelInitialization('camera');
    _emitCamera(
      _cameraState.copyWith(
        isEnabled: false,
        connectionState: MediaConnectionState.stopped,
      ),
    );
    await stopVideoStream();
  }

  @override
  Future<void> enableCamera() async {
    await initializeCamera();
    _emitCamera(_cameraState.copyWith(isEnabled: true));
  }

  @override
  Future<void> disableCamera() async {
    _emitCamera(_cameraState.copyWith(isEnabled: false));
  }

  @override
  Future<void> switchCamera() async {
    _emitCamera(
      _cameraState.copyWith(isFrontCamera: !_cameraState.isFrontCamera),
    );
  }

  @override
  Future<void> initializeMicrophone() {
    if (_microphoneState.connectionState == MediaConnectionState.ready ||
        _microphoneState.connectionState == MediaConnectionState.initializing) {
      return _initializationCompleters['microphone']?.future ?? Future.value();
    }

    _emitMicrophone(
      _microphoneState.copyWith(
        connectionState: MediaConnectionState.initializing,
      ),
    );
    return _scheduleInitialization('microphone', () {
      _emitMicrophone(
        _microphoneState.copyWith(connectionState: MediaConnectionState.ready),
      );
      _emitAudio(
        _audioState.copyWith(connectionState: MediaConnectionState.ready),
      );
    });
  }

  @override
  Future<void> disposeMicrophone() async {
    _cancelInitialization('microphone');
    _emitMicrophone(
      _microphoneState.copyWith(
        isMuted: true,
        connectionState: MediaConnectionState.stopped,
      ),
    );
    await stopAudioStream();
  }

  @override
  Future<void> muteMicrophone() async {
    _emitMicrophone(_microphoneState.copyWith(isMuted: true));
  }

  @override
  Future<void> unmuteMicrophone() async {
    await initializeMicrophone();
    _emitMicrophone(_microphoneState.copyWith(isMuted: false));
  }

  @override
  Future<void> startVideoStream() async {
    await initializeCamera();
    _emitVideo(
      _videoState.copyWith(
        isStreaming: true,
        fps: 20 + _random.nextInt(11),
        resolution: '640x480',
        connectionState: MediaConnectionState.streaming,
      ),
    );
  }

  @override
  Future<void> stopVideoStream() async {
    _emitVideo(
      _videoState.copyWith(
        isStreaming: false,
        fps: 0,
        connectionState: MediaConnectionState.stopped,
      ),
    );
  }

  @override
  Future<void> startAudioStream() async {
    await initializeMicrophone();
    _emitAudio(
      _audioState.copyWith(
        isStreaming: true,
        sampleRate: 16000,
        connectionState: MediaConnectionState.streaming,
      ),
    );
  }

  @override
  Future<void> stopAudioStream() async {
    _emitAudio(
      _audioState.copyWith(
        isStreaming: false,
        connectionState: MediaConnectionState.stopped,
      ),
    );
  }

  @override
  Stream<CameraState> cameraStateStream() {
    return _stateStream(_cameraState, _cameraController.stream);
  }

  @override
  Stream<MicrophoneState> microphoneStateStream() {
    return _stateStream(_microphoneState, _microphoneController.stream);
  }

  @override
  Stream<VideoStreamState> videoStreamStateStream() {
    return _stateStream(_videoState, _videoController.stream);
  }

  @override
  Stream<AudioStreamState> audioStreamStateStream() {
    return _stateStream(_audioState, _audioController.stream);
  }

  Stream<T> _stateStream<T>(T currentState, Stream<T> updates) {
    return Stream<T>.multi(
      (controller) {
        controller.addSync(currentState);
        final subscription = updates.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  Future<void> _scheduleInitialization(
    String key,
    void Function() completeInitialization,
  ) {
    final completer = Completer<void>();
    _initializationCompleters[key] = completer;
    _initializationTimers[key]?.cancel();
    _initializationTimers[key] = Timer(initializationDelay, () {
      completeInitialization();
      _initializationTimers.remove(key);
      _initializationCompleters.remove(key);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  void _cancelInitialization(String key) {
    _initializationTimers.remove(key)?.cancel();
    final completer = _initializationCompleters.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _emitCamera(CameraState state) {
    _cameraState = state;
    _cameraController.add(state);
  }

  void _emitMicrophone(MicrophoneState state) {
    _microphoneState = state;
    _microphoneController.add(state);
  }

  void _emitVideo(VideoStreamState state) {
    _videoState = state;
    _videoController.add(state);
  }

  void _emitAudio(AudioStreamState state) {
    _audioState = state;
    _audioController.add(state);
  }
}
