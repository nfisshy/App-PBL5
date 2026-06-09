import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/features/audio_upload/data/dtos/audio_upload_request_dto.dart';
import 'package:photomanager/features/audio_upload/data/dtos/audio_upload_response_dto.dart';
import 'package:photomanager/features/audio_upload/data/mappers/audio_upload_request_mapper.dart';
import 'package:photomanager/features/audio_upload/data/mappers/audio_upload_response_mapper.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';

void main() {
  test('request DTO maps JSON and domain objects both directions', () {
    final createdAt = DateTime.utc(2026);
    final dto = AudioUploadRequestDto.fromJson({
      'request_id': 'request-1',
      'language': 'vi',
      'audio_bytes_length': 32000,
      'created_at': createdAt.toIso8601String(),
    });
    final domain = dto.toDomain();

    expect(domain.audioBytesLength, 32000);
    expect(domain.toDto().toJson()['language'], 'vi');
    expect(domain, isA<AudioUploadRequest>());
  });

  test('response DTO preserves server contract and maps both directions', () {
    final dto = AudioUploadResponseDto.fromJson(
      const {
        'draft_text': 'hello',
        'final_text': 'hello how are you',
        'final_source': 'speech',
      },
    );
    final domain = dto.toDomain();

    expect(domain, isA<AudioUploadResponse>());
    expect(domain.finalText, 'hello how are you');
    expect(domain.toDto().toJson()['final_source'], 'speech');
  });
}
