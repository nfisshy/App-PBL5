import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/storage/app_database.dart';
import 'package:photomanager/features/conversation/data/drift_conversation_repository.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';

void main() {
  late AppDatabase database;
  late DriftConversationRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftConversationRepository(database);
  });

  tearDown(() => database.close());

  test('saves and returns conversation messages chronologically', () async {
    await repository.saveMessage(_message('Second', second: 2));
    await repository.saveMessage(_message('First', second: 1));

    final messages = await repository.getConversationHistory('dat');

    expect(messages.map((message) => message.message), ['First', 'Second']);
  });

  test('returns latest message summary for each conversation', () async {
    await repository.saveMessage(_message('First', second: 1));
    await repository.saveMessage(_message('Latest', second: 2));
    await repository.saveMessage(
      _message(
        'Other',
        second: 3,
        conversationId: 'linh',
        participantUsername: 'linh',
        participantDisplayName: 'Tran Thi Linh',
      ),
    );

    final histories = await repository.getAllConversations();

    expect(histories, hasLength(2));
    expect(histories.first.conversationId, 'linh');
    expect(histories.last.lastMessage, 'Latest');
  });

  test('deletes one conversation and clears all history', () async {
    await repository.saveMessage(_message('Dat message', second: 1));
    await repository.saveMessage(
      _message(
        'Linh message',
        second: 2,
        conversationId: 'linh',
        participantUsername: 'linh',
        participantDisplayName: 'Tran Thi Linh',
      ),
    );

    await repository.deleteConversation('dat');
    expect(await repository.getConversationHistory('dat'), isEmpty);
    expect(await repository.getAllConversations(), hasLength(1));

    await repository.clearAllHistory();
    expect(await repository.getAllConversations(), isEmpty);
  });
}

ConversationMessage _message(
  String message, {
  required int second,
  String conversationId = 'dat',
  String participantUsername = 'dat',
  String participantDisplayName = 'Nguyen Tien Dat',
}) {
  return ConversationMessage(
    conversationId: conversationId,
    participantUsername: participantUsername,
    participantDisplayName: participantDisplayName,
    senderUsername: 'huy',
    senderDisplayName: 'HUY',
    message: message,
    createdAt: DateTime.utc(2026, 1, 1, 0, 0, second),
  );
}
