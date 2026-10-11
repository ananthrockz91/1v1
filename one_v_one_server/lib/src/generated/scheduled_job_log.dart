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

abstract class ScheduledJobLog
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ScheduledJobLog._({
    this.id,
    required this.jobName,
    required this.executedAt,
    required this.targetDate,
    required this.staleLobbiesCleaned,
    required this.abandonedMatchesProcessed,
    required this.leaderboardsAggregated,
    required this.success,
    this.errorDetails,
  });

  factory ScheduledJobLog({
    int? id,
    required String jobName,
    required DateTime executedAt,
    required String targetDate,
    required int staleLobbiesCleaned,
    required int abandonedMatchesProcessed,
    required int leaderboardsAggregated,
    required bool success,
    String? errorDetails,
  }) = _ScheduledJobLogImpl;

  factory ScheduledJobLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return ScheduledJobLog(
      id: jsonSerialization['id'] as int?,
      jobName: jsonSerialization['jobName'] as String,
      executedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['executedAt'],
      ),
      targetDate: jsonSerialization['targetDate'] as String,
      staleLobbiesCleaned: jsonSerialization['staleLobbiesCleaned'] as int,
      abandonedMatchesProcessed:
          jsonSerialization['abandonedMatchesProcessed'] as int,
      leaderboardsAggregated:
          jsonSerialization['leaderboardsAggregated'] as int,
      success: _is.BoolJsonExtension.fromJson(jsonSerialization['success']),
      errorDetails: jsonSerialization['errorDetails'] as String?,
    );
  }

  static final t = ScheduledJobLogTable();

  static const db = ScheduledJobLogRepository._();

  @override
  int? id;

  String jobName;

  DateTime executedAt;

  String targetDate;

  int staleLobbiesCleaned;

  int abandonedMatchesProcessed;

  int leaderboardsAggregated;

  bool success;

  String? errorDetails;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ScheduledJobLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ScheduledJobLog copyWith({
    int? id,
    String? jobName,
    DateTime? executedAt,
    String? targetDate,
    int? staleLobbiesCleaned,
    int? abandonedMatchesProcessed,
    int? leaderboardsAggregated,
    bool? success,
    String? errorDetails,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ScheduledJobLog',
      if (id != null) 'id': id,
      'jobName': jobName,
      'executedAt': executedAt.toJson(),
      'targetDate': targetDate,
      'staleLobbiesCleaned': staleLobbiesCleaned,
      'abandonedMatchesProcessed': abandonedMatchesProcessed,
      'leaderboardsAggregated': leaderboardsAggregated,
      'success': success,
      if (errorDetails != null) 'errorDetails': errorDetails,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ScheduledJobLog',
      if (id != null) 'id': id,
      'jobName': jobName,
      'executedAt': executedAt.toJson(),
      'targetDate': targetDate,
      'staleLobbiesCleaned': staleLobbiesCleaned,
      'abandonedMatchesProcessed': abandonedMatchesProcessed,
      'leaderboardsAggregated': leaderboardsAggregated,
      'success': success,
      if (errorDetails != null) 'errorDetails': errorDetails,
    };
  }

  static ScheduledJobLogInclude include() {
    return ScheduledJobLogInclude._();
  }

  static ScheduledJobLogIncludeList includeList({
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    ScheduledJobLogInclude? include,
  }) {
    return ScheduledJobLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ScheduledJobLogImpl extends ScheduledJobLog {
  _ScheduledJobLogImpl({
    int? id,
    required String jobName,
    required DateTime executedAt,
    required String targetDate,
    required int staleLobbiesCleaned,
    required int abandonedMatchesProcessed,
    required int leaderboardsAggregated,
    required bool success,
    String? errorDetails,
  }) : super._(
         id: id,
         jobName: jobName,
         executedAt: executedAt,
         targetDate: targetDate,
         staleLobbiesCleaned: staleLobbiesCleaned,
         abandonedMatchesProcessed: abandonedMatchesProcessed,
         leaderboardsAggregated: leaderboardsAggregated,
         success: success,
         errorDetails: errorDetails,
       );

  /// Returns a shallow copy of this [ScheduledJobLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ScheduledJobLog copyWith({
    Object? id = _Undefined,
    String? jobName,
    DateTime? executedAt,
    String? targetDate,
    int? staleLobbiesCleaned,
    int? abandonedMatchesProcessed,
    int? leaderboardsAggregated,
    bool? success,
    Object? errorDetails = _Undefined,
  }) {
    return ScheduledJobLog(
      id: id is int? ? id : this.id,
      jobName: jobName ?? this.jobName,
      executedAt: executedAt ?? this.executedAt,
      targetDate: targetDate ?? this.targetDate,
      staleLobbiesCleaned: staleLobbiesCleaned ?? this.staleLobbiesCleaned,
      abandonedMatchesProcessed:
          abandonedMatchesProcessed ?? this.abandonedMatchesProcessed,
      leaderboardsAggregated:
          leaderboardsAggregated ?? this.leaderboardsAggregated,
      success: success ?? this.success,
      errorDetails: errorDetails is String? ? errorDetails : this.errorDetails,
    );
  }
}

