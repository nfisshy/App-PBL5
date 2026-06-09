class AudioUploadResponseDto {
  const AudioUploadResponseDto({
    required this.draftText,
    required this.finalText,
    required this.finalSource,
  });

  final String draftText;
  final String finalText;
  final String finalSource;

  factory AudioUploadResponseDto.fromJson(Map<String, Object?> json) {
    return AudioUploadResponseDto(
      draftText: json['draft_text'] as String? ?? '',
      finalText: json['final_text'] as String? ?? '',
      finalSource: json['final_source'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'draft_text': draftText,
        'final_text': finalText,
        'final_source': finalSource,
      };
}
