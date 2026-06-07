import 'package:drift/drift.dart';
import 'package:photomanager/core/storage/app_database.dart';
import 'package:photomanager/features/conversation/domain/conversation_history.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart'
    as domain;
import 'package:photomanager/features/conversation/domain/conversation_repository.dart';

class DriftConversationRepository implements ConversationRepository {
  const DriftConversationRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveMessage(domain.ConversationMessage message) async {
    await _database.into(_database.conversationTable).insert(
          ConversationTableCompanion.insert(
            conversationId: message.conversationId,
            participantUsername: message.participantUsername,
            participantDisplayName: message.participantDisplayName,
            sender: message.sender,
            message: message.message,
            createdAt: message.createdAt,
          ),
        );
  }

  @override
  Future<List<domain.ConversationMessage>> getConversationHistory(
    String conversationId,
  ) async {
    final query = _database.select(_database.conversationTable)
      ..where((table) => table.conversationId.equals(conversationId))
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);

    final rows = await query.get();
    return rows.map(_toMessage).toList(growable: false);
  }

  @override
  Future<List<ConversationHistory>> getAllConversations() async {
    final query = _database.select(_database.conversationTable)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    final rows = await query.get();
    final histories = <ConversationHistory>[];
    final seenConversationIds = <String>{};

    for (final row in rows) {
      if (!seenConversationIds.add(row.conversationId)) {
        continue;
      }

      histories.add(
        ConversationHistory(
          conversationId: row.conversationId,
          participantUsername: row.participantUsername,
          participantDisplayName: row.participantDisplayName,
          lastMessage: row.message,
          lastMessageAt: row.createdAt,
        ),
      );
    }

    return histories;
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await (_database.delete(_database.conversationTable)
          ..where((table) => table.conversationId.equals(conversationId)))
        .go();
  }

  @override
  Future<void> clearAllHistory() async {
    await _database.delete(_database.conversationTable).go();
  }

  domain.ConversationMessage _toMessage(ConversationTableData row) {
    return domain.ConversationMessage(
      id: row.id,
      conversationId: row.conversationId,
      participantUsername: row.participantUsername,
      participantDisplayName: row.participantDisplayName,
      sender: row.sender,
      message: row.message,
      createdAt: row.createdAt,
    );
  }
}
