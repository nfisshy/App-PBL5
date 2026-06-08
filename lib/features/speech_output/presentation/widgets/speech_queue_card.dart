import 'package:flutter/material.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';

class SpeechQueueCard extends StatelessWidget {
  const SpeechQueueCard({
    required this.items,
    super.key,
  });

  final List<SpeechQueueItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speech Queue (${items.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No messages queued.')
            else
              ...items.take(3).map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item.message.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
