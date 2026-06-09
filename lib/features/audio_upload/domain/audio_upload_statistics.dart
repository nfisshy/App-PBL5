class AudioUploadStatistics {
  const AudioUploadStatistics({
    required this.uploadedRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.lastUploadAt,
  });

  const AudioUploadStatistics.empty()
      : uploadedRequests = 0,
        successfulRequests = 0,
        failedRequests = 0,
        lastUploadAt = null;

  final int uploadedRequests;
  final int successfulRequests;
  final int failedRequests;
  final DateTime? lastUploadAt;
}
