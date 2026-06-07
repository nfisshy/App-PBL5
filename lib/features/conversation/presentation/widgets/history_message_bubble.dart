import 'package:flutter/material.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';

class HistoryMessageBubble extends StatelessWidget {
  const HistoryMessageBubble({
    required this.message,
    super.key,
  });

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderDisplayName,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(message.message),
          ],
        ),
      ),
    );
  }
}
