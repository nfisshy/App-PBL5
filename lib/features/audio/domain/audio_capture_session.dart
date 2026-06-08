class AudioCaptureSession {
  const AudioCaptureSession({
    required this.sessionId,
    required this.startedAt,
    required this.totalChunks,
    required this.totalDurationMs,
    this.endedAt,
  });

  final String sessionId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalChunks;
  final int totalDurationMs;

  AudioCaptureSession copyWith({
    DateTime? endedAt,
    int? totalChunks,
    int? totalDurationMs,
  }) {
    return AudioCaptureSession(
      sessionId: sessionId,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalChunks: totalChunks ?? this.totalChunks,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    );
  }
}
