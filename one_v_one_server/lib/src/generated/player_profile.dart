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

abstract class PlayerProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PlayerProfile._({
    this.id,
    required this.playerId,
    required this.displayName,
    required this.avatarSeed,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.trianglesCaptured,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory PlayerProfile({
    int? id,
    required String playerId,
    required String displayName,
    required String avatarSeed,
    required int totalMatches,
    required int wins,
    required int losses,
    required int draws,
    required int trianglesCaptured,
    required DateTime createdAt,
    required DateTime lastActiveAt,
  }) = _PlayerProfileImpl;

  factory PlayerProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlayerProfile(
      id: jsonSerialization['id'] as int?,
      playerId: jsonSerialization['playerId'] as String,
      displayName: jsonSerialization['displayName'] as String,
      avatarSeed: jsonSerialization['avatarSeed'] as String,
      totalMatches: jsonSerialization['totalMatches'] as int,
      wins: jsonSerialization['wins'] as int,
      losses: jsonSerialization['losses'] as int,
      draws: jsonSerialization['draws'] as int,
      trianglesCaptured: jsonSerialization['trianglesCaptured'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastActiveAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActiveAt'],
      ),
    );
  }

  static final t = PlayerProfileTable();

  static const db = PlayerProfileRepository._();

  @override
  int? id;

  String playerId;

  String displayName;

  String avatarSeed;

  int totalMatches;

  int wins;

  int losses;

  int draws;

  int trianglesCaptured;

  DateTime createdAt;

  DateTime lastActiveAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PlayerProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlayerProfile copyWith({
    int? id,
    String? playerId,
    String? displayName,
    String? avatarSeed,
    int? totalMatches,
    int? wins,
    int? losses,
    int? draws,
    int? trianglesCaptured,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlayerProfile',
      if (id != null) 'id': id,
      'playerId': playerId,
      'displayName': displayName,
      'avatarSeed': avatarSeed,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'trianglesCaptured': trianglesCaptured,
      'createdAt': createdAt.toJson(),
      'lastActiveAt': lastActiveAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlayerProfile',
      if (id != null) 'id': id,
      'playerId': playerId,
      'displayName': displayName,
      'avatarSeed': avatarSeed,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'trianglesCaptured': trianglesCaptured,
      'createdAt': createdAt.toJson(),
      'lastActiveAt': lastActiveAt.toJson(),
    };
  }

  static PlayerProfileInclude include() {
    return PlayerProfileInclude._();
  }

  static PlayerProfileIncludeList includeList({
    _is.WhereExpressionBuilder<PlayerProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    PlayerProfileInclude? include,
  }) {
    return PlayerProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerProfileImpl extends PlayerProfile {
  _PlayerProfileImpl({
    int? id,
    required String playerId,
    required String displayName,
    required String avatarSeed,
    required int totalMatches,
    required int wins,
    required int losses,
    required int draws,
    required int trianglesCaptured,
    required DateTime createdAt,
    required DateTime lastActiveAt,
  }) : super._(
         id: id,
         playerId: playerId,
         displayName: displayName,
         avatarSeed: avatarSeed,
         totalMatches: totalMatches,
         wins: wins,
         losses: losses,
         draws: draws,
         trianglesCaptured: trianglesCaptured,
         createdAt: createdAt,
         lastActiveAt: lastActiveAt,
       );

  /// Returns a shallow copy of this [PlayerProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlayerProfile copyWith({
    Object? id = _Undefined,
    String? playerId,
    String? displayName,
    String? avatarSeed,
    int? totalMatches,
    int? wins,
    int? losses,
    int? draws,
    int? trianglesCaptured,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return PlayerProfile(
      id: id is int? ? id : this.id,
      playerId: playerId ?? this.playerId,
      displayName: displayName ?? this.displayName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      trianglesCaptured: trianglesCaptured ?? this.trianglesCaptured,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class PlayerProfileUpdateTable extends _is.UpdateTable<PlayerProfileTable> {
  PlayerProfileUpdateTable(super.table);

  _is.ColumnValue<String, String> playerId(String value) => _is.ColumnValue(
    table.playerId,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<String, String> avatarSeed(String value) => _is.ColumnValue(
    table.avatarSeed,
    value,
  );

  _is.ColumnValue<int, int> totalMatches(int value) => _is.ColumnValue(
    table.totalMatches,
    value,
  );

  _is.ColumnValue<int, int> wins(int value) => _is.ColumnValue(
    table.wins,
    value,
  );

  _is.ColumnValue<int, int> losses(int value) => _is.ColumnValue(
    table.losses,
    value,
  );

  _is.ColumnValue<int, int> draws(int value) => _is.ColumnValue(
    table.draws,
    value,
  );

  _is.ColumnValue<int, int> trianglesCaptured(int value) => _is.ColumnValue(
    table.trianglesCaptured,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastActiveAt(DateTime value) =>
      _is.ColumnValue(
        table.lastActiveAt,
        value,
      );
}

class PlayerProfileTable extends _is.Table<int?> {
  PlayerProfileTable({super.tableRelation})
    : super(tableName: 'player_profile') {
    updateTable = PlayerProfileUpdateTable(this);
    playerId = _is.ColumnString(
      'playerId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    avatarSeed = _is.ColumnString(
      'avatarSeed',
      this,
    );
    totalMatches = _is.ColumnInt(
      'totalMatches',
      this,
    );
    wins = _is.ColumnInt(
      'wins',
      this,
    );
    losses = _is.ColumnInt(
      'losses',
      this,
    );
    draws = _is.ColumnInt(
      'draws',
      this,
    );
    trianglesCaptured = _is.ColumnInt(
      'trianglesCaptured',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    lastActiveAt = _is.ColumnDateTime(
      'lastActiveAt',
      this,
    );
  }

  late final PlayerProfileUpdateTable updateTable;

  late final _is.ColumnString playerId;

  late final _is.ColumnString displayName;

  late final _is.ColumnString avatarSeed;

  late final _is.ColumnInt totalMatches;

  late final _is.ColumnInt wins;

  late final _is.ColumnInt losses;

  late final _is.ColumnInt draws;

  late final _is.ColumnInt trianglesCaptured;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime lastActiveAt;

  @override
  List<_is.Column> get columns => [
    id,
    playerId,
    displayName,
    avatarSeed,
    totalMatches,
    wins,
    losses,
    draws,
    trianglesCaptured,
    createdAt,
    lastActiveAt,
  ];
}

class PlayerProfileInclude extends _is.IncludeObject {
  PlayerProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PlayerProfile.t;
}

class PlayerProfileIncludeList extends _is.IncludeList {
  PlayerProfileIncludeList._({
    _is.WhereExpressionBuilder<PlayerProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlayerProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PlayerProfile.t;
}

class PlayerProfileRepository {
  const PlayerProfileRepository._();

  /// Returns a list of [PlayerProfile]s matching the given query parameters.
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
  Future<List<PlayerProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlayerProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlayerProfile>(
      where: where?.call(PlayerProfile.t),
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PlayerProfile] matching the given query parameters.
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
  Future<PlayerProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlayerProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlayerProfile>(
      where: where?.call(PlayerProfile.t),
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlayerProfile] by its [id] or null if no such row exists.
  Future<PlayerProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlayerProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlayerProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [PlayerProfile]s will have their `id` fields set.
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
  Future<List<PlayerProfile>> insert(
    _is.DatabaseSession session,
    List<PlayerProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlayerProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlayerProfile] and returns the inserted row.
  ///
  /// The returned [PlayerProfile] will have its `id` field set.
  Future<PlayerProfile> insertRow(
    _is.DatabaseSession session,
    PlayerProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlayerProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PlayerProfile]s in the list and returns the resulting rows.
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
  /// The returned [PlayerProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlayerProfile>> upsert(
    _is.DatabaseSession session,
    List<PlayerProfile> rows, {
    required _is.ColumnSelections<PlayerProfileTable> conflictColumns,
    _is.ColumnSelections<PlayerProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<PlayerProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlayerProfile>(
      rows,
      conflictColumns: conflictColumns(PlayerProfile.t),
      updateColumns: updateColumns?.call(PlayerProfile.t),
      updateWhere: updateWhere?.call(PlayerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlayerProfile] and returns the resulting row.
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
  /// The returned [PlayerProfile] will have its `id` field set.
  Future<PlayerProfile?> upsertRow(
    _is.DatabaseSession session,
    PlayerProfile row, {
    required _is.ColumnSelections<PlayerProfileTable> conflictColumns,
    _is.ColumnSelections<PlayerProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<PlayerProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlayerProfile>(
      row,
      conflictColumns: conflictColumns(PlayerProfile.t),
      updateColumns: updateColumns?.call(PlayerProfile.t),
      updateWhere: updateWhere?.call(PlayerProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlayerProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlayerProfile>> update(
    _is.DatabaseSession session,
    List<PlayerProfile> rows, {
    _is.ColumnSelections<PlayerProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlayerProfile>(
      rows,
      columns: columns?.call(PlayerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlayerProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlayerProfile> updateRow(
    _is.DatabaseSession session,
    PlayerProfile row, {
    _is.ColumnSelections<PlayerProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlayerProfile>(
      row,
      columns: columns?.call(PlayerProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlayerProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlayerProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PlayerProfileUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlayerProfile>(
      id,
      columnValues: columnValues(PlayerProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlayerProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlayerProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlayerProfileUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PlayerProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlayerProfile>(
      columnValues: columnValues(PlayerProfile.t.updateTable),
      where: where(PlayerProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlayerProfile]s in the list and returns the deleted rows.
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
  Future<List<PlayerProfile>> delete(
    _is.DatabaseSession session,
    List<PlayerProfile> rows, {
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlayerProfile>(
      rows,
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlayerProfile].
  Future<PlayerProfile> deleteRow(
    _is.DatabaseSession session,
    PlayerProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlayerProfile>(
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
  Future<List<PlayerProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlayerProfileTable> where,
    _is.OrderByBuilder<PlayerProfileTable>? orderBy,
    _is.OrderByListBuilder<PlayerProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlayerProfile>(
      where: where(PlayerProfile.t),
      orderBy: orderBy?.call(PlayerProfile.t),
      orderByList: orderByList?.call(PlayerProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlayerProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlayerProfile>(
      where: where?.call(PlayerProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlayerProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlayerProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlayerProfile>(
      where: where(PlayerProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
