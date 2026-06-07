import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/media/data/mock_media_repository.dart';
import 'package:photomanager/features/media/domain/camera_state.dart';
import 'package:photomanager/features/media/domain/media_connection_state.dart';
import 'package:photomanager/features/media/domain/microphone_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';
import 'package:photomanager/features/media/presentation/media_providers.dart';

void main() {
  test('providers expose initialized camera and microphone states', () async {
    final container = _container();
    addTearDown(container.dispose);
    final cameraReady = _waitForCamera(
      container,
      (state) => state.connectionState == MediaConnectionState.ready,
    );
    final microphoneReady = _waitForMicrophone(
      container,
      (state) => state.connectionState == MediaConnectionState.ready,
    );

    await container.read(mediaActionsProvider).initialize();

    expect((await cameraReady).connectionState, MediaConnectionState.ready);
    expect(
      (await microphoneReady).connectionState,
      MediaConnectionState.ready,
    );
  });

  test('media actions update provider-driven stream state', () async {
    final container = _container();
    addTearDown(container.dispose);
    final streaming = _waitForVideo(container, (state) => state.isStreaming);

    await container.read(mediaActionsProvider).startStreams();

    final video = await streaming;
    expect(video.fps, inInclusiveRange(20, 30));
    expect(video.resolution, '640x480');
  });
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      mediaRepositoryProvider.overrideWithValue(
        MockMediaRepository(
          initializationDelay: const Duration(milliseconds: 5),
        ),
      ),
    ],
  );
}

Future<CameraState> _waitForCamera(
  ProviderContainer container,
  bool Function(CameraState state) matches,
) {
  final completer = Completer<CameraState>();
  late final ProviderSubscription<AsyncValue<CameraState>> subscription;
  subscription = container.listen(
    cameraStateProvider,
    (previous, next) {
      final state = next.valueOrNull;
      if (state != null && matches(state) && !completer.isCompleted) {
        completer.complete(state);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<MicrophoneState> _waitForMicrophone(
  ProviderContainer container,
  bool Function(MicrophoneState state) matches,
) {
  final completer = Completer<MicrophoneState>();
  late final ProviderSubscription<AsyncValue<MicrophoneState>> subscription;
  subscription = container.listen(
    microphoneStateProvider,
    (previous, next) {
      final state = next.valueOrNull;
      if (state != null && matches(state) && !completer.isCompleted) {
        completer.complete(state);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<VideoStreamState> _waitForVideo(
  ProviderContainer container,
  bool Function(VideoStreamState state) matches,
) {
  final completer = Completer<VideoStreamState>();
  late final ProviderSubscription<AsyncValue<VideoStreamState>> subscription;
  subscription = container.listen(
    videoStreamStateProvider,
    (previous, next) {
      final state = next.valueOrNull;
      if (state != null && matches(state) && !completer.isCompleted) {
        completer.complete(state);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
