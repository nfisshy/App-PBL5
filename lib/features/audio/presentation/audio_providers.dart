import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/audio/audio_capture_service.dart';
import 'package:photomanager/features/audio/data/mock_audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_capture_session.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return MockAudioRepository();
});

final audioCaptureServiceProvider = Provider<AudioCaptureService>((ref) {
  return AudioCaptureService(ref.watch(audioRepositoryProvider));
});

final audioCaptureStateProvider = StreamProvider<AudioCaptureState>((ref) {
  return ref.watch(audioCaptureServiceProvider).captureStateStream();
});

final audioStatisticsProvider = StreamProvider<AudioStatistics>((ref) {
  return ref.watch(audioCaptureServiceProvider).statisticsStream();
});

final audioChunkProvider = StreamProvider<AudioChunk>((ref) {
  return ref.watch(audioCaptureServiceProvider).audioChunkStream();
});

final recentAudioChunksProvider = StateProvider<List<AudioChunk>>((ref) {
  return const [];
});

final currentAudioSessionProvider =
    StateNotifierProvider<AudioCaptureSessionController, AudioCaptureSession?>(
        (ref) {
  return AudioCaptureSessionController(
    service: ref.watch(audioCaptureServiceProvider),
    onSessionStarted: () {
      ref.read(recentAudioChunksProvider.notifier).state = const [];
    },
    onChunk: (chunk) {
      final chunks = ref.read(recentAudioChunksProvider.notifier);
      chunks.state = [chunk, ...chunks.state].take(20).toList(growable: false);
    },
  );
});

class AudioCaptureSessionController
    extends StateNotifier<AudioCaptureSession?> {
  AudioCaptureSessionController({
    required AudioCaptureService service,
    required void Function() onSessionStarted,
    required void Function(AudioChunk chunk) onChunk,
  })  : _service = service,
        _onSessionStarted = onSessionStarted,
        _onChunk = onChunk,
        super(null) {
    _chunkSubscription = _service.audioChunkStream().listen(_handleChunk);
  }

  final AudioCaptureService _service;
  final void Function() _onSessionStarted;
  final void Function(AudioChunk chunk) _onChunk;
  late final StreamSubscription<AudioChunk> _chunkSubscription;

  Future<void> initialize() => _service.initialize();

  Future<void> startRecording() async {
    final now = DateTime.now();
    _onSessionStarted();
    state = AudioCaptureSession(
      sessionId: 'audio-${now.microsecondsSinceEpoch}',
      startedAt: now,
      totalChunks: 0,
      totalDurationMs: 0,
    );
    await _service.startRecording();
  }

  Future<void> pauseRecording() => _service.pauseRecording();

  Future<void> resumeRecording() => _service.resumeRecording();

  Future<void> stopRecording() async {
    await _service.stopRecording();
    final session = state;
    if (session != null && session.endedAt == null) {
      state = session.copyWith(endedAt: DateTime.now());
    }
  }

  Future<void> disposeCapture() async {
    await _service.dispose();
    final session = state;
    if (session != null && session.endedAt == null) {
      state = session.copyWith(endedAt: DateTime.now());
    }
  }

  void _handleChunk(AudioChunk chunk) {
    _onChunk(chunk);
    final session = state;
    if (session == null || session.endedAt != null) {
      return;
    }

    state = session.copyWith(
      totalChunks: session.totalChunks + 1,
      totalDurationMs: session.totalDurationMs + chunk.durationMs,
    );
  }

  @override
  void dispose() {
    unawaited(_service.dispose());
    _chunkSubscription.cancel();
    super.dispose();
  }
}
