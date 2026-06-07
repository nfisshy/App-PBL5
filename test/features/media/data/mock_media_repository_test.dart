import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/media/data/mock_media_repository.dart';
import 'package:photomanager/features/media/domain/media_connection_state.dart';

void main() {
  late MockMediaRepository repository;

  setUp(() {
    repository = MockMediaRepository(
      initializationDelay: const Duration(milliseconds: 5),
      random: Random(1),
    );
  });

  test('camera transitions from idle to initializing to ready', () async {
    final states = <MediaConnectionState>[];
    final subscription = repository
        .cameraStateStream()
        .listen((state) => states.add(state.connectionState));

    await repository.initializeCamera();
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      containsAllInOrder([
        MediaConnectionState.idle,
        MediaConnectionState.initializing,
        MediaConnectionState.ready,
      ]),
    );
    await subscription.cancel();
  });

  test('camera can be enabled, disabled, and switched', () async {
    await repository.enableCamera();
    var state = await repository.cameraStateStream().first;
    expect(state.isEnabled, isTrue);
    expect(state.isFrontCamera, isTrue);

    await repository.switchCamera();
    state = await repository.cameraStateStream().first;
    expect(state.isFrontCamera, isFalse);

    await repository.disableCamera();
    state = await repository.cameraStateStream().first;
    expect(state.isEnabled, isFalse);
  });

  test('microphone can be unmuted and muted', () async {
    await repository.unmuteMicrophone();
    expect((await repository.microphoneStateStream().first).isMuted, isFalse);

    await repository.muteMicrophone();
    expect((await repository.microphoneStateStream().first).isMuted, isTrue);
  });

  test('video stream starts and stops with mock statistics', () async {
    await repository.startVideoStream();
    var state = await repository.videoStreamStateStream().first;

    expect(state.isStreaming, isTrue);
    expect(state.fps, inInclusiveRange(20, 30));
    expect(state.resolution, '640x480');

    await repository.stopVideoStream();
    state = await repository.videoStreamStateStream().first;
    expect(state.isStreaming, isFalse);
    expect(state.connectionState, MediaConnectionState.stopped);
  });

  test('audio stream starts and stops at 16000 Hz', () async {
    await repository.startAudioStream();
    var state = await repository.audioStreamStateStream().first;

    expect(state.isStreaming, isTrue);
    expect(state.sampleRate, 16000);

    await repository.stopAudioStream();
    state = await repository.audioStreamStateStream().first;
    expect(state.isStreaming, isFalse);
    expect(state.connectionState, MediaConnectionState.stopped);
  });
}
