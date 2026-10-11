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

abstract class PlayerProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastActiveAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActiveAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [PlayerProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
