import 'package:photomanager/features/speech_output/data/dtos/speech_response_dto.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';

extension SpeechResponseDtoMapper on SpeechResponseDto {
  List<SpeechMessage> toDomainMessages({DateTime? createdAt}) {
    final timestamp = createdAt ?? DateTime.now();
    return [
      if (draftText.isNotEmpty)
        SpeechMessage(
          messageId: 'draft-${timestamp.microsecondsSinceEpoch}',
          text: draftText,
          type: SpeechMessageType.draft,
          createdAt: timestamp,
        ),
      if (finalText.isNotEmpty)
        SpeechMessage(
          messageId: 'final-${timestamp.microsecondsSinceEpoch}',
          text: finalText,
          type: SpeechMessageType.finalResult,
          createdAt: timestamp,
        ),
    ];
  }
}
