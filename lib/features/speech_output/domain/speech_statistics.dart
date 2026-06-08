class SpeechStatistics {
  const SpeechStatistics({
    required this.spokenCount,
    required this.queuedCount,
    required this.isSpeaking,
  });

  const SpeechStatistics.empty()
      : spokenCount = 0,
        queuedCount = 0,
        isSpeaking = false;

  final int spokenCount;
  final int queuedCount;
  final bool isSpeaking;
}
