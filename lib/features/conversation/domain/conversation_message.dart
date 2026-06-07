class ConversationMessage {
  const ConversationMessage({
    required this.conversationId,
    required this.participantUsername,
    required this.participantDisplayName,
    required this.senderUsername,
    required this.senderDisplayName,
    required this.message,
    required this.createdAt,
    this.id,
  });

  final int? id;
  final String conversationId;
  final String participantUsername;
  final String participantDisplayName;
  final String senderUsername;
  final String senderDisplayName;
  final String message;
  final DateTime createdAt;
}
