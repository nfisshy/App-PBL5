import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';

abstract interface class AudioRepository {
  Future<void> initialize();

  Future<void> startRecording();

  Future<void> pauseRecording();

  Future<void> resumeRecording();

  Future<void> stopRecording();

  Future<void> dispose();

  Stream<AudioCaptureState> captureStateStream();

  Stream<AudioChunk> audioChunkStream();

  Stream<AudioStatistics> statisticsStream();
}
