import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';

class AudioCaptureService {
  const AudioCaptureService(this._repository);

  final AudioRepository _repository;

  Future<void> initialize() => _repository.initialize();

  Future<void> startRecording() => _repository.startRecording();

  Future<void> pauseRecording() => _repository.pauseRecording();

  Future<void> resumeRecording() => _repository.resumeRecording();

  Future<void> stopRecording() => _repository.stopRecording();

  Future<void> dispose() => _repository.dispose();

  Stream<AudioCaptureState> captureStateStream() {
    return _repository.captureStateStream();
  }

  Stream<AudioChunk> audioChunkStream() => _repository.audioChunkStream();

  Stream<AudioStatistics> statisticsStream() {
    return _repository.statisticsStream();
  }
}
