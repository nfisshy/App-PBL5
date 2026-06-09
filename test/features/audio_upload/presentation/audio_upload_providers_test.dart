import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/audio_upload/data/mock_audio_upload_repository.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_state.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';
import 'package:photomanager/features/audio_upload/presentation/audio_upload_providers.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';

void main() {
  test('providers run the mock capture-to-upload-to-speech pipeline', () async {
    final uploadRepository = MockAudioUploadRepository(
      stageDelay: const Duration(milliseconds: 5),
    );
    final speechRepository = MockSpeechRepository(
      initializationDelay: const Duration(milliseconds: 5),
      sentenceDuration: const Duration(milliseconds: 5),
    );
    final container = ProviderContainer(
      overrides: [
        audioUploadRepositoryProvider.overrideWithValue(uploadRepository),
        speechRepositoryProvider.overrideWithValue(speechRepository),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await uploadRepository.dispose();
      await speechRepository.dispose();
    });

    final completed = _waitForState(container, AudioUploadState.completed);
    final response = _waitForResponse(container);
    final statistics = _waitForStatistics(container);
    final spokenMessages = _collectSpeechMessages(container, 2);

    await container.read(audioUploadServiceProvider).uploadAudio(
          language: 'vi',
          audioBytesLength: 32000,
        );

    expect(await completed, AudioUploadState.completed);
    expect((await response).finalSource, 'speech');
    expect(
      (await spokenMessages).map((message) => message.text),
      ['hello', 'hello how are you'],
    );
    expect((await statistics).successfulRequests, 1);
  });
}

Future<AudioUploadStatistics> _waitForStatistics(ProviderContainer container) {
  final completer = Completer<AudioUploadStatistics>();
  late final ProviderSubscription<AsyncValue<AudioUploadStatistics>>
      subscription;
  subscription = container.listen(
    audioUploadStatisticsProvider,
    (previous, next) {
      final statistics = next.valueOrNull;
      if (statistics != null &&
          statistics.successfulRequests == 1 &&
          !completer.isCompleted) {
        completer.complete(statistics);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<AudioUploadState> _waitForState(
  ProviderContainer container,
  AudioUploadState expected,
) {
  final completer = Completer<AudioUploadState>();
  late final ProviderSubscription<AsyncValue<AudioUploadState>> subscription;
  subscription = container.listen(
    audioUploadStateProvider,
    (previous, next) {
      if (next.valueOrNull == expected && !completer.isCompleted) {
        completer.complete(expected);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<AudioUploadResponse> _waitForResponse(ProviderContainer container) {
  final completer = Completer<AudioUploadResponse>();
  late final ProviderSubscription<AsyncValue<AudioUploadResponse>> subscription;
  subscription = container.listen(
    audioUploadResponseProvider,
    (previous, next) {
      final response = next.valueOrNull;
      if (response != null && !completer.isCompleted) {
        completer.complete(response);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}

Future<List<SpeechMessage>> _collectSpeechMessages(
  ProviderContainer container,
  int count,
) {
  final messages = <SpeechMessage>[];
  final completer = Completer<List<SpeechMessage>>();
  late final ProviderSubscription<AsyncValue<SpeechMessage>> subscription;
  subscription = container.listen(
    speechMessageProvider,
    (previous, next) {
      final message = next.valueOrNull;
      if (message != null) {
        messages.add(message);
        if (messages.length == count && !completer.isCompleted) {
          completer.complete(List.unmodifiable(messages));
        }
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
