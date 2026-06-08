import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/audio/data/mock_audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_capture_state.dart';

void main() {
  late MockAudioRepository repository;

  setUp(() {
    repository = MockAudioRepository(
      initializationDelay: const Duration(milliseconds: 5),
      chunkInterval: const Duration(milliseconds: 5),
      random: Random(1),
    );
  });

  tearDown(() => repository.dispose());

  test('initializes from idle through initializing to ready', () async {
    final states = <AudioCaptureState>[];
    final subscription = repository.captureStateStream().listen(states.add);

    await repository.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      containsAllInOrder([
        AudioCaptureState.idle,
        AudioCaptureState.initializing,
        AudioCaptureState.ready,
      ]),
    );
    await subscription.cancel();
  });

  test('records, pauses, resumes, and stops', () async {
    await repository.startRecording();
    expect(await repository.captureStateStream().first,
        AudioCaptureState.recording);

    await repository.pauseRecording();
    expect(
        await repository.captureStateStream().first, AudioCaptureState.paused);

    await repository.resumeRecording();
    expect(await repository.captureStateStream().first,
        AudioCaptureState.recording);

    await repository.stopRecording();
    expect(
        await repository.captureStateStream().first, AudioCaptureState.stopped);
  });

  test('generates sequential chunks every interval', () async {
    final chunks = repository.audioChunkStream().take(2).toList();

    await repository.startRecording();
    final generated = await chunks;
    await repository.stopRecording();

    expect(generated.map((chunk) => chunk.sequenceNumber), [1, 2]);
    expect(generated.every((chunk) => chunk.durationMs == 5), isTrue);
    expect(
      generated.every(
        (chunk) => chunk.sizeBytes >= 28000 && chunk.sizeBytes <= 40000,
      ),
      isTrue,
    );
  });

  test('statistics update with generated chunks', () async {
    final updated = repository
        .statisticsStream()
        .firstWhere((statistics) => statistics.chunkCount >= 2);

    await repository.startRecording();
    final statistics = await updated;
    await repository.stopRecording();

    expect(statistics.chunkCount, 2);
    expect(statistics.totalDurationMs, 10);
    expect(statistics.averageChunkSize, greaterThan(0));
    expect(statistics.isRecording, isTrue);
  });

  test('pause stops chunk generation until resumed', () async {
    final chunks = <int>[];
    final subscription = repository
        .audioChunkStream()
        .listen((chunk) => chunks.add(chunk.sequenceNumber));

    await repository.startRecording();
    await Future<void>.delayed(const Duration(milliseconds: 8));
    await repository.pauseRecording();
    final countAtPause = chunks.length;
    await Future<void>.delayed(const Duration(milliseconds: 12));
    expect(chunks, hasLength(countAtPause));

    await repository.resumeRecording();
    await Future<void>.delayed(const Duration(milliseconds: 8));
    expect(chunks.length, greaterThan(countAtPause));

    await repository.stopRecording();
    await subscription.cancel();
  });
}
