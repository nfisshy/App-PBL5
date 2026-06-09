import 'package:photomanager/features/audio_upload/data/dtos/audio_upload_request_dto.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_request.dart';

extension AudioUploadRequestDtoMapper on AudioUploadRequestDto {
  AudioUploadRequest toDomain() {
    return AudioUploadRequest(
      requestId: requestId,
      language: language,
      audioBytesLength: audioBytesLength,
      createdAt: createdAt,
    );
  }
}

extension AudioUploadRequestMapper on AudioUploadRequest {
  AudioUploadRequestDto toDto() {
    return AudioUploadRequestDto(
      requestId: requestId,
      language: language,
      audioBytesLength: audioBytesLength,
      createdAt: createdAt,
    );
  }
}
