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

abstract class MatchMoveRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      extraTurn: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['extraTurn'],
      ),
      stateVersion: jsonSerialization['stateVersion'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [MatchMoveRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
