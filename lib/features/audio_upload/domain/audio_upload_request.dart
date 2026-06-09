class AudioUploadRequest {
  const AudioUploadRequest({
    required this.requestId,
    required this.language,
    required this.audioBytesLength,
    required this.createdAt,
  });

  final String requestId;
  final String language;
  final int audioBytesLength;
  final DateTime createdAt;
}
