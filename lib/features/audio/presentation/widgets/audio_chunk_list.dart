import 'package:flutter/material.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';

class AudioChunkList extends StatelessWidget {
  const AudioChunkList({
    required this.chunks,
    super.key,
  });

  final List<AudioChunk> chunks;

  @override
  Widget build(BuildContext context) {
    if (chunks.isEmpty) {
      return const Center(child: Text('No audio chunks generated yet.'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chunks.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chunk = chunks[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${chunk.sequenceNumber}')),
          title: Text('Chunk #${chunk.sequenceNumber}'),
          subtitle: Text(
            '${chunk.sizeBytes} bytes • ${chunk.durationMs} ms',
          ),
          trailing: Text(_formatTimestamp(chunk.timestamp)),
        );
      },
    );
  }
}

String _formatTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}
