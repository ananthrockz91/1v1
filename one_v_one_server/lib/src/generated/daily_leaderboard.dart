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

abstract class DailyLeaderboard
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DailyLeaderboard._({
    this.id,
    required this.dateString,
    required this.playerId,
    required this.displayName,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.trianglesCaptured,
    required this.rank,
    required this.winRate,
    required this.updatedAt,
  });

  factory DailyLeaderboard({
    int? id,
    required String dateString,
    required String playerId,
    required String displayName,
    required int wins,
    required int losses,
    required int draws,
    required int trianglesCaptured,
    required int rank,
    required double winRate,
    required DateTime updatedAt,
  }) = _DailyLeaderboardImpl;

  factory DailyLeaderboard.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyLeaderboard(
      id: jsonSerialization['id'] as int?,
      dateString: jsonSerialization['dateString'] as String,
      playerId: jsonSerialization['playerId'] as String,
      displayName: jsonSerialization['displayName'] as String,
      wins: jsonSerialization['wins'] as int,
      losses: jsonSerialization['losses'] as int,
      draws: jsonSerialization['draws'] as int,
      trianglesCaptured: jsonSerialization['trianglesCaptured'] as int,
      rank: jsonSerialization['rank'] as int,
      winRate: (jsonSerialization['winRate'] as num).toDouble(),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = DailyLeaderboardTable();

  static const db = DailyLeaderboardRepository._();

  @override
  int? id;

  String dateString;

  String playerId;

  String displayName;

  int wins;

  int losses;

  int draws;

  int trianglesCaptured;

  int rank;

  double winRate;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DailyLeaderboard]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DailyLeaderboard copyWith({
    int? id,
    String? dateString,
    String? playerId,
    String? displayName,
    int? wins,
    int? losses,
    int? draws,
    int? trianglesCaptured,
    int? rank,
    double? winRate,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyLeaderboard',
      if (id != null) 'id': id,
      'dateString': dateString,
      'playerId': playerId,
      'displayName': displayName,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'trianglesCaptured': trianglesCaptured,
      'rank': rank,
      'winRate': winRate,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyLeaderboard',
      if (id != null) 'id': id,
      'dateString': dateString,
      'playerId': playerId,
      'displayName': displayName,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'trianglesCaptured': trianglesCaptured,
      'rank': rank,
      'winRate': winRate,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static DailyLeaderboardInclude include() {
    return DailyLeaderboardInclude._();
  }

  static DailyLeaderboardIncludeList includeList({
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    DailyLeaderboardInclude? include,
  }) {
    return DailyLeaderboardIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyLeaderboardImpl extends DailyLeaderboard {
  _DailyLeaderboardImpl({
    int? id,
    required String dateString,
    required String playerId,
    required String displayName,
    required int wins,
    required int losses,
    required int draws,
    required int trianglesCaptured,
    required int rank,
    required double winRate,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         dateString: dateString,
         playerId: playerId,
         displayName: displayName,
         wins: wins,
         losses: losses,
         draws: draws,
         trianglesCaptured: trianglesCaptured,
         rank: rank,
         winRate: winRate,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [DailyLeaderboard]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DailyLeaderboard copyWith({
    Object? id = _Undefined,
    String? dateString,
    String? playerId,
    String? displayName,
    int? wins,
    int? losses,
    int? draws,
    int? trianglesCaptured,
    int? rank,
    double? winRate,
    DateTime? updatedAt,
  }) {
    return DailyLeaderboard(
      id: id is int? ? id : this.id,
      dateString: dateString ?? this.dateString,
      playerId: playerId ?? this.playerId,
      displayName: displayName ?? this.displayName,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      trianglesCaptured: trianglesCaptured ?? this.trianglesCaptured,
      rank: rank ?? this.rank,
      winRate: winRate ?? this.winRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DailyLeaderboardUpdateTable
    extends _is.UpdateTable<DailyLeaderboardTable> {
  DailyLeaderboardUpdateTable(super.table);

  _is.ColumnValue<String, String> dateString(String value) => _is.ColumnValue(
    table.dateString,
    value,
  );

  _is.ColumnValue<String, String> playerId(String value) => _is.ColumnValue(
    table.playerId,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
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

  _is.ColumnValue<int, int> rank(int value) => _is.ColumnValue(
    table.rank,
    value,
  );

  _is.ColumnValue<double, double> winRate(double value) => _is.ColumnValue(
    table.winRate,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class DailyLeaderboardTable extends _is.Table<int?> {
  DailyLeaderboardTable({super.tableRelation})
    : super(tableName: 'daily_leaderboard') {
    updateTable = DailyLeaderboardUpdateTable(this);
    dateString = _is.ColumnString(
      'dateString',
      this,
    );
    playerId = _is.ColumnString(
      'playerId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
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
    rank = _is.ColumnInt(
      'rank',
      this,
    );
    winRate = _is.ColumnDouble(
      'winRate',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final DailyLeaderboardUpdateTable updateTable;

  late final _is.ColumnString dateString;

  late final _is.ColumnString playerId;

  late final _is.ColumnString displayName;

  late final _is.ColumnInt wins;

  late final _is.ColumnInt losses;

  late final _is.ColumnInt draws;

  late final _is.ColumnInt trianglesCaptured;

  late final _is.ColumnInt rank;

  late final _is.ColumnDouble winRate;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    dateString,
    playerId,
    displayName,
    wins,
    losses,
    draws,
    trianglesCaptured,
    rank,
    winRate,
    updatedAt,
  ];
}

class DailyLeaderboardInclude extends _is.IncludeObject {
  DailyLeaderboardInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DailyLeaderboard.t;
}

class DailyLeaderboardIncludeList extends _is.IncludeList {
  DailyLeaderboardIncludeList._({
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyLeaderboard.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DailyLeaderboard.t;
}

class DailyLeaderboardRepository {
  const DailyLeaderboardRepository._();

  /// Returns a list of [DailyLeaderboard]s matching the given query parameters.
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
  Future<List<DailyLeaderboard>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DailyLeaderboard>(
      where: where?.call(DailyLeaderboard.t),
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DailyLeaderboard] matching the given query parameters.
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
  Future<DailyLeaderboard?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? where,
    int? offset,
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DailyLeaderboard>(
      where: where?.call(DailyLeaderboard.t),
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DailyLeaderboard] by its [id] or null if no such row exists.
  Future<DailyLeaderboard?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DailyLeaderboard>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DailyLeaderboard]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyLeaderboard]s will have their `id` fields set.
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
  Future<List<DailyLeaderboard>> insert(
    _is.DatabaseSession session,
    List<DailyLeaderboard> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DailyLeaderboard>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DailyLeaderboard] and returns the inserted row.
  ///
  /// The returned [DailyLeaderboard] will have its `id` field set.
  Future<DailyLeaderboard> insertRow(
    _is.DatabaseSession session,
    DailyLeaderboard row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyLeaderboard>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DailyLeaderboard]s in the list and returns the resulting rows.
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
  /// The returned [DailyLeaderboard]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyLeaderboard>> upsert(
    _is.DatabaseSession session,
    List<DailyLeaderboard> rows, {
    required _is.ColumnSelections<DailyLeaderboardTable> conflictColumns,
    _is.ColumnSelections<DailyLeaderboardTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DailyLeaderboard>(
      rows,
      conflictColumns: conflictColumns(DailyLeaderboard.t),
      updateColumns: updateColumns?.call(DailyLeaderboard.t),
      updateWhere: updateWhere?.call(DailyLeaderboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DailyLeaderboard] and returns the resulting row.
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
  /// The returned [DailyLeaderboard] will have its `id` field set.
  Future<DailyLeaderboard?> upsertRow(
    _is.DatabaseSession session,
    DailyLeaderboard row, {
    required _is.ColumnSelections<DailyLeaderboardTable> conflictColumns,
    _is.ColumnSelections<DailyLeaderboardTable>? updateColumns,
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DailyLeaderboard>(
      row,
      conflictColumns: conflictColumns(DailyLeaderboard.t),
      updateColumns: updateColumns?.call(DailyLeaderboard.t),
      updateWhere: updateWhere?.call(DailyLeaderboard.t),
      transaction: transaction,
    );
  }

  /// Updates all [DailyLeaderboard]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyLeaderboard>> update(
    _is.DatabaseSession session,
    List<DailyLeaderboard> rows, {
    _is.ColumnSelections<DailyLeaderboardTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DailyLeaderboard>(
      rows,
      columns: columns?.call(DailyLeaderboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DailyLeaderboard]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyLeaderboard> updateRow(
    _is.DatabaseSession session,
    DailyLeaderboard row, {
    _is.ColumnSelections<DailyLeaderboardTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyLeaderboard>(
      row,
      columns: columns?.call(DailyLeaderboard.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyLeaderboard] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyLeaderboard?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DailyLeaderboardUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyLeaderboard>(
      id,
      columnValues: columnValues(DailyLeaderboard.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyLeaderboard]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DailyLeaderboard>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DailyLeaderboardUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DailyLeaderboardTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DailyLeaderboard>(
      columnValues: columnValues(DailyLeaderboard.t.updateTable),
      where: where(DailyLeaderboard.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DailyLeaderboard]s in the list and returns the deleted rows.
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
  Future<List<DailyLeaderboard>> delete(
    _is.DatabaseSession session,
    List<DailyLeaderboard> rows, {
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DailyLeaderboard>(
      rows,
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DailyLeaderboard].
  Future<DailyLeaderboard> deleteRow(
    _is.DatabaseSession session,
    DailyLeaderboard row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyLeaderboard>(
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
  Future<List<DailyLeaderboard>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyLeaderboardTable> where,
    _is.OrderByBuilder<DailyLeaderboardTable>? orderBy,
    _is.OrderByListBuilder<DailyLeaderboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DailyLeaderboard>(
      where: where(DailyLeaderboard.t),
      orderBy: orderBy?.call(DailyLeaderboard.t),
      orderByList: orderByList?.call(DailyLeaderboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DailyLeaderboardTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DailyLeaderboard>(
      where: where?.call(DailyLeaderboard.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DailyLeaderboard] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DailyLeaderboardTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DailyLeaderboard>(
      where: where(DailyLeaderboard.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
