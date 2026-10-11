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

abstract class DailyLeaderboard
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [DailyLeaderboard]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
