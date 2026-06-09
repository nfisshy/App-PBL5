import 'package:photomanager/features/audio_upload/data/dtos/audio_upload_response_dto.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_response.dart';

extension AudioUploadResponseDtoMapper on AudioUploadResponseDto {
  AudioUploadResponse toDomain() {
    return AudioUploadResponse(
      draftText: draftText,
      finalText: finalText,
      finalSource: finalSource,
    );
  }
}

extension AudioUploadResponseMapper on AudioUploadResponse {
  AudioUploadResponseDto toDto() {
    return AudioUploadResponseDto(
      draftText: draftText,
      finalText: finalText,
      finalSource: finalSource,
    );
  }
}
