import 'package:flutter/material.dart';
import 'package:photomanager/features/audio_upload/domain/audio_upload_statistics.dart';

class AudioUploadStatisticsCard extends StatelessWidget {
  const AudioUploadStatisticsCard({
    required this.statistics,
    super.key,
  });

  final AudioUploadStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Statistics',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('Uploaded Requests: ${statistics.uploadedRequests}'),
            Text('Successful Requests: ${statistics.successfulRequests}'),
            Text('Failed Requests: ${statistics.failedRequests}'),
            Text(
              statistics.lastUploadAt == null
                  ? 'Last Upload: Never'
                  : 'Last Upload: ${statistics.lastUploadAt!.toLocal()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
