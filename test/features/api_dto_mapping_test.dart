import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/auth/data/dtos/login_request_dto.dart';
import 'package:photomanager/features/auth/data/dtos/login_response_dto.dart';
import 'package:photomanager/features/auth/data/dtos/user_dto.dart';
import 'package:photomanager/features/auth/data/mappers/user_mapper.dart';
import 'package:photomanager/features/contacts/data/dtos/contact_dto.dart';
import 'package:photomanager/features/contacts/data/mappers/contact_mapper.dart';
import 'package:photomanager/features/speech_output/data/dtos/speech_request_dto.dart';
import 'package:photomanager/features/speech_output/data/dtos/speech_response_dto.dart';
import 'package:photomanager/features/speech_output/data/mappers/speech_response_mapper.dart';
import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';

void main() {
  test('auth DTOs map to JSON and domain entities', () {
    const request = LoginRequestDto(email: 'a@b.com', password: 'secret');
    final response = LoginResponseDto.fromJson(
      const {
        'user': {'email': 'a@b.com', 'username': 'Admin'},
      },
    );
    final domain = response.user.toDomain();

    expect(request.toJson()['email'], 'a@b.com');
    expect(domain.username, 'Admin');
    expect(domain.toDto(), isA<UserDto>());
  });

  test('contact DTO maps both directions', () {
    final dto = ContactDto.fromJson(
      const {'username': 'dat', 'display_name': 'Nguyen Tien Dat'},
    );

    expect(dto.toDomain().displayName, 'Nguyen Tien Dat');
    expect(dto.toDomain().toDto().toJson()['username'], 'dat');
  });

  test('speech DTOs preserve server-compatible snake case and map messages',
      () {
    const request = SpeechRequestDto(language: 'vi', wavBytesLength: 16000);
    final response = SpeechResponseDto.fromJson(
      const {
        'draft_text': 'Xin chao',
        'final_text': 'Xin chao ban',
        'final_source': 'speech',
      },
    );
    final messages = response.toDomainMessages(
      createdAt: DateTime.utc(2026),
    );

    expect(request.toJson()['wav_bytes_length'], 16000);
    expect(response.toJson()['final_source'], 'speech');
    expect(messages.map((message) => message.type), [
      SpeechMessageType.draft,
      SpeechMessageType.finalResult,
    ]);
  });
}
