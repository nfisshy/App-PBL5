import 'dart:async';

import 'package:photomanager/core/services/speech/speech_output_service.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';

class AudioUploadService {
  AudioUploadService({
    required AudioUploadRepository repository,
    required SpeechOutputService speechOutputService,
  })  : _repository = repository,
        _speechOutputService = speechOutputService {
    _responseSubscription = _repository.responseStream().listen(
          _handleResponse,
        );
  }

  final AudioUploadRepository _repository;
  final SpeechOutputService _speechOutputService;
  late final StreamSubscription<AudioUploadResponse> _responseSubscription;
  int _requestSequence = 0;

  Future<AudioUploadResponse?> uploadAudio({
    required String language,
    required int audioBytesLength,
  }) {
    return _repository.uploadAudio(
      _createRequest(
        language: language,
        audioBytesLength: audioBytesLength,
      ),
    );
  }

  Future<AudioUploadResponse?> uploadAudioBytes({
    required String language,
    required List<int> bytes,
  }) {
    return _repository.uploadAudioBytes(
      request: _createRequest(
        language: language,
        audioBytesLength: bytes.length,
      ),
      bytes: List<int>.unmodifiable(bytes),
    );
  }

  Future<AudioUploadResponse?> generateMockResponse() {
    return _repository.generateMockResponse();
  }

  Future<void> cancelUpload() => _repository.cancelUpload();

  Stream<AudioUploadState> stateStream() => _repository.stateStream();

  Stream<AudioUploadResponse> responseStream() => _repository.responseStream();

  Stream<AudioUploadStatistics> statisticsStream() {
    return _repository.statisticsStream();
  }

  Future<void> dispose() => _responseSubscription.cancel();

  AudioUploadRequest _createRequest({
    required String language,
    required int audioBytesLength,
  }) {
    final now = DateTime.now();
    _requestSequence++;
    return AudioUploadRequest(
      requestId: 'upload-${now.microsecondsSinceEpoch}-$_requestSequence',
      language: language,
      audioBytesLength: audioBytesLength,
      createdAt: now,
    );
  }

  Future<void> _handleResponse(AudioUploadResponse response) async {
    if (response.draftText.isNotEmpty) {
      await _speechOutputService.speakDraft(response.draftText);
    }
    if (response.finalText.isNotEmpty) {
      await _speechOutputService.speakFinal(response.finalText);
    }
  }
}
