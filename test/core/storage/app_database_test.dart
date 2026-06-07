import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photomanager/core/storage/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('stores and reads conversation table rows', () async {
    final createdAt = DateTime.utc(2026, 1, 1);

    await database.into(database.conversationTable).insert(
          ConversationTableCompanion.insert(
            conversationId: 'dat',
            participantUsername: 'dat',
            participantDisplayName: 'Nguyen Tien Dat',
            senderUsername: 'huy',
            senderDisplayName: 'HUY',
            message: 'Xin chào',
            createdAt: createdAt,
          ),
        );

    final rows = await database.select(database.conversationTable).get();

    expect(rows, hasLength(1));
    expect(rows.single.conversationId, 'dat');
    expect(rows.single.message, 'Xin chào');
    expect(rows.single.senderUsername, 'huy');
    expect(rows.single.senderDisplayName, 'HUY');
    expect(
      rows.single.createdAt.millisecondsSinceEpoch,
      createdAt.millisecondsSinceEpoch,
    );
  });

  test('migrates version 1 sender data to sender identity fields', () async {
    await database.close();
    database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase
            ..execute('''
              CREATE TABLE conversation_table (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                conversation_id TEXT NOT NULL,
                participant_username TEXT NOT NULL,
                participant_display_name TEXT NOT NULL,
                sender TEXT NOT NULL,
                message TEXT NOT NULL,
                created_at INTEGER NOT NULL
              )
            ''')
            ..execute('''
              INSERT INTO conversation_table (
                conversation_id,
                participant_username,
                participant_display_name,
                sender,
                message,
                created_at
              ) VALUES (
                'dat',
                'dat',
                'Nguyen Tien Dat',
                'HUY',
                'Xin chào',
                1
              )
            ''')
            ..userVersion = 1;
        },
      ),
    );

    final rows = await database.select(database.conversationTable).get();

    expect(rows, hasLength(1));
    expect(rows.single.senderUsername, 'huy');
    expect(rows.single.senderDisplayName, 'HUY');
    expect(rows.single.message, 'Xin chào');
  });
}
