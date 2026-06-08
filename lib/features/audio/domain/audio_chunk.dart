class AudioChunk {
  const AudioChunk({
    required this.chunkId,
    required this.timestamp,
    required this.durationMs,
    required this.sizeBytes,
    required this.sequenceNumber,
  });

  final String chunkId;
  final DateTime timestamp;
  final int durationMs;
  final int sizeBytes;
  final int sequenceNumber;
}
