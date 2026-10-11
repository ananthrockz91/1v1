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

abstract class GameMatch
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GameMatch._({
    this.id,
    required this.matchId,
    required this.gameType,
    required this.rulesetVersion,
    required this.boardSize,
    this.roomCode,
    required this.isPublic,
    required this.status,
    required this.player1Id,
    this.player2Id,
    required this.activePlayerId,
    required this.player1Score,
    required this.player2Score,
    required this.stateVersion,
    this.winnerId,
    required this.isDraw,
    required this.stateJson,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory GameMatch({
    int? id,
    required String matchId,
    required String gameType,
    required String rulesetVersion,
    required int boardSize,
    String? roomCode,
    required bool isPublic,
    required String status,
    required String player1Id,
    String? player2Id,
    required String activePlayerId,
    required int player1Score,
    required int player2Score,
    required int stateVersion,
    String? winnerId,
    required bool isDraw,
    required String stateJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) = _GameMatchImpl;

  factory GameMatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return GameMatch(
      id: jsonSerialization['id'] as int?,
      matchId: jsonSerialization['matchId'] as String,
      gameType: jsonSerialization['gameType'] as String,
      rulesetVersion: jsonSerialization['rulesetVersion'] as String,
      boardSize: jsonSerialization['boardSize'] as int,
      roomCode: jsonSerialization['roomCode'] as String?,
      isPublic: _is.BoolJsonExtension.fromJson(jsonSerialization['isPublic']),
      status: jsonSerialization['status'] as String,
      player1Id: jsonSerialization['player1Id'] as String,
      player2Id: jsonSerialization['player2Id'] as String?,
      activePlayerId: jsonSerialization['activePlayerId'] as String,
      player1Score: jsonSerialization['player1Score'] as int,
      player2Score: jsonSerialization['player2Score'] as int,
      stateVersion: jsonSerialization['stateVersion'] as int,
      winnerId: jsonSerialization['winnerId'] as String?,
      isDraw: _is.BoolJsonExtension.fromJson(jsonSerialization['isDraw']),
      stateJson: jsonSerialization['stateJson'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  static final t = GameMatchTable();

  static const db = GameMatchRepository._();

  @override
  int? id;

  String matchId;

  String gameType;

  String rulesetVersion;

  int boardSize;

  String? roomCode;

  bool isPublic;

  String status;

  String player1Id;

  String? player2Id;

  String activePlayerId;

  int player1Score;

  int player2Score;

  int stateVersion;

  String? winnerId;

  bool isDraw;

  String stateJson;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? completedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GameMatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GameMatch copyWith({
    int? id,
    String? matchId,
    String? gameType,
    String? rulesetVersion,
    int? boardSize,
    String? roomCode,
    bool? isPublic,
    String? status,
    String? player1Id,
    String? player2Id,
    String? activePlayerId,
    int? player1Score,
    int? player2Score,
    int? stateVersion,
    String? winnerId,
    bool? isDraw,
    String? stateJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GameMatch',
      if (id != null) 'id': id,
      'matchId': matchId,
      'gameType': gameType,
      'rulesetVersion': rulesetVersion,
      'boardSize': boardSize,
      if (roomCode != null) 'roomCode': roomCode,
      'isPublic': isPublic,
      'status': status,
      'player1Id': player1Id,
      if (player2Id != null) 'player2Id': player2Id,
      'activePlayerId': activePlayerId,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'stateVersion': stateVersion,
      if (winnerId != null) 'winnerId': winnerId,
      'isDraw': isDraw,
      'stateJson': stateJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GameMatch',
      if (id != null) 'id': id,
      'matchId': matchId,
      'gameType': gameType,
      'rulesetVersion': rulesetVersion,
      'boardSize': boardSize,
      if (roomCode != null) 'roomCode': roomCode,
      'isPublic': isPublic,
      'status': status,
      'player1Id': player1Id,
      if (player2Id != null) 'player2Id': player2Id,
      'activePlayerId': activePlayerId,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'stateVersion': stateVersion,
      if (winnerId != null) 'winnerId': winnerId,
      'isDraw': isDraw,
      'stateJson': stateJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  static GameMatchInclude include() {
    return GameMatchInclude._();
  }

  static GameMatchIncludeList includeList({
    _is.WhereExpressionBuilder<GameMatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    GameMatchInclude? include,
  }) {
    return GameMatchIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GameMatchImpl extends GameMatch {
  _GameMatchImpl({
    int? id,
    required String matchId,
    required String gameType,
    required String rulesetVersion,
    required int boardSize,
    String? roomCode,
    required bool isPublic,
    required String status,
    required String player1Id,
    String? player2Id,
    required String activePlayerId,
    required int player1Score,
    required int player2Score,
    required int stateVersion,
    String? winnerId,
    required bool isDraw,
    required String stateJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? completedAt,
  }) : super._(
         id: id,
         matchId: matchId,
         gameType: gameType,
         rulesetVersion: rulesetVersion,
         boardSize: boardSize,
         roomCode: roomCode,
         isPublic: isPublic,
         status: status,
         player1Id: player1Id,
         player2Id: player2Id,
         activePlayerId: activePlayerId,
         player1Score: player1Score,
         player2Score: player2Score,
         stateVersion: stateVersion,
         winnerId: winnerId,
         isDraw: isDraw,
         stateJson: stateJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
         completedAt: completedAt,
       );

  /// Returns a shallow copy of this [GameMatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GameMatch copyWith({
    Object? id = _Undefined,
    String? matchId,
    String? gameType,
    String? rulesetVersion,
    int? boardSize,
    Object? roomCode = _Undefined,
    bool? isPublic,
    String? status,
    String? player1Id,
    Object? player2Id = _Undefined,
    String? activePlayerId,
    int? player1Score,
    int? player2Score,
    int? stateVersion,
    Object? winnerId = _Undefined,
    bool? isDraw,
    String? stateJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? completedAt = _Undefined,
  }) {
    return GameMatch(
      id: id is int? ? id : this.id,
      matchId: matchId ?? this.matchId,
      gameType: gameType ?? this.gameType,
      rulesetVersion: rulesetVersion ?? this.rulesetVersion,
      boardSize: boardSize ?? this.boardSize,
      roomCode: roomCode is String? ? roomCode : this.roomCode,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id is String? ? player2Id : this.player2Id,
      activePlayerId: activePlayerId ?? this.activePlayerId,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      stateVersion: stateVersion ?? this.stateVersion,
      winnerId: winnerId is String? ? winnerId : this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      stateJson: stateJson ?? this.stateJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}

class GameMatchUpdateTable extends _is.UpdateTable<GameMatchTable> {
  GameMatchUpdateTable(super.table);

  _is.ColumnValue<String, String> matchId(String value) => _is.ColumnValue(
    table.matchId,
    value,
  );

  _is.ColumnValue<String, String> gameType(String value) => _is.ColumnValue(
    table.gameType,
    value,
  );

  _is.ColumnValue<String, String> rulesetVersion(String value) =>
      _is.ColumnValue(
        table.rulesetVersion,
        value,
      );

  _is.ColumnValue<int, int> boardSize(int value) => _is.ColumnValue(
    table.boardSize,
    value,
  );

  _is.ColumnValue<String, String> roomCode(String? value) => _is.ColumnValue(
    table.roomCode,
    value,
  );

  _is.ColumnValue<bool, bool> isPublic(bool value) => _is.ColumnValue(
    table.isPublic,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> player1Id(String value) => _is.ColumnValue(
    table.player1Id,
    value,
  );

  _is.ColumnValue<String, String> player2Id(String? value) => _is.ColumnValue(
    table.player2Id,
    value,
  );

  _is.ColumnValue<String, String> activePlayerId(String value) =>
      _is.ColumnValue(
        table.activePlayerId,
        value,
      );

  _is.ColumnValue<int, int> player1Score(int value) => _is.ColumnValue(
    table.player1Score,
    value,
  );

  _is.ColumnValue<int, int> player2Score(int value) => _is.ColumnValue(
    table.player2Score,
    value,
  );

  _is.ColumnValue<int, int> stateVersion(int value) => _is.ColumnValue(
    table.stateVersion,
    value,
  );

  _is.ColumnValue<String, String> winnerId(String? value) => _is.ColumnValue(
    table.winnerId,
    value,
  );

  _is.ColumnValue<bool, bool> isDraw(bool value) => _is.ColumnValue(
    table.isDraw,
    value,
  );

  _is.ColumnValue<String, String> stateJson(String value) => _is.ColumnValue(
    table.stateJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );
}

class GameMatchTable extends _is.Table<int?> {
  GameMatchTable({super.tableRelation}) : super(tableName: 'game_match') {
    updateTable = GameMatchUpdateTable(this);
    matchId = _is.ColumnString(
      'matchId',
      this,
    );
    gameType = _is.ColumnString(
      'gameType',
      this,
    );
    rulesetVersion = _is.ColumnString(
      'rulesetVersion',
      this,
    );
    boardSize = _is.ColumnInt(
      'boardSize',
      this,
    );
    roomCode = _is.ColumnString(
      'roomCode',
      this,
    );
    isPublic = _is.ColumnBool(
      'isPublic',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    player1Id = _is.ColumnString(
      'player1Id',
      this,
    );
    player2Id = _is.ColumnString(
      'player2Id',
      this,
    );
    activePlayerId = _is.ColumnString(
      'activePlayerId',
      this,
    );
    player1Score = _is.ColumnInt(
      'player1Score',
      this,
    );
    player2Score = _is.ColumnInt(
      'player2Score',
      this,
    );
    stateVersion = _is.ColumnInt(
      'stateVersion',
      this,
    );
    winnerId = _is.ColumnString(
      'winnerId',
      this,
    );
    isDraw = _is.ColumnBool(
      'isDraw',
      this,
    );
    stateJson = _is.ColumnString(
      'stateJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
  }

  late final GameMatchUpdateTable updateTable;

  late final _is.ColumnString matchId;

  late final _is.ColumnString gameType;

  late final _is.ColumnString rulesetVersion;

  late final _is.ColumnInt boardSize;

  late final _is.ColumnString roomCode;

  late final _is.ColumnBool isPublic;

  late final _is.ColumnString status;

  late final _is.ColumnString player1Id;

  late final _is.ColumnString player2Id;

  late final _is.ColumnString activePlayerId;

  late final _is.ColumnInt player1Score;

  late final _is.ColumnInt player2Score;

  late final _is.ColumnInt stateVersion;

  late final _is.ColumnString winnerId;

  late final _is.ColumnBool isDraw;

  late final _is.ColumnString stateJson;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime completedAt;

  @override
  List<_is.Column> get columns => [
    id,
    matchId,
    gameType,
    rulesetVersion,
    boardSize,
    roomCode,
    isPublic,
    status,
    player1Id,
    player2Id,
    activePlayerId,
    player1Score,
    player2Score,
    stateVersion,
    winnerId,
    isDraw,
    stateJson,
    createdAt,
    updatedAt,
    completedAt,
  ];
}

class GameMatchInclude extends _is.IncludeObject {
  GameMatchInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GameMatch.t;
}

class GameMatchIncludeList extends _is.IncludeList {
  GameMatchIncludeList._({
    _is.WhereExpressionBuilder<GameMatchTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GameMatch.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GameMatch.t;
}

class GameMatchRepository {
  const GameMatchRepository._();

  /// Returns a list of [GameMatch]s matching the given query parameters.
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
  Future<List<GameMatch>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GameMatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GameMatch>(
      where: where?.call(GameMatch.t),
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GameMatch] matching the given query parameters.
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
  Future<GameMatch?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GameMatchTable>? where,
    int? offset,
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GameMatch>(
      where: where?.call(GameMatch.t),
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GameMatch] by its [id] or null if no such row exists.
  Future<GameMatch?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GameMatch>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GameMatch]s in the list and returns the inserted rows.
  ///
  /// The returned [GameMatch]s will have their `id` fields set.
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
  Future<List<GameMatch>> insert(
    _is.DatabaseSession session,
    List<GameMatch> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GameMatch>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GameMatch] and returns the inserted row.
  ///
  /// The returned [GameMatch] will have its `id` field set.
  Future<GameMatch> insertRow(
    _is.DatabaseSession session,
    GameMatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GameMatch>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GameMatch]s in the list and returns the resulting rows.
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
  /// The returned [GameMatch]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GameMatch>> upsert(
    _is.DatabaseSession session,
    List<GameMatch> rows, {
    required _is.ColumnSelections<GameMatchTable> conflictColumns,
    _is.ColumnSelections<GameMatchTable>? updateColumns,
    _is.WhereExpressionBuilder<GameMatchTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GameMatch>(
      rows,
      conflictColumns: conflictColumns(GameMatch.t),
      updateColumns: updateColumns?.call(GameMatch.t),
      updateWhere: updateWhere?.call(GameMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GameMatch] and returns the resulting row.
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
  /// The returned [GameMatch] will have its `id` field set.
  Future<GameMatch?> upsertRow(
    _is.DatabaseSession session,
    GameMatch row, {
    required _is.ColumnSelections<GameMatchTable> conflictColumns,
    _is.ColumnSelections<GameMatchTable>? updateColumns,
    _is.WhereExpressionBuilder<GameMatchTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GameMatch>(
      row,
      conflictColumns: conflictColumns(GameMatch.t),
      updateColumns: updateColumns?.call(GameMatch.t),
      updateWhere: updateWhere?.call(GameMatch.t),
      transaction: transaction,
    );
  }

  /// Updates all [GameMatch]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GameMatch>> update(
    _is.DatabaseSession session,
    List<GameMatch> rows, {
    _is.ColumnSelections<GameMatchTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GameMatch>(
      rows,
      columns: columns?.call(GameMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GameMatch]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GameMatch> updateRow(
    _is.DatabaseSession session,
    GameMatch row, {
    _is.ColumnSelections<GameMatchTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GameMatch>(
      row,
      columns: columns?.call(GameMatch.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GameMatch] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GameMatch?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GameMatchUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GameMatch>(
      id,
      columnValues: columnValues(GameMatch.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GameMatch]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GameMatch>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GameMatchUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GameMatchTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GameMatch>(
      columnValues: columnValues(GameMatch.t.updateTable),
      where: where(GameMatch.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GameMatch]s in the list and returns the deleted rows.
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
  Future<List<GameMatch>> delete(
    _is.DatabaseSession session,
    List<GameMatch> rows, {
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GameMatch>(
      rows,
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GameMatch].
  Future<GameMatch> deleteRow(
    _is.DatabaseSession session,
    GameMatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GameMatch>(
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
  Future<List<GameMatch>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GameMatchTable> where,
    _is.OrderByBuilder<GameMatchTable>? orderBy,
    _is.OrderByListBuilder<GameMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GameMatch>(
      where: where(GameMatch.t),
      orderBy: orderBy?.call(GameMatch.t),
      orderByList: orderByList?.call(GameMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GameMatchTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GameMatch>(
      where: where?.call(GameMatch.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GameMatch] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GameMatchTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GameMatch>(
      where: where(GameMatch.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
