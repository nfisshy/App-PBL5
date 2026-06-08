import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';

void main() {
  test('providers expose state, queue, messages, and statistics', () async {
    final repository = MockSpeechRepository(
      initializationDelay: const Duration(milliseconds: 5),
      sentenceDuration: const Duration(milliseconds: 5),
    );
    final container = ProviderContainer(
      overrides: [speechRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(() async {
      container.dispose();
      await repository.dispose();
    });

    final speaking = _waitForState(container, SpeechState.speaking);
    final queued = _waitForQueueSize(container, 1);
    final message = _waitForMessage(container);
    final completed = _waitForStatistics(
      container,
      (statistics) => statistics.spokenCount == 1,
    );

    await container.read(speechOutputServiceProvider).speakDraft('draft');

    expect(await speaking, SpeechState.speaking);
    expect(await queued, 1);
    expect((await message).text, 'draft');
    expect((await completed).queuedCount, 0);
  });
}

Future<SpeechState> _waitForState(
  ProviderContainer container,
  SpeechState expected,
) {
  final completer = Completer<SpeechState>();
  late final ProviderSubscription<AsyncValue<SpeechState>> subscription;
  subscription = container.listen(
    speechStateProvider,
    (previous, next) {
      if (next.valueOrNull == expected && !completer.isCompleted) {
        completer.complete(expected);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<int> _waitForQueueSize(ProviderContainer container, int expected) {
  final completer = Completer<int>();
  late final ProviderSubscription<AsyncValue<List<SpeechQueueItem>>>
      subscription;
  subscription = container.listen(
    speechQueueProvider,
    (previous, next) {
      if (next.valueOrNull?.length == expected && !completer.isCompleted) {
        completer.complete(expected);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<SpeechMessage> _waitForMessage(ProviderContainer container) {
  final completer = Completer<SpeechMessage>();
  late final ProviderSubscription<AsyncValue<SpeechMessage>> subscription;
  subscription = container.listen(
    speechMessageProvider,
    (previous, next) {
      final message = next.valueOrNull;
      if (message != null && !completer.isCompleted) {
        completer.complete(message);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<SpeechStatistics> _waitForStatistics(
  ProviderContainer container,
  bool Function(SpeechStatistics statistics) matches,
) {
  final completer = Completer<SpeechStatistics>();
  late final ProviderSubscription<AsyncValue<SpeechStatistics>> subscription;
  subscription = container.listen(
    speechStatisticsProvider,
    (previous, next) {
      final statistics = next.valueOrNull;
      if (statistics != null && matches(statistics) && !completer.isCompleted) {
        completer.complete(statistics);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