class ScheduledJobLogUpdateTable extends _is.UpdateTable<ScheduledJobLogTable> {
  ScheduledJobLogUpdateTable(super.table);

  _is.ColumnValue<String, String> jobName(String value) => _is.ColumnValue(
    table.jobName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> executedAt(DateTime value) =>
      _is.ColumnValue(
        table.executedAt,
        value,
      );

  _is.ColumnValue<String, String> targetDate(String value) => _is.ColumnValue(
    table.targetDate,
    value,
  );

  _is.ColumnValue<int, int> staleLobbiesCleaned(int value) => _is.ColumnValue(
    table.staleLobbiesCleaned,
    value,
  );

  _is.ColumnValue<int, int> abandonedMatchesProcessed(int value) =>
      _is.ColumnValue(
        table.abandonedMatchesProcessed,
        value,
      );

  _is.ColumnValue<int, int> leaderboardsAggregated(int value) =>
      _is.ColumnValue(
        table.leaderboardsAggregated,
        value,
      );

  _is.ColumnValue<bool, bool> success(bool value) => _is.ColumnValue(
    table.success,
    value,
  );

  _is.ColumnValue<String, String> errorDetails(String? value) =>
      _is.ColumnValue(
        table.errorDetails,
        value,
      );
}

class ScheduledJobLogTable extends _is.Table<int?> {
  ScheduledJobLogTable({super.tableRelation})
    : super(tableName: 'scheduled_job_log') {
    updateTable = ScheduledJobLogUpdateTable(this);
    jobName = _is.ColumnString(
      'jobName',
      this,
    );
    executedAt = _is.ColumnDateTime(
      'executedAt',
      this,
    );
    targetDate = _is.ColumnString(
      'targetDate',
      this,
    );
    staleLobbiesCleaned = _is.ColumnInt(
      'staleLobbiesCleaned',
      this,
    );
    abandonedMatchesProcessed = _is.ColumnInt(
      'abandonedMatchesProcessed',
      this,
    );
    leaderboardsAggregated = _is.ColumnInt(
      'leaderboardsAggregated',
      this,
    );
    success = _is.ColumnBool(
      'success',
      this,
    );
    errorDetails = _is.ColumnString(
      'errorDetails',
      this,
    );
  }

  late final ScheduledJobLogUpdateTable updateTable;

  late final _is.ColumnString jobName;

  late final _is.ColumnDateTime executedAt;

  late final _is.ColumnString targetDate;

  late final _is.ColumnInt staleLobbiesCleaned;

  late final _is.ColumnInt abandonedMatchesProcessed;

  late final _is.ColumnInt leaderboardsAggregated;

  late final _is.ColumnBool success;

  late final _is.ColumnString errorDetails;

