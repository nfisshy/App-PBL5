class SpeechRequestDto {
  const SpeechRequestDto({
    required this.language,
    required this.wavBytesLength,
  });

  final String language;
  final int wavBytesLength;

  factory SpeechRequestDto.fromJson(Map<String, Object?> json) {
    return SpeechRequestDto(
      language: json['language'] as String? ?? '',
      wavBytesLength: json['wav_bytes_length'] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() => {
        'language': language,
        'wav_bytes_length': wavBytesLength,
      };
}
