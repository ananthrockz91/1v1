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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class GameMatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      isPublic: _isc.BoolJsonExtension.fromJson(jsonSerialization['isPublic']),
      status: jsonSerialization['status'] as String,
      player1Id: jsonSerialization['player1Id'] as String,
      player2Id: jsonSerialization['player2Id'] as String?,
      activePlayerId: jsonSerialization['activePlayerId'] as String,
      player1Score: jsonSerialization['player1Score'] as int,
      player2Score: jsonSerialization['player2Score'] as int,
      stateVersion: jsonSerialization['stateVersion'] as int,
      winnerId: jsonSerialization['winnerId'] as String?,
      isDraw: _isc.BoolJsonExtension.fromJson(jsonSerialization['isDraw']),
      stateJson: jsonSerialization['stateJson'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [GameMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
