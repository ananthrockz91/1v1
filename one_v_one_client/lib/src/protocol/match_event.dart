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
import 'package:one_v_one_client/src/protocol/protocol.dart' as _i9b5jvrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class MatchEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MatchEvent._({
    required this.matchId,
    required this.eventType,
    required this.stateVersion,
    required this.activePlayerId,
    this.edgeId,
    this.claimedTriangles,
    this.extraTurn,
    required this.player1Score,
    required this.player2Score,
    required this.isTerminal,
    this.winnerId,
    required this.isDraw,
    this.stateJson,
    required this.timestamp,
  });

  factory MatchEvent({
    required String matchId,
    required String eventType,
    required int stateVersion,
    required String activePlayerId,
    String? edgeId,
    List<String>? claimedTriangles,
    bool? extraTurn,
    required int player1Score,
    required int player2Score,
    required bool isTerminal,
    String? winnerId,
    required bool isDraw,
    String? stateJson,
    required DateTime timestamp,
  }) = _MatchEventImpl;

  factory MatchEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return MatchEvent(
      matchId: jsonSerialization['matchId'] as String,
      eventType: jsonSerialization['eventType'] as String,
      stateVersion: jsonSerialization['stateVersion'] as int,
      activePlayerId: jsonSerialization['activePlayerId'] as String,
      edgeId: jsonSerialization['edgeId'] as String?,
      claimedTriangles: jsonSerialization['claimedTriangles'] == null
          ? null
          : _i9b5jvrz.Protocol().deserialize<List<String>>(
              jsonSerialization['claimedTriangles'],
            ),
      extraTurn: jsonSerialization['extraTurn'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['extraTurn']),
      player1Score: jsonSerialization['player1Score'] as int,
      player2Score: jsonSerialization['player2Score'] as int,
      isTerminal: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isTerminal'],
      ),
      winnerId: jsonSerialization['winnerId'] as String?,
      isDraw: _isc.BoolJsonExtension.fromJson(jsonSerialization['isDraw']),
      stateJson: jsonSerialization['stateJson'] as String?,
      timestamp: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  String matchId;

  String eventType;

  int stateVersion;

  String activePlayerId;

  String? edgeId;

  List<String>? claimedTriangles;

  bool? extraTurn;

  int player1Score;

  int player2Score;

  bool isTerminal;

  String? winnerId;

  bool isDraw;

  String? stateJson;

  DateTime timestamp;

  /// Returns a shallow copy of this [MatchEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MatchEvent copyWith({
    String? matchId,
    String? eventType,
    int? stateVersion,
    String? activePlayerId,
    String? edgeId,
    List<String>? claimedTriangles,
    bool? extraTurn,
    int? player1Score,
    int? player2Score,
    bool? isTerminal,
    String? winnerId,
    bool? isDraw,
    String? stateJson,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MatchEvent',
      'matchId': matchId,
      'eventType': eventType,
      'stateVersion': stateVersion,
      'activePlayerId': activePlayerId,
      if (edgeId != null) 'edgeId': edgeId,
      if (claimedTriangles != null)
        'claimedTriangles': claimedTriangles?.toJson(),
      if (extraTurn != null) 'extraTurn': extraTurn,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'isTerminal': isTerminal,
      if (winnerId != null) 'winnerId': winnerId,
      'isDraw': isDraw,
      if (stateJson != null) 'stateJson': stateJson,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MatchEvent',
      'matchId': matchId,
      'eventType': eventType,
      'stateVersion': stateVersion,
      'activePlayerId': activePlayerId,
      if (edgeId != null) 'edgeId': edgeId,
      if (claimedTriangles != null)
        'claimedTriangles': claimedTriangles?.toJson(),
      if (extraTurn != null) 'extraTurn': extraTurn,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'isTerminal': isTerminal,
      if (winnerId != null) 'winnerId': winnerId,
      'isDraw': isDraw,
      if (stateJson != null) 'stateJson': stateJson,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MatchEventImpl extends MatchEvent {
  _MatchEventImpl({
    required String matchId,
    required String eventType,
    required int stateVersion,
    required String activePlayerId,
    String? edgeId,
    List<String>? claimedTriangles,
    bool? extraTurn,
    required int player1Score,
    required int player2Score,
    required bool isTerminal,
    String? winnerId,
    required bool isDraw,
    String? stateJson,
    required DateTime timestamp,
  }) : super._(
         matchId: matchId,
         eventType: eventType,
         stateVersion: stateVersion,
         activePlayerId: activePlayerId,
         edgeId: edgeId,
         claimedTriangles: claimedTriangles,
         extraTurn: extraTurn,
         player1Score: player1Score,
         player2Score: player2Score,
         isTerminal: isTerminal,
         winnerId: winnerId,
         isDraw: isDraw,
         stateJson: stateJson,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [MatchEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MatchEvent copyWith({
    String? matchId,
    String? eventType,
    int? stateVersion,
    String? activePlayerId,
    Object? edgeId = _Undefined,
    Object? claimedTriangles = _Undefined,
    Object? extraTurn = _Undefined,
    int? player1Score,
    int? player2Score,
    bool? isTerminal,
    Object? winnerId = _Undefined,
    bool? isDraw,
    Object? stateJson = _Undefined,
    DateTime? timestamp,
  }) {
    return MatchEvent(
      matchId: matchId ?? this.matchId,
      eventType: eventType ?? this.eventType,
      stateVersion: stateVersion ?? this.stateVersion,
      activePlayerId: activePlayerId ?? this.activePlayerId,
      edgeId: edgeId is String? ? edgeId : this.edgeId,
      claimedTriangles: claimedTriangles is List<String>?
          ? claimedTriangles
          : this.claimedTriangles?.map((e0) => e0).toList(),
      extraTurn: extraTurn is bool? ? extraTurn : this.extraTurn,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      isTerminal: isTerminal ?? this.isTerminal,
      winnerId: winnerId is String? ? winnerId : this.winnerId,
      isDraw: isDraw ?? this.isDraw,
      stateJson: stateJson is String? ? stateJson : this.stateJson,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
