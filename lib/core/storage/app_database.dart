import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photomanager/core/storage/conversation_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ConversationTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await customStatement('''
              CREATE TABLE conversation_table_v2 (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                conversation_id TEXT NOT NULL,
                participant_username TEXT NOT NULL,
                participant_display_name TEXT NOT NULL,
                sender_username TEXT NOT NULL,
                sender_display_name TEXT NOT NULL,
                message TEXT NOT NULL,
                created_at INTEGER NOT NULL
              )
            ''');
            await customStatement('''
              INSERT INTO conversation_table_v2 (
                id,
                conversation_id,
                participant_username,
                participant_display_name,
                sender_username,
                sender_display_name,
                message,
                created_at
              )
              SELECT
                id,
                conversation_id,
                participant_username,
                participant_display_name,
                LOWER(sender),
                sender,
                message,
                created_at
              FROM conversation_table
            ''');
            await customStatement('DROP TABLE conversation_table');
            await customStatement(
              'ALTER TABLE conversation_table_v2 RENAME TO conversation_table',
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final databaseFile = File(
      p.join(directory.path, 'conversation_history.sqlite'),
    );

    return NativeDatabase.createInBackground(databaseFile);
  });
}
