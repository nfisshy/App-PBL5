import 'package:drift/drift.dart';

class ConversationTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get conversationId => text()();

  TextColumn get participantUsername => text()();

  TextColumn get participantDisplayName => text()();

  TextColumn get senderUsername => text()();

  TextColumn get senderDisplayName => text()();

  TextColumn get message => text()();

  DateTimeColumn get createdAt => dateTime()();
}
