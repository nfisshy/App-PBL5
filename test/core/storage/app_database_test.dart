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
            sender: 'HUY',
            message: 'Xin chào',
            createdAt: createdAt,
          ),
        );

    final rows = await database.select(database.conversationTable).get();

    expect(rows, hasLength(1));
    expect(rows.single.conversationId, 'dat');
    expect(rows.single.message, 'Xin chào');
    expect(
      rows.single.createdAt.millisecondsSinceEpoch,
      createdAt.millisecondsSinceEpoch,
    );
  });
}
