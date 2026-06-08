import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';
import 'package:photomanager/features/conversation/presentation/conversation_providers.dart';
import 'package:photomanager/features/conversation/presentation/widgets/history_message_bubble.dart';
import 'package:photomanager/features/speech_output/presentation/speech_output_providers.dart';
import 'package:photomanager/shared/widgets/app_loading_indicator.dart';

class ConversationHistoryDetailScreen extends ConsumerWidget {
  const ConversationHistoryDetailScreen({
    required this.conversationId,
    super.key,
  });

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(conversationDetailProvider(conversationId));
    final participantName =
        messages.valueOrNull?.firstOrNull?.participantDisplayName;

    return Scaffold(
      appBar: AppBar(
        title: Text(participantName ?? 'Conversation'),
      ),
      body: SafeArea(
        child: messages.when(
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) => _DetailError(
            onRetry: () => ref
                .read(conversationDetailProvider(conversationId).notifier)
                .load(),
          ),
          data: (items) => items.isEmpty
              ? const Center(child: Text('No stored messages.'))
              : _MessageList(
                  messages: items,
                  onSpeak: (message) {
                    ref
                        .read(speechOutputServiceProvider)
                        .speakFinal(message.message);
                  },
                ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.onSpeak,
  });

  final List<ConversationMessage> messages;
  final ValueChanged<ConversationMessage> onSpeak;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final message = messages[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: HistoryMessageBubble(message: message)),
                IconButton(
                  tooltip: 'Speak message',
                  onPressed: () => onSpeak(message),
                  icon: const Icon(Icons.volume_up_outlined),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to load this conversation.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
