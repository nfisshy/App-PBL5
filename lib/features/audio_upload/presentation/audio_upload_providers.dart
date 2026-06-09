import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/audio_upload/audio_upload_service.dart';
import 'package:photomanager/features/audio_upload/data/mock_audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';

final audioUploadRepositoryProvider = Provider<AudioUploadRepository>((ref) {
  final repository = MockAudioUploadRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final audioUploadServiceProvider = Provider<AudioUploadService>((ref) {
  final service = AudioUploadService(
    repository: ref.watch(audioUploadRepositoryProvider),
    speechOutputService: ref.watch(speechOutputServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final audioUploadStateProvider = StreamProvider<AudioUploadState>((ref) {
  return ref.watch(audioUploadServiceProvider).stateStream();
});

final audioUploadStatisticsProvider =
    StreamProvider<AudioUploadStatistics>((ref) {
  return ref.watch(audioUploadServiceProvider).statisticsStream();
});

final audioUploadResponseProvider = StreamProvider<AudioUploadResponse>((ref) {
  return ref.watch(audioUploadServiceProvider).responseStream();
});
