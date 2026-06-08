import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/core/services/speech/speech_output_service.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';

final speechRepositoryProvider = Provider<SpeechRepository>((ref) {
  final repository = MockSpeechRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final speechOutputServiceProvider = Provider<SpeechOutputService>((ref) {
  return SpeechOutputService(ref.watch(speechRepositoryProvider));
});

final speechStateProvider = StreamProvider<SpeechState>((ref) {
  return ref.watch(speechOutputServiceProvider).speechStateStream();
});

final speechStatisticsProvider = StreamProvider<SpeechStatistics>((ref) {
  return ref.watch(speechOutputServiceProvider).statisticsStream();
});

final speechMessageProvider = StreamProvider<SpeechMessage>((ref) {
  return ref.watch(speechOutputServiceProvider).spokenMessageStream();
});

final speechQueueProvider = StreamProvider<List<SpeechQueueItem>>((ref) {
  return ref.watch(speechOutputServiceProvider).queueStream();
});
