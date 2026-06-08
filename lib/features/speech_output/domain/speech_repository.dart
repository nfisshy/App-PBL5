import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';

abstract interface class SpeechRepository {
  Future<void> initialize();

  Future<void> speakDraft(String text);

  Future<void> speakFinal(String text);

  Future<void> speakSystem(String text);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> dispose();

  Stream<SpeechState> speechStateStream();

  Stream<SpeechMessage> spokenMessageStream();

  Stream<SpeechStatistics> statisticsStream();

  Stream<List<SpeechQueueItem>> queueStream();
}
