import 'package:flutter/material.dart';
import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';

class SpeechMessageCard extends StatelessWidget {
  const SpeechMessageCard({
    required this.message,
    super.key,
  });

  final SpeechMessage? message;

  @override
  Widget build(BuildContext context) {
    final currentMessage = message;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: currentMessage == null
            ? const Text('No spoken message yet.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentMessage.type.label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(currentMessage.text),
                ],
              ),
      ),
    );
  }
}

extension SpeechMessageTypeLabel on SpeechMessageType {
  String get label => switch (this) {
        SpeechMessageType.draft => 'Draft',
        SpeechMessageType.finalResult => 'Final',
        SpeechMessageType.system => 'System',
      };
}
