/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class MatchMoveRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MatchMoveRecord._({
    this.id,
    required this.matchId,
    required this.moveIndex,
    required this.playerId,
    required this.node1R,
    required this.node1C,
    required this.node2R,
    required this.node2C,
    required this.edgeId,
    required this.claimedTrianglesJson,
    required this.extraTurn,
    required this.stateVersion,
    required this.createdAt,
  });

  factory MatchMoveRecord({
    int? id,
    required String matchId,
    required int moveIndex,
    required String playerId,
    required int node1R,
    required int node1C,
    required int node2R,
    required int node2C,
    required String edgeId,
    required String claimedTrianglesJson,
    required bool extraTurn,
    required int stateVersion,
    required DateTime createdAt,
  }) = _MatchMoveRecordImpl;

  factory MatchMoveRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return MatchMoveRecord(
      id: jsonSerialization['id'] as int?,
      matchId: jsonSerialization['matchId'] as String,
      moveIndex: jsonSerialization['moveIndex'] as int,
      playerId: jsonSerialization['playerId'] as String,
      node1R: jsonSerialization['node1R'] as int,
      node1C: jsonSerialization['node1C'] as int,
      node2R: jsonSerialization['node2R'] as int,
      node2C: jsonSerialization['node2C'] as int,
      edgeId: jsonSerialization['edgeId'] as String,
      claimedTrianglesJson: jsonSerialization['claimedTrianglesJson'] as String,
      extraTurn: _is.BoolJsonExtension.fromJson(jsonSerialization['extraTurn']),
      stateVersion: jsonSerialization['stateVersion'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MatchMoveRecordTable();

  static const db = MatchMoveRecordRepository._();

  @override
  int? id;

  String matchId;

  int moveIndex;

  String playerId;

  int node1R;

  int node1C;

  int node2R;

  int node2C;

  String edgeId;

  String claimedTrianglesJson;

  bool extraTurn;

  int stateVersion;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MatchMoveRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MatchMoveRecord copyWith({
    int? id,
    String? matchId,
    int? moveIndex,
    String? playerId,
    int? node1R,
    int? node1C,
    int? node2R,
    int? node2C,
    String? edgeId,
    String? claimedTrianglesJson,
    bool? extraTurn,
    int? stateVersion,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MatchMoveRecord',
      if (id != null) 'id': id,
      'matchId': matchId,
      'moveIndex': moveIndex,
      'playerId': playerId,
      'node1R': node1R,
      'node1C': node1C,
      'node2R': node2R,
      'node2C': node2C,
      'edgeId': edgeId,
      'claimedTrianglesJson': claimedTrianglesJson,
      'extraTurn': extraTurn,
      'stateVersion': stateVersion,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MatchMoveRecord',
      if (id != null) 'id': id,
      'matchId': matchId,
      'moveIndex': moveIndex,
      'playerId': playerId,
      'node1R': node1R,
      'node1C': node1C,
      'node2R': node2R,
      'node2C': node2C,
      'edgeId': edgeId,
      'claimedTrianglesJson': claimedTrianglesJson,
      'extraTurn': extraTurn,
      'stateVersion': stateVersion,
      'createdAt': createdAt.toJson(),
    };
  }

  static MatchMoveRecordInclude include() {
    return MatchMoveRecordInclude._();
  }

  static MatchMoveRecordIncludeList includeList({
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    MatchMoveRecordInclude? include,
  }) {
    return MatchMoveRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MatchMoveRecordImpl extends MatchMoveRecord {
  _MatchMoveRecordImpl({
    int? id,
    required String matchId,
    required int moveIndex,
    required String playerId,
    required int node1R,
    required int node1C,
    required int node2R,
    required int node2C,
    required String edgeId,
    required String claimedTrianglesJson,
    required bool extraTurn,
    required int stateVersion,
    required DateTime createdAt,
  }) : super._(
         id: id,
         matchId: matchId,
         moveIndex: moveIndex,
         playerId: playerId,
         node1R: node1R,
         node1C: node1C,
         node2R: node2R,
         node2C: node2C,
         edgeId: edgeId,
         claimedTrianglesJson: claimedTrianglesJson,
         extraTurn: extraTurn,
         stateVersion: stateVersion,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MatchMoveRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MatchMoveRecord copyWith({
    Object? id = _Undefined,
    String? matchId,
    int? moveIndex,
    String? playerId,
    int? node1R,
    int? node1C,
    int? node2R,
    int? node2C,
    String? edgeId,
    String? claimedTrianglesJson,
    bool? extraTurn,
    int? stateVersion,
    DateTime? createdAt,
  }) {
    return MatchMoveRecord(
      id: id is int? ? id : this.id,
      matchId: matchId ?? this.matchId,
      moveIndex: moveIndex ?? this.moveIndex,
      playerId: playerId ?? this.playerId,
      node1R: node1R ?? this.node1R,
      node1C: node1C ?? this.node1C,
      node2R: node2R ?? this.node2R,
      node2C: node2C ?? this.node2C,
      edgeId: edgeId ?? this.edgeId,
      claimedTrianglesJson: claimedTrianglesJson ?? this.claimedTrianglesJson,
      extraTurn: extraTurn ?? this.extraTurn,
      stateVersion: stateVersion ?? this.stateVersion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MatchMoveRecordUpdateTable extends _is.UpdateTable<MatchMoveRecordTable> {
  MatchMoveRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> matchId(String value) => _is.ColumnValue(
    table.matchId,
    value,
  );

  _is.ColumnValue<int, int> moveIndex(int value) => _is.ColumnValue(
    table.moveIndex,
    value,
  );

  _is.ColumnValue<String, String> playerId(String value) => _is.ColumnValue(
    table.playerId,
    value,
  );

  _is.ColumnValue<int, int> node1R(int value) => _is.ColumnValue(
    table.node1R,
    value,
  );

  _is.ColumnValue<int, int> node1C(int value) => _is.ColumnValue(
    table.node1C,
    value,
  );

  _is.ColumnValue<int, int> node2R(int value) => _is.ColumnValue(
    table.node2R,
    value,
  );

  _is.ColumnValue<int, int> node2C(int value) => _is.ColumnValue(
    table.node2C,
    value,
  );

  _is.ColumnValue<String, String> edgeId(String value) => _is.ColumnValue(
    table.edgeId,
    value,
  );

  _is.ColumnValue<String, String> claimedTrianglesJson(String value) =>
      _is.ColumnValue(
        table.claimedTrianglesJson,
        value,
      );

  _is.ColumnValue<bool, bool> extraTurn(bool value) => _is.ColumnValue(
    table.extraTurn,
    value,
  );

  _is.ColumnValue<int, int> stateVersion(int value) => _is.ColumnValue(
    table.stateVersion,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MatchMoveRecordTable extends _is.Table<int?> {
  MatchMoveRecordTable({super.tableRelation})
    : super(tableName: 'match_move_record') {
    updateTable = MatchMoveRecordUpdateTable(this);
    matchId = _is.ColumnString(
      'matchId',
      this,
    );
    moveIndex = _is.ColumnInt(
      'moveIndex',
      this,
    );
    playerId = _is.ColumnString(
      'playerId',
      this,
    );
    node1R = _is.ColumnInt(
      'node1R',
      this,
    );
    node1C = _is.ColumnInt(
      'node1C',
      this,
    );
    node2R = _is.ColumnInt(
      'node2R',
      this,
    );
    node2C = _is.ColumnInt(
      'node2C',
      this,
    );
    edgeId = _is.ColumnString(
      'edgeId',
      this,
    );
    claimedTrianglesJson = _is.ColumnString(
      'claimedTrianglesJson',
      this,
    );
    extraTurn = _is.ColumnBool(
      'extraTurn',
      this,
    );
    stateVersion = _is.ColumnInt(
      'stateVersion',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MatchMoveRecordUpdateTable updateTable;

  late final _is.ColumnString matchId;

  late final _is.ColumnInt moveIndex;

  late final _is.ColumnString playerId;

  late final _is.ColumnInt node1R;

  late final _is.ColumnInt node1C;

  late final _is.ColumnInt node2R;

  late final _is.ColumnInt node2C;

  late final _is.ColumnString edgeId;

  late final _is.ColumnString claimedTrianglesJson;

  late final _is.ColumnBool extraTurn;

  late final _is.ColumnInt stateVersion;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    matchId,
    moveIndex,
    playerId,
    node1R,
    node1C,
    node2R,
    node2C,
    edgeId,
    claimedTrianglesJson,
    extraTurn,
    stateVersion,
    createdAt,
  ];
}

class MatchMoveRecordInclude extends _is.IncludeObject {
  MatchMoveRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => MatchMoveRecord.t;
}

class MatchMoveRecordIncludeList extends _is.IncludeList {
  MatchMoveRecordIncludeList._({
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MatchMoveRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MatchMoveRecord.t;
}

class MatchMoveRecordRepository {
  const MatchMoveRecordRepository._();

  /// Returns a list of [MatchMoveRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<MatchMoveRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MatchMoveRecord>(
      where: where?.call(MatchMoveRecord.t),
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MatchMoveRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<MatchMoveRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MatchMoveRecord>(
      where: where?.call(MatchMoveRecord.t),
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MatchMoveRecord] by its [id] or null if no such row exists.
  Future<MatchMoveRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MatchMoveRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MatchMoveRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [MatchMoveRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> insert(
    _is.DatabaseSession session,
    List<MatchMoveRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MatchMoveRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MatchMoveRecord] and returns the inserted row.
  ///
  /// The returned [MatchMoveRecord] will have its `id` field set.
  Future<MatchMoveRecord> insertRow(
    _is.DatabaseSession session,
    MatchMoveRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MatchMoveRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MatchMoveRecord]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [MatchMoveRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> upsert(
    _is.DatabaseSession session,
    List<MatchMoveRecord> rows, {
    required _is.ColumnSelections<MatchMoveRecordTable> conflictColumns,
    _is.ColumnSelections<MatchMoveRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MatchMoveRecord>(
      rows,
      conflictColumns: conflictColumns(MatchMoveRecord.t),
      updateColumns: updateColumns?.call(MatchMoveRecord.t),
      updateWhere: updateWhere?.call(MatchMoveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MatchMoveRecord] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [MatchMoveRecord] will have its `id` field set.
  Future<MatchMoveRecord?> upsertRow(
    _is.DatabaseSession session,
    MatchMoveRecord row, {
    required _is.ColumnSelections<MatchMoveRecordTable> conflictColumns,
    _is.ColumnSelections<MatchMoveRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MatchMoveRecord>(
      row,
      conflictColumns: conflictColumns(MatchMoveRecord.t),
      updateColumns: updateColumns?.call(MatchMoveRecord.t),
      updateWhere: updateWhere?.call(MatchMoveRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [MatchMoveRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> update(
    _is.DatabaseSession session,
    List<MatchMoveRecord> rows, {
    _is.ColumnSelections<MatchMoveRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MatchMoveRecord>(
      rows,
      columns: columns?.call(MatchMoveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MatchMoveRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MatchMoveRecord> updateRow(
    _is.DatabaseSession session,
    MatchMoveRecord row, {
    _is.ColumnSelections<MatchMoveRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MatchMoveRecord>(
      row,
      columns: columns?.call(MatchMoveRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MatchMoveRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MatchMoveRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MatchMoveRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MatchMoveRecord>(
      id,
      columnValues: columnValues(MatchMoveRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MatchMoveRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MatchMoveRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MatchMoveRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MatchMoveRecord>(
      columnValues: columnValues(MatchMoveRecord.t.updateTable),
      where: where(MatchMoveRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MatchMoveRecord]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> delete(
    _is.DatabaseSession session,
    List<MatchMoveRecord> rows, {
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MatchMoveRecord>(
      rows,
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MatchMoveRecord].
  Future<MatchMoveRecord> deleteRow(
    _is.DatabaseSession session,
    MatchMoveRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MatchMoveRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MatchMoveRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MatchMoveRecordTable> where,
    _is.OrderByBuilder<MatchMoveRecordTable>? orderBy,
    _is.OrderByListBuilder<MatchMoveRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MatchMoveRecord>(
      where: where(MatchMoveRecord.t),
      orderBy: orderBy?.call(MatchMoveRecord.t),
      orderByList: orderByList?.call(MatchMoveRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MatchMoveRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MatchMoveRecord>(
      where: where?.call(MatchMoveRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MatchMoveRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MatchMoveRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MatchMoveRecord>(
      where: where(MatchMoveRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
