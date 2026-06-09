import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';

abstract interface class AudioUploadRepository {
  Future<AudioUploadResponse?> uploadAudio(AudioUploadRequest request);

  Future<AudioUploadResponse?> uploadAudioBytes({
    required AudioUploadRequest request,
    required List<int> bytes,
  });

  Future<AudioUploadResponse?> generateMockResponse();

  Future<void> cancelUpload();

  Future<void> dispose();

  Stream<AudioUploadState> stateStream();

  Stream<AudioUploadResponse> responseStream();

  Stream<AudioUploadStatistics> statisticsStream();
}
