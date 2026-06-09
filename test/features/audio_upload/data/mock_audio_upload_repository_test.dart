import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/audio_upload/data/mock_audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';

void main() {
  late MockAudioUploadRepository repository;

  setUp(() {
    repository = MockAudioUploadRepository(
      stageDelay: const Duration(milliseconds: 5),
    );
  });

  tearDown(() => repository.dispose());

  test('simulates the complete upload lifecycle and response', () async {
    final states = <AudioUploadState>[];
    final subscription = repository.stateStream().listen(states.add);

    final response = await repository.uploadAudio(_request());
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      containsAllInOrder([
        AudioUploadState.idle,
        AudioUploadState.preparing,
        AudioUploadState.uploading,
        AudioUploadState.processing,
        AudioUploadState.completed,
      ]),
    );
    expect(response?.draftText, 'hello');
    expect(response?.finalText, 'hello how are you');
    expect(response?.finalSource, 'speech');
    await subscription.cancel();
  });

  test('uploadAudioBytes uses binary length and updates statistics', () async {
    final response = repository.responseStream().first;

    await repository.uploadAudioBytes(
      request: _request(),
      bytes: const [1, 2, 3, 4],
    );
    final statistics = await repository.statisticsStream().first;

    expect((await response).finalSource, 'speech');
    expect(statistics.uploadedRequests, 1);
    expect(statistics.successfulRequests, 1);
    expect(statistics.failedRequests, 0);
    expect(statistics.lastUploadAt, isNotNull);
  });

  test('cancel stops an active upload and records a failed request', () async {
    unawaited(repository.uploadAudio(_request()));
    await repository
        .stateStream()
        .firstWhere((state) => state == AudioUploadState.preparing);

    await repository.cancelUpload();

    expect(await repository.stateStream().first, AudioUploadState.idle);
    final statistics = await repository.statisticsStream().first;
    expect(statistics.uploadedRequests, 1);
    expect(statistics.failedRequests, 1);
  });

  test('generates a mock response without an upload transport', () async {
    final response = await repository.generateMockResponse();
    final statistics = await repository.statisticsStream().first;

    expect(response?.finalText, 'hello how are you');
    expect(statistics.uploadedRequests, 1);
    expect(statistics.successfulRequests, 1);
  });
}

AudioUploadRequest _request() {
  return AudioUploadRequest(
    requestId: 'request-1',
    language: 'vi',
    audioBytesLength: 32000,
    createdAt: DateTime.utc(2026),
  );
}
