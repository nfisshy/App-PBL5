class ConversationHistory {
  const ConversationHistory({
    required this.conversationId,
    required this.participantUsername,
    required this.participantDisplayName,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  final String conversationId;
  final String participantUsername;
  final String participantDisplayName;
  final String lastMessage;
  final DateTime lastMessageAt;
}
