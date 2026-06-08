import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';

void main() {
  late MockSpeechRepository repository;

  setUp(() {
    repository = MockSpeechRepository(
      initializationDelay: const Duration(milliseconds: 5),
      sentenceDuration: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => repository.dispose());

  test('initializes from idle through initializing to ready', () async {
    final states = <SpeechState>[];
    final subscription = repository.speechStateStream().listen(states.add);

    await repository.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      containsAllInOrder([
        SpeechState.idle,
        SpeechState.initializing,
        SpeechState.ready,
      ]),
    );
    await subscription.cancel();
  });

  test('processes queued messages sequentially', () async {
    final messages = repository.spokenMessageStream().take(3).toList();

    unawaited(repository.speakDraft('draft one'));
    unawaited(repository.speakDraft('draft two'));
    unawaited(repository.speakFinal('final result'));

    expect(
      (await messages).map((message) => message.text),
      ['draft one', 'draft two', 'final result'],
    );
    expect(await repository.speechStateStream().first, SpeechState.ready);
  });

  test('pauses and resumes current speech', () async {
    final spoken = repository.spokenMessageStream().first;
    unawaited(repository.speakFinal('message'));
    await repository
        .speechStateStream()
        .firstWhere((state) => state == SpeechState.speaking);

    await repository.pause();
    expect(await repository.speechStateStream().first, SpeechState.paused);
    await Future<void>.delayed(const Duration(milliseconds: 15));

    await repository.resume();
    expect((await spoken).text, 'message');
    expect(await repository.speechStateStream().first, SpeechState.ready);
  });

  test('stop clears the current message and queue', () async {
    unawaited(repository.speakFinal('first'));
    unawaited(repository.speakFinal('second'));
    await repository
        .speechStateStream()
        .firstWhere((state) => state == SpeechState.speaking);

    await repository.stop();

    expect(await repository.speechStateStream().first, SpeechState.stopped);
    expect(await repository.queueStream().first, isEmpty);
    expect((await repository.statisticsStream().first).queuedCount, 0);
  });

  test('updates statistics after playback', () async {
    final completed = repository
        .statisticsStream()
        .firstWhere((statistics) => statistics.spokenCount == 1);

    await repository.speakSystem('system message');
    final statistics = await completed;

    expect(statistics.spokenCount, 1);
    expect(statistics.queuedCount, 0);
    expect(statistics.isSpeaking, isFalse);
  });
}