  @override
  List<_is.Column> get columns => [
    id,
    jobName,
    executedAt,
    targetDate,
    staleLobbiesCleaned,
    abandonedMatchesProcessed,
    leaderboardsAggregated,
    success,
    errorDetails,
  ];
}

class ScheduledJobLogInclude extends _is.IncludeObject {
  ScheduledJobLogInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ScheduledJobLog.t;
}

class ScheduledJobLogIncludeList extends _is.IncludeList {
  ScheduledJobLogIncludeList._({
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ScheduledJobLog.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ScheduledJobLog.t;
}

class ScheduledJobLogRepository {
  const ScheduledJobLogRepository._();

  /// Returns a list of [ScheduledJobLog]s matching the given query parameters.
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
  Future<List<ScheduledJobLog>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ScheduledJobLog>(
      where: where?.call(ScheduledJobLog.t),
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ScheduledJobLog] matching the given query parameters.
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
  Future<ScheduledJobLog?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? where,
    int? offset,
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ScheduledJobLog>(
      where: where?.call(ScheduledJobLog.t),
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ScheduledJobLog] by its [id] or null if no such row exists.
  Future<ScheduledJobLog?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ScheduledJobLog>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ScheduledJobLog]s in the list and returns the inserted rows.
  ///
  /// The returned [ScheduledJobLog]s will have their `id` fields set.
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
  Future<List<ScheduledJobLog>> insert(
    _is.DatabaseSession session,
    List<ScheduledJobLog> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ScheduledJobLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ScheduledJobLog] and returns the inserted row.
  ///
  /// The returned [ScheduledJobLog] will have its `id` field set.
  Future<ScheduledJobLog> insertRow(
    _is.DatabaseSession session,
    ScheduledJobLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ScheduledJobLog>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ScheduledJobLog]s in the list and returns the resulting rows.
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
  /// The returned [ScheduledJobLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ScheduledJobLog>> upsert(
    _is.DatabaseSession session,
    List<ScheduledJobLog> rows, {
    required _is.ColumnSelections<ScheduledJobLogTable> conflictColumns,
    _is.ColumnSelections<ScheduledJobLogTable>? updateColumns,
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ScheduledJobLog>(
      rows,
      conflictColumns: conflictColumns(ScheduledJobLog.t),
      updateColumns: updateColumns?.call(ScheduledJobLog.t),
      updateWhere: updateWhere?.call(ScheduledJobLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ScheduledJobLog] and returns the resulting row.
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
  /// The returned [ScheduledJobLog] will have its `id` field set.
  Future<ScheduledJobLog?> upsertRow(
    _is.DatabaseSession session,
    ScheduledJobLog row, {
    required _is.ColumnSelections<ScheduledJobLogTable> conflictColumns,
    _is.ColumnSelections<ScheduledJobLogTable>? updateColumns,
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ScheduledJobLog>(
      row,
      conflictColumns: conflictColumns(ScheduledJobLog.t),
      updateColumns: updateColumns?.call(ScheduledJobLog.t),
      updateWhere: updateWhere?.call(ScheduledJobLog.t),
      transaction: transaction,
    );
  }

  /// Updates all [ScheduledJobLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ScheduledJobLog>> update(
    _is.DatabaseSession session,
    List<ScheduledJobLog> rows, {
    _is.ColumnSelections<ScheduledJobLogTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ScheduledJobLog>(
      rows,
      columns: columns?.call(ScheduledJobLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ScheduledJobLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ScheduledJobLog> updateRow(
    _is.DatabaseSession session,
    ScheduledJobLog row, {
    _is.ColumnSelections<ScheduledJobLogTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ScheduledJobLog>(
      row,
      columns: columns?.call(ScheduledJobLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ScheduledJobLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ScheduledJobLog?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ScheduledJobLogUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ScheduledJobLog>(
      id,
      columnValues: columnValues(ScheduledJobLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ScheduledJobLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ScheduledJobLog>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ScheduledJobLogUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ScheduledJobLogTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ScheduledJobLog>(
      columnValues: columnValues(ScheduledJobLog.t.updateTable),
      where: where(ScheduledJobLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ScheduledJobLog]s in the list and returns the deleted rows.
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
  Future<List<ScheduledJobLog>> delete(
    _is.DatabaseSession session,
    List<ScheduledJobLog> rows, {
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ScheduledJobLog>(
      rows,
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ScheduledJobLog].
  Future<ScheduledJobLog> deleteRow(
    _is.DatabaseSession session,
    ScheduledJobLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ScheduledJobLog>(
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
  Future<List<ScheduledJobLog>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ScheduledJobLogTable> where,
    _is.OrderByBuilder<ScheduledJobLogTable>? orderBy,
    _is.OrderByListBuilder<ScheduledJobLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ScheduledJobLog>(
      where: where(ScheduledJobLog.t),
      orderBy: orderBy?.call(ScheduledJobLog.t),
      orderByList: orderByList?.call(ScheduledJobLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ScheduledJobLogTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ScheduledJobLog>(
      where: where?.call(ScheduledJobLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ScheduledJobLog] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ScheduledJobLogTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ScheduledJobLog>(
      where: where(ScheduledJobLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
