import 'package:flutter/material.dart';
import 'package:photomanager/features/media/domain/audio_stream_state.dart';
import 'package:photomanager/features/media/domain/video_stream_state.dart';

class StreamStatisticsCard extends StatelessWidget {
  const StreamStatisticsCard({
    required this.videoState,
    required this.audioState,
    super.key,
  });

  final VideoStreamState videoState;
  final AudioStreamState audioState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stream Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _Statistic(label: 'Video FPS', value: '${videoState.fps}'),
            _Statistic(label: 'Resolution', value: videoState.resolution),
            _Statistic(
              label: 'Audio Sample Rate',
              value: '${audioState.sampleRate} Hz',
            ),
            _Statistic(
              label: 'Streaming Status',
              value: videoState.isStreaming || audioState.isStreaming
                  ? 'Streaming'
                  : 'Stopped',
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
