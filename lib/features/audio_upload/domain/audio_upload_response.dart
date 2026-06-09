class AudioUploadResponse {
  const AudioUploadResponse({
    required this.draftText,
    required this.finalText,
    required this.finalSource,
  });

  final String draftText;
  final String finalText;
  final String finalSource;
}
