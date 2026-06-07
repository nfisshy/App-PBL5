class ConversationMessage {
  const ConversationMessage({
    required this.conversationId,
    required this.participantUsername,
    required this.participantDisplayName,
    required this.sender,
    required this.message,
    required this.createdAt,
    this.id,
  });

  final int? id;
  final String conversationId;
  final String participantUsername;
  final String participantDisplayName;
  final String sender;
  final String message;
  final DateTime createdAt;
}
