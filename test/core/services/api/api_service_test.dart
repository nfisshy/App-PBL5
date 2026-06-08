import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/network/mock_api_client.dart';
import 'package:photomanager/core/network/network_result.dart';
import 'package:photomanager/core/services/api/api_service.dart';
import 'package:photomanager/features/auth/data/dtos/login_request_dto.dart';
import 'package:photomanager/features/speech_output/data/dtos/speech_request_dto.dart';

void main() {
  test('service decodes login, contacts, speech, and mock upload responses',
      () async {
    final service = ApiService(MockApiClient(responseDelay: Duration.zero));

    final login = await service.login(
      const LoginRequestDto(
        email: 'admin@test.com',
        password: '123456',
      ),
    );
    final contacts = await service.getContacts();
    final speech = await service.processSpeech(
      const SpeechRequestDto(language: 'vi', wavBytesLength: 32000),
    );
    final upload = await service.uploadWav(
      bytes: const [1, 2],
      request: const SpeechRequestDto(language: 'vi', wavBytesLength: 2),
    );

    expect((login as Success).data.user.username, 'Admin');
    expect((contacts as Success).data.first.username, 'dat');
    expect((speech as Success).data.finalSource, 'speech');
    expect((upload as Success).data.finalSource, 'speech');
  });
}
