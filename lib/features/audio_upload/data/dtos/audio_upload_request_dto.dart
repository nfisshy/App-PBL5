class AudioUploadRequestDto {
  const AudioUploadRequestDto({
    required this.requestId,
    required this.language,
    required this.audioBytesLength,
    required this.createdAt,
  });

  final String requestId;
  final String language;
  final int audioBytesLength;
  final DateTime createdAt;

  factory AudioUploadRequestDto.fromJson(Map<String, Object?> json) {
    return AudioUploadRequestDto(
      requestId: json['request_id'] as String? ?? '',
      language: json['language'] as String? ?? '',
      audioBytesLength: json['audio_bytes_length'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, Object?> toJson() => {
        'request_id': requestId,
        'language': language,
        'audio_bytes_length': audioBytesLength,
        'created_at': createdAt.toIso8601String(),
      };
}
