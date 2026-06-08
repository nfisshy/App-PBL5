import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/audio/data/mock_audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_capture_session.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';
import 'package:photomanager/features/audio/presentation/audio_providers.dart';

void main() {
  test('providers expose recording state, chunks, statistics, and session',
      () async {
    final container = _container();
    addTearDown(container.dispose);
    final recording =
        _waitForCaptureState(container, AudioCaptureState.recording);
    final statistics = _waitForStatistics(
      container,
      (statistics) => statistics.chunkCount >= 1,
    );
    final sessionWithChunk = _waitForSession(
      container,
      (session) => session.totalChunks >= 1,
    );

    await container.read(currentAudioSessionProvider.notifier).startRecording();

    expect(await recording, AudioCaptureState.recording);
    expect((await statistics).chunkCount, 1);
    expect((await sessionWithChunk).totalDurationMs, 5);
    expect(container.read(recentAudioChunksProvider), isNotEmpty);
  });

  test('stop finalizes the current audio session', () async {
    final container = _container();
    addTearDown(container.dispose);
    final sessionWithChunk = _waitForSession(
      container,
      (session) => session.totalChunks >= 1,
    );

    await container.read(currentAudioSessionProvider.notifier).startRecording();
    await sessionWithChunk;
    await container.read(currentAudioSessionProvider.notifier).stopRecording();

    final session = container.read(currentAudioSessionProvider);
    expect(session?.endedAt, isNotNull);
    expect(session?.totalChunks, greaterThanOrEqualTo(1));
  });

  test('audio chunk provider exposes generated chunks', () async {
    final container = _container();
    addTearDown(container.dispose);
    final chunk = Completer<AudioChunk>();
    final subscription = container.listen(
      audioChunkProvider,
      (previous, next) {
        final value = next.valueOrNull;
        if (value != null && !chunk.isCompleted) {
          chunk.complete(value);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(currentAudioSessionProvider.notifier).startRecording();

    expect((await chunk.future).sequenceNumber, 1);
  });
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      audioRepositoryProvider.overrideWithValue(
        MockAudioRepository(
          initializationDelay: const Duration(milliseconds: 5),
          chunkInterval: const Duration(milliseconds: 5),
        ),
      ),
    ],
  );
}

Future<AudioCaptureState> _waitForCaptureState(
  ProviderContainer container,
  AudioCaptureState expected,
) {
  final completer = Completer<AudioCaptureState>();
  late final ProviderSubscription<AsyncValue<AudioCaptureState>> subscription;
  subscription = container.listen(
    audioCaptureStateProvider,
    (previous, next) {
      if (next.valueOrNull == expected && !completer.isCompleted) {
        completer.complete(expected);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<AudioStatistics> _waitForStatistics(
  ProviderContainer container,
  bool Function(AudioStatistics statistics) matches,
) {
  final completer = Completer<AudioStatistics>();
  late final ProviderSubscription<AsyncValue<AudioStatistics>> subscription;
  subscription = container.listen(
    audioStatisticsProvider,
    (previous, next) {
      final statistics = next.valueOrNull;
      if (statistics != null && matches(statistics) && !completer.isCompleted) {
        completer.complete(statistics);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<AudioCaptureSession> _waitForSession(
  ProviderContainer container,
  bool Function(AudioCaptureSession session) matches,
) {
  final completer = Completer<AudioCaptureSession>();
  late final ProviderSubscription<AudioCaptureSession?> subscription;
  subscription = container.listen(
    currentAudioSessionProvider,
    (previous, next) {
      if (next != null && matches(next) && !completer.isCompleted) {
        completer.complete(next);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
