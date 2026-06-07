import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/storage/app_database.dart';
import 'package:photomanager/features/conversation/data/drift_conversation_repository.dart';
import 'package:photomanager/features/conversation/domain/conversation_message.dart';
import 'package:photomanager/features/conversation/domain/get_conversation_history_use_case.dart';
import 'package:photomanager/features/conversation/domain/save_message_use_case.dart';

void main() {
  late AppDatabase database;
  late SaveMessageUseCase saveMessage;
  late GetConversationHistoryUseCase getConversationHistory;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftConversationRepository(database);
    saveMessage = SaveMessageUseCase(repository);
    getConversationHistory = GetConversationHistoryUseCase(repository);
  });

  tearDown(() => database.close());

  test('save and get history use cases persist and retrieve a message',
      () async {
    final message = ConversationMessage(
      conversationId: 'dat',
      participantUsername: 'dat',
      participantDisplayName: 'Nguyen Tien Dat',
      senderUsername: 'huy',
      senderDisplayName: 'HUY',
      message: 'Xin chào',
      createdAt: DateTime.utc(2026, 1, 1),
    );

    await saveMessage(message);
    final history = await getConversationHistory('dat');

    expect(history, hasLength(1));
    expect(history.single.message, 'Xin chào');
    expect(history.single.id, isNotNull);
  });
}
