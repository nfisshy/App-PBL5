import 'package:flutter/material.dart';
import 'package:photomanager/features/call/domain/conversation_message.dart';
import 'package:photomanager/features/call/presentation/widgets/conversation_message_bubble.dart';

class ConversationMessageList extends StatelessWidget {
  const ConversationMessageList({
    required this.messages,
    super.key,
  });

  final List<ConversationMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No translated messages yet.'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return ConversationMessageBubble(message: messages[index]);
      },
    );
  }
}
