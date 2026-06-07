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
  int get schemaVersion => 1;
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
