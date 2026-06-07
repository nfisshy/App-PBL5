// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConversationTableTable extends ConversationTable
    with TableInfo<$ConversationTableTable, ConversationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _participantUsernameMeta =
      const VerificationMeta('participantUsername');
  @override
  late final GeneratedColumn<String> participantUsername =
      GeneratedColumn<String>('participant_username', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _participantDisplayNameMeta =
      const VerificationMeta('participantDisplayName');
  @override
  late final GeneratedColumn<String> participantDisplayName =
      GeneratedColumn<String>('participant_display_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderUsernameMeta =
      const VerificationMeta('senderUsername');
  @override
  late final GeneratedColumn<String> senderUsername = GeneratedColumn<String>(
      'sender_username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderDisplayNameMeta =
      const VerificationMeta('senderDisplayName');
  @override
  late final GeneratedColumn<String> senderDisplayName =
      GeneratedColumn<String>('sender_display_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        participantUsername,
        participantDisplayName,
        senderUsername,
        senderDisplayName,
        message,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConversationTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('participant_username')) {
      context.handle(
          _participantUsernameMeta,
          participantUsername.isAcceptableOrUnknown(
              data['participant_username']!, _participantUsernameMeta));
    } else if (isInserting) {
      context.missing(_participantUsernameMeta);
    }
    if (data.containsKey('participant_display_name')) {
      context.handle(
          _participantDisplayNameMeta,
          participantDisplayName.isAcceptableOrUnknown(
              data['participant_display_name']!, _participantDisplayNameMeta));
    } else if (isInserting) {
      context.missing(_participantDisplayNameMeta);
    }
    if (data.containsKey('sender_username')) {
      context.handle(
          _senderUsernameMeta,
          senderUsername.isAcceptableOrUnknown(
              data['sender_username']!, _senderUsernameMeta));
    } else if (isInserting) {
      context.missing(_senderUsernameMeta);
    }
    if (data.containsKey('sender_display_name')) {
      context.handle(
          _senderDisplayNameMeta,
          senderDisplayName.isAcceptableOrUnknown(
              data['sender_display_name']!, _senderDisplayNameMeta));
    } else if (isInserting) {
      context.missing(_senderDisplayNameMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      participantUsername: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}participant_username'])!,
      participantDisplayName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}participant_display_name'])!,
      senderUsername: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sender_username'])!,
      senderDisplayName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sender_display_name'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ConversationTableTable createAlias(String alias) {
    return $ConversationTableTable(attachedDatabase, alias);
  }
}

class ConversationTableData extends DataClass
    implements Insertable<ConversationTableData> {
  final int id;
  final String conversationId;
  final String participantUsername;
  final String participantDisplayName;
  final String senderUsername;
  final String senderDisplayName;
  final String message;
  final DateTime createdAt;
  const ConversationTableData(
      {required this.id,
      required this.conversationId,
      required this.participantUsername,
      required this.participantDisplayName,
      required this.senderUsername,
      required this.senderDisplayName,
      required this.message,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['participant_username'] = Variable<String>(participantUsername);
    map['participant_display_name'] = Variable<String>(participantDisplayName);
    map['sender_username'] = Variable<String>(senderUsername);
    map['sender_display_name'] = Variable<String>(senderDisplayName);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConversationTableCompanion toCompanion(bool nullToAbsent) {
    return ConversationTableCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      participantUsername: Value(participantUsername),
      participantDisplayName: Value(participantDisplayName),
      senderUsername: Value(senderUsername),
      senderDisplayName: Value(senderDisplayName),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory ConversationTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationTableData(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      participantUsername:
          serializer.fromJson<String>(json['participantUsername']),
      participantDisplayName:
          serializer.fromJson<String>(json['participantDisplayName']),
      senderUsername: serializer.fromJson<String>(json['senderUsername']),
      senderDisplayName: serializer.fromJson<String>(json['senderDisplayName']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'participantUsername': serializer.toJson<String>(participantUsername),
      'participantDisplayName':
          serializer.toJson<String>(participantDisplayName),
      'senderUsername': serializer.toJson<String>(senderUsername),
      'senderDisplayName': serializer.toJson<String>(senderDisplayName),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConversationTableData copyWith(
          {int? id,
          String? conversationId,
          String? participantUsername,
          String? participantDisplayName,
          String? senderUsername,
          String? senderDisplayName,
          String? message,
          DateTime? createdAt}) =>
      ConversationTableData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        participantUsername: participantUsername ?? this.participantUsername,
        participantDisplayName:
            participantDisplayName ?? this.participantDisplayName,
        senderUsername: senderUsername ?? this.senderUsername,
        senderDisplayName: senderDisplayName ?? this.senderDisplayName,
        message: message ?? this.message,
        createdAt: createdAt ?? this.createdAt,
      );
  ConversationTableData copyWithCompanion(ConversationTableCompanion data) {
    return ConversationTableData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      participantUsername: data.participantUsername.present
          ? data.participantUsername.value
          : this.participantUsername,
      participantDisplayName: data.participantDisplayName.present
          ? data.participantDisplayName.value
          : this.participantDisplayName,
      senderUsername: data.senderUsername.present
          ? data.senderUsername.value
          : this.senderUsername,
      senderDisplayName: data.senderDisplayName.present
          ? data.senderDisplayName.value
          : this.senderDisplayName,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTableData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('participantUsername: $participantUsername, ')
          ..write('participantDisplayName: $participantDisplayName, ')
          ..write('senderUsername: $senderUsername, ')
          ..write('senderDisplayName: $senderDisplayName, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      conversationId,
      participantUsername,
      participantDisplayName,
      senderUsername,
      senderDisplayName,
      message,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationTableData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.participantUsername == this.participantUsername &&
          other.participantDisplayName == this.participantDisplayName &&
          other.senderUsername == this.senderUsername &&
          other.senderDisplayName == this.senderDisplayName &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class ConversationTableCompanion
    extends UpdateCompanion<ConversationTableData> {
  final Value<int> id;
  final Value<String> conversationId;
  final Value<String> participantUsername;
  final Value<String> participantDisplayName;
  final Value<String> senderUsername;
  final Value<String> senderDisplayName;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const ConversationTableCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.participantUsername = const Value.absent(),
    this.participantDisplayName = const Value.absent(),
    this.senderUsername = const Value.absent(),
    this.senderDisplayName = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ConversationTableCompanion.insert({
    this.id = const Value.absent(),
    required String conversationId,
    required String participantUsername,
    required String participantDisplayName,
    required String senderUsername,
    required String senderDisplayName,
    required String message,
    required DateTime createdAt,
  })  : conversationId = Value(conversationId),
        participantUsername = Value(participantUsername),
        participantDisplayName = Value(participantDisplayName),
        senderUsername = Value(senderUsername),
        senderDisplayName = Value(senderDisplayName),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<ConversationTableData> custom({
    Expression<int>? id,
    Expression<String>? conversationId,
    Expression<String>? participantUsername,
    Expression<String>? participantDisplayName,
    Expression<String>? senderUsername,
    Expression<String>? senderDisplayName,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (participantUsername != null)
        'participant_username': participantUsername,
      if (participantDisplayName != null)
        'participant_display_name': participantDisplayName,
      if (senderUsername != null) 'sender_username': senderUsername,
      if (senderDisplayName != null) 'sender_display_name': senderDisplayName,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ConversationTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? conversationId,
      Value<String>? participantUsername,
      Value<String>? participantDisplayName,
      Value<String>? senderUsername,
      Value<String>? senderDisplayName,
      Value<String>? message,
      Value<DateTime>? createdAt}) {
    return ConversationTableCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      participantUsername: participantUsername ?? this.participantUsername,
      participantDisplayName:
          participantDisplayName ?? this.participantDisplayName,
      senderUsername: senderUsername ?? this.senderUsername,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (participantUsername.present) {
      map['participant_username'] = Variable<String>(participantUsername.value);
    }
    if (participantDisplayName.present) {
      map['participant_display_name'] =
          Variable<String>(participantDisplayName.value);
    }
    if (senderUsername.present) {
      map['sender_username'] = Variable<String>(senderUsername.value);
    }
    if (senderDisplayName.present) {
      map['sender_display_name'] = Variable<String>(senderDisplayName.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationTableCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('participantUsername: $participantUsername, ')
          ..write('participantDisplayName: $participantDisplayName, ')
          ..write('senderUsername: $senderUsername, ')
          ..write('senderDisplayName: $senderDisplayName, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationTableTable conversationTable =
      $ConversationTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [conversationTable];
}

typedef $$ConversationTableTableCreateCompanionBuilder
    = ConversationTableCompanion Function({
  Value<int> id,
  required String conversationId,
  required String participantUsername,
  required String participantDisplayName,
  required String senderUsername,
  required String senderDisplayName,
  required String message,
  required DateTime createdAt,
});
typedef $$ConversationTableTableUpdateCompanionBuilder
    = ConversationTableCompanion Function({
  Value<int> id,
  Value<String> conversationId,
  Value<String> participantUsername,
  Value<String> participantDisplayName,
  Value<String> senderUsername,
  Value<String> senderDisplayName,
  Value<String> message,
  Value<DateTime> createdAt,
});

class $$ConversationTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantUsername => $composableBuilder(
      column: $table.participantUsername,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantDisplayName => $composableBuilder(
      column: $table.participantDisplayName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderDisplayName => $composableBuilder(
      column: $table.senderDisplayName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ConversationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantUsername => $composableBuilder(
      column: $table.participantUsername,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantDisplayName => $composableBuilder(
      column: $table.participantDisplayName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderDisplayName => $composableBuilder(
      column: $table.senderDisplayName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationTableTable> {
  $$ConversationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get participantUsername => $composableBuilder(
      column: $table.participantUsername, builder: (column) => column);

  GeneratedColumn<String> get participantDisplayName => $composableBuilder(
      column: $table.participantDisplayName, builder: (column) => column);

  GeneratedColumn<String> get senderUsername => $composableBuilder(
      column: $table.senderUsername, builder: (column) => column);

  GeneratedColumn<String> get senderDisplayName => $composableBuilder(
      column: $table.senderDisplayName, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConversationTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationTableTable,
    ConversationTableData,
    $$ConversationTableTableFilterComposer,
    $$ConversationTableTableOrderingComposer,
    $$ConversationTableTableAnnotationComposer,
    $$ConversationTableTableCreateCompanionBuilder,
    $$ConversationTableTableUpdateCompanionBuilder,
    (
      ConversationTableData,
      BaseReferences<_$AppDatabase, $ConversationTableTable,
          ConversationTableData>
    ),
    ConversationTableData,
    PrefetchHooks Function()> {
  $$ConversationTableTableTableManager(
      _$AppDatabase db, $ConversationTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> participantUsername = const Value.absent(),
            Value<String> participantDisplayName = const Value.absent(),
            Value<String> senderUsername = const Value.absent(),
            Value<String> senderDisplayName = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ConversationTableCompanion(
            id: id,
            conversationId: conversationId,
            participantUsername: participantUsername,
            participantDisplayName: participantDisplayName,
            senderUsername: senderUsername,
            senderDisplayName: senderDisplayName,
            message: message,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String conversationId,
            required String participantUsername,
            required String participantDisplayName,
            required String senderUsername,
            required String senderDisplayName,
            required String message,
            required DateTime createdAt,
          }) =>
              ConversationTableCompanion.insert(
            id: id,
            conversationId: conversationId,
            participantUsername: participantUsername,
            participantDisplayName: participantDisplayName,
            senderUsername: senderUsername,
            senderDisplayName: senderDisplayName,
            message: message,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationTableTable,
    ConversationTableData,
    $$ConversationTableTableFilterComposer,
    $$ConversationTableTableOrderingComposer,
    $$ConversationTableTableAnnotationComposer,
    $$ConversationTableTableCreateCompanionBuilder,
    $$ConversationTableTableUpdateCompanionBuilder,
    (
      ConversationTableData,
      BaseReferences<_$AppDatabase, $ConversationTableTable,
          ConversationTableData>
    ),
    ConversationTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationTableTableTableManager get conversationTable =>
      $$ConversationTableTableTableManager(_db, _db.conversationTable);
}
