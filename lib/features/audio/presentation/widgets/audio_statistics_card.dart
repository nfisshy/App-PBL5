import 'package:flutter/material.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';

class AudioStatisticsCard extends StatelessWidget {
  const AudioStatisticsCard({
    required this.statistics,
    super.key,
  });

  final AudioStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _Statistic(
                label: 'Total Chunks', value: '${statistics.chunkCount}'),
            _Statistic(
              label: 'Total Duration',
              value: '${statistics.totalDurationMs} ms',
            ),
            _Statistic(
              label: 'Average Chunk Size',
              value: '${statistics.averageChunkSize.round()} bytes',
            ),
            _Statistic(
              label: 'Recording Status',
              value: statistics.isRecording ? 'Recording' : 'Not Recording',
            ),
          ],
        ),
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  const _Statistic({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
