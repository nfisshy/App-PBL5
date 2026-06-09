import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/services/audio_upload/audio_upload_service.dart';
import 'package:photomanager/core/services/speech/speech_output_service.dart';
import 'package:photomanager/features/audio_upload/data/mock_audio_upload_repository.dart';
import 'package:photomanager/features/speech_output/data/mock_speech_repository.dart';

void main() {
  test('prepares requests and sends mock responses to speech output', () async {
    final uploadRepository = MockAudioUploadRepository(
      stageDelay: const Duration(milliseconds: 5),
    );
    final speechRepository = MockSpeechRepository(
      initializationDelay: const Duration(milliseconds: 5),
      sentenceDuration: const Duration(milliseconds: 5),
    );
    final speechService = SpeechOutputService(speechRepository);
    final service = AudioUploadService(
      repository: uploadRepository,
      speechOutputService: speechService,
    );
    final spokenMessages = speechService.spokenMessageStream().take(2).toList();

    final response = await service.uploadAudioBytes(
      language: 'vi',
      bytes: const [1, 2, 3],
    );

    expect(response?.finalSource, 'speech');
    expect(
      (await spokenMessages).map((message) => message.text),
      ['hello', 'hello how are you'],
    );
    await service.dispose();
    await uploadRepository.dispose();
    await speechRepository.dispose();
  });
}
