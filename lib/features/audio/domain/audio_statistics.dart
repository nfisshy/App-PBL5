class AudioStatistics {
  const AudioStatistics({
    required this.chunkCount,
    required this.totalDurationMs,
    required this.averageChunkSize,
    required this.isRecording,
  });

  const AudioStatistics.empty()
      : chunkCount = 0,
        totalDurationMs = 0,
        averageChunkSize = 0,
        isRecording = false;

  final int chunkCount;
  final int totalDurationMs;
  final double averageChunkSize;
  final bool isRecording;
}
