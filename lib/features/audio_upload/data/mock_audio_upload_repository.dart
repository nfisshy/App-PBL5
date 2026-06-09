import 'dart:async';

import 'package:photomanager/features/audio_upload/data/dtos/audio_upload_response_dto.dart';
import 'package:photomanager/features/audio_upload/data/mappers/audio_upload_response_mapper.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';

class MockAudioUploadRepository implements AudioUploadRepository {
  MockAudioUploadRepository({
    this.stageDelay = const Duration(milliseconds: 400),
  });

  final Duration stageDelay;

  final _stateController = StreamController<AudioUploadState>.broadcast();
  final _responseController = StreamController<AudioUploadResponse>.broadcast();
  final _statisticsController =
      StreamController<AudioUploadStatistics>.broadcast();

  AudioUploadState _state = AudioUploadState.idle;
  AudioUploadStatistics _statistics = const AudioUploadStatistics.empty();
  int _operationId = 0;
  bool _disposed = false;

  @override
  Future<AudioUploadResponse?> uploadAudio(AudioUploadRequest request) {
    return _simulateUpload(request);
  }

  @override
  Future<AudioUploadResponse?> uploadAudioBytes({
    required AudioUploadRequest request,
    required List<int> bytes,
  }) {
    final normalizedRequest = AudioUploadRequest(
      requestId: request.requestId,
      language: request.language,
      audioBytesLength: bytes.length,
      createdAt: request.createdAt,
    );
    return _simulateUpload(normalizedRequest);
  }

  @override
  Future<AudioUploadResponse?> generateMockResponse() async {
    if (_disposed) {
      return null;
    }
    final operationId = ++_operationId;
    _statistics = AudioUploadStatistics(
      uploadedRequests: _statistics.uploadedRequests + 1,
      successfulRequests: _statistics.successfulRequests,
      failedRequests: _statistics.failedRequests,
      lastUploadAt: DateTime.now(),
    );
    _emitStatistics();
    _emitState(AudioUploadState.processing);
    await Future<void>.delayed(stageDelay);
    if (!_isCurrent(operationId)) {
      return null;
    }
    return _completeUpload();
  }

  @override
  Future<void> cancelUpload() async {
    final wasActive = _state == AudioUploadState.preparing ||
        _state == AudioUploadState.uploading ||
        _state == AudioUploadState.processing;
    _operationId++;
    if (!_disposed) {
      if (wasActive) {
        _statistics = AudioUploadStatistics(
          uploadedRequests: _statistics.uploadedRequests,
          successfulRequests: _statistics.successfulRequests,
          failedRequests: _statistics.failedRequests + 1,
          lastUploadAt: _statistics.lastUploadAt,
        );
        _emitStatistics();
      }
      _emitState(AudioUploadState.idle);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _operationId++;
    await Future.wait([
      _stateController.close(),
      _responseController.close(),
      _statisticsController.close(),
    ]);
  }

  @override
  Stream<AudioUploadState> stateStream() {
    return _currentValueStream(_state, _stateController.stream);
  }

  @override
  Stream<AudioUploadResponse> responseStream() => _responseController.stream;

  @override
  Stream<AudioUploadStatistics> statisticsStream() {
    return _currentValueStream(_statistics, _statisticsController.stream);
  }

  Future<AudioUploadResponse?> _simulateUpload(
      AudioUploadRequest request) async {
    if (_disposed) {
      return null;
    }
    final operationId = ++_operationId;
    _statistics = AudioUploadStatistics(
      uploadedRequests: _statistics.uploadedRequests + 1,
      successfulRequests: _statistics.successfulRequests,
      failedRequests: _statistics.failedRequests,
      lastUploadAt: request.createdAt,
    );
    _emitStatistics();

    for (final state in const [
      AudioUploadState.preparing,
      AudioUploadState.uploading,
      AudioUploadState.processing,
    ]) {
      if (!_isCurrent(operationId)) {
        return null;
      }
      _emitState(state);
      await Future<void>.delayed(stageDelay);
    }

    if (!_isCurrent(operationId)) {
      return null;
    }
    return _completeUpload();
  }

  AudioUploadResponse _completeUpload() {
    const response = AudioUploadResponseDto(
      draftText: 'hello',
      finalText: 'hello how are you',
      finalSource: 'speech',
    );
    _statistics = AudioUploadStatistics(
      uploadedRequests: _statistics.uploadedRequests,
      successfulRequests: _statistics.successfulRequests + 1,
      failedRequests: _statistics.failedRequests,
      lastUploadAt: _statistics.lastUploadAt,
    );
    _emitState(AudioUploadState.completed);
    _emitStatistics();
    final domainResponse = response.toDomain();
    _responseController.add(domainResponse);
    return domainResponse;
  }

  bool _isCurrent(int operationId) {
    return !_disposed && operationId == _operationId;
  }

  Stream<T> _currentValueStream<T>(T currentValue, Stream<T> updates) {
    return Stream<T>.multi(
      (controller) {
        controller.addSync(currentValue);
        final subscription = updates.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  void _emitState(AudioUploadState state) {
    _state = state;
    _stateController.add(state);
  }

  void _emitStatistics() {
    _statisticsController.add(_statistics);
  }
}
