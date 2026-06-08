import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/speech/speech_output_service.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';

void main() {
  test('service delegates speech lifecycle and streams', () async {
    final repository = MockSpeechRepository(
      initializationDelay: const Duration(milliseconds: 5),
      sentenceDuration: const Duration(milliseconds: 5),
    );
    final service = SpeechOutputService(repository);
    final message = service.spokenMessageStream().first;

    await service.speakFinal('hello');

    expect((await message).type, SpeechMessageType.finalResult);
    expect(await service.speechStateStream().first, SpeechState.ready);
    expect((await service.statisticsStream().first).spokenCount, 1);
    await service.dispose();
  });
}
