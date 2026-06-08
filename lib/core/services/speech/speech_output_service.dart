import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';

class SpeechOutputService {
  const SpeechOutputService(this._repository);

  final SpeechRepository _repository;

  Future<void> initialize() => _repository.initialize();

  Future<void> speakDraft(String text) => _repository.speakDraft(text);

  Future<void> speakFinal(String text) => _repository.speakFinal(text);

  Future<void> speakSystem(String text) => _repository.speakSystem(text);

  Future<void> pause() => _repository.pause();

  Future<void> resume() => _repository.resume();

  Future<void> stop() => _repository.stop();

  Future<void> dispose() => _repository.dispose();

  Stream<SpeechState> speechStateStream() => _repository.speechStateStream();

  Stream<SpeechMessage> spokenMessageStream() {
    return _repository.spokenMessageStream();
  }

  Stream<SpeechStatistics> statisticsStream() {
    return _repository.statisticsStream();
  }

  Stream<List<SpeechQueueItem>> queueStream() => _repository.queueStream();
}
