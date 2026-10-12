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
import 'package:one_v_one_server/src/generated/protocol.dart' as _iv6ukpwq;
import 'package:serverpod/serverpod.dart' as _is;
import 'game_match.dart' as _i05c3kpq;
import 'player_profile.dart' as _i5i3bhsm;
import 'scheduled_job_log.dart' as _ika9uxac;

abstract class AdminDashboardData
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminDashboardData._({
    required this.serverTime,
    required this.runMode,
    required this.serverId,
    required this.uptimeSeconds,
    required this.dbLatencyMs,
    required this.totalMatches,
    required this.waitingMatches,
    required this.inProgressMatches,
    required this.completedMatches,
    required this.totalPlayers,
    required this.totalMoves,
    required this.totalScheduledLogs,
    required this.totalLeaderboardRows,
    required this.localCacheEntries,
    required this.localPrioCacheEntries,
    required this.recentMatches,
    required this.recentJobLogs,
    required this.recentPlayers,
  });

  factory AdminDashboardData({
    required DateTime serverTime,
    required String runMode,
    required String serverId,
    required int uptimeSeconds,
    required int dbLatencyMs,
    required int totalMatches,
    required int waitingMatches,
    required int inProgressMatches,
    required int completedMatches,
    required int totalPlayers,
    required int totalMoves,
    required int totalScheduledLogs,
    required int totalLeaderboardRows,
    required int localCacheEntries,
    required int localPrioCacheEntries,
    required List<_i05c3kpq.GameMatch> recentMatches,
    required List<_ika9uxac.ScheduledJobLog> recentJobLogs,
    required List<_i5i3bhsm.PlayerProfile> recentPlayers,
  }) = _AdminDashboardDataImpl;

  factory AdminDashboardData.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminDashboardData(
      serverTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
      runMode: jsonSerialization['runMode'] as String,
      serverId: jsonSerialization['serverId'] as String,
      uptimeSeconds: jsonSerialization['uptimeSeconds'] as int,
      dbLatencyMs: jsonSerialization['dbLatencyMs'] as int,
      totalMatches: jsonSerialization['totalMatches'] as int,
      waitingMatches: jsonSerialization['waitingMatches'] as int,
      inProgressMatches: jsonSerialization['inProgressMatches'] as int,
      completedMatches: jsonSerialization['completedMatches'] as int,
      totalPlayers: jsonSerialization['totalPlayers'] as int,
      totalMoves: jsonSerialization['totalMoves'] as int,
      totalScheduledLogs: jsonSerialization['totalScheduledLogs'] as int,
      totalLeaderboardRows: jsonSerialization['totalLeaderboardRows'] as int,
      localCacheEntries: jsonSerialization['localCacheEntries'] as int,
      localPrioCacheEntries: jsonSerialization['localPrioCacheEntries'] as int,
      recentMatches: _iv6ukpwq.Protocol()
          .deserialize<List<_i05c3kpq.GameMatch>>(
            jsonSerialization['recentMatches'],
          ),
      recentJobLogs: _iv6ukpwq.Protocol()
          .deserialize<List<_ika9uxac.ScheduledJobLog>>(
            jsonSerialization['recentJobLogs'],
          ),
      recentPlayers: _iv6ukpwq.Protocol()
          .deserialize<List<_i5i3bhsm.PlayerProfile>>(
            jsonSerialization['recentPlayers'],
          ),
    );
  }

  DateTime serverTime;

  String runMode;

  String serverId;

  int uptimeSeconds;

  int dbLatencyMs;

  int totalMatches;

  int waitingMatches;

  int inProgressMatches;

  int completedMatches;

  int totalPlayers;

  int totalMoves;

  int totalScheduledLogs;

  int totalLeaderboardRows;

  int localCacheEntries;

  int localPrioCacheEntries;

  List<_i05c3kpq.GameMatch> recentMatches;

  List<_ika9uxac.ScheduledJobLog> recentJobLogs;

  List<_i5i3bhsm.PlayerProfile> recentPlayers;

  /// Returns a shallow copy of this [AdminDashboardData]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminDashboardData copyWith({
    DateTime? serverTime,
    String? runMode,
    String? serverId,
    int? uptimeSeconds,
    int? dbLatencyMs,
    int? totalMatches,
    int? waitingMatches,
    int? inProgressMatches,
    int? completedMatches,
    int? totalPlayers,
    int? totalMoves,
    int? totalScheduledLogs,
    int? totalLeaderboardRows,
    int? localCacheEntries,
    int? localPrioCacheEntries,
    List<_i05c3kpq.GameMatch>? recentMatches,
    List<_ika9uxac.ScheduledJobLog>? recentJobLogs,
    List<_i5i3bhsm.PlayerProfile>? recentPlayers,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDashboardData',
      'serverTime': serverTime.toJson(),
      'runMode': runMode,
      'serverId': serverId,
      'uptimeSeconds': uptimeSeconds,
      'dbLatencyMs': dbLatencyMs,
      'totalMatches': totalMatches,
      'waitingMatches': waitingMatches,
      'inProgressMatches': inProgressMatches,
      'completedMatches': completedMatches,
      'totalPlayers': totalPlayers,
      'totalMoves': totalMoves,
      'totalScheduledLogs': totalScheduledLogs,
      'totalLeaderboardRows': totalLeaderboardRows,
      'localCacheEntries': localCacheEntries,
      'localPrioCacheEntries': localPrioCacheEntries,
      'recentMatches': recentMatches.toJson(valueToJson: (v) => v.toJson()),
      'recentJobLogs': recentJobLogs.toJson(valueToJson: (v) => v.toJson()),
      'recentPlayers': recentPlayers.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminDashboardData',
      'serverTime': serverTime.toJson(),
      'runMode': runMode,
      'serverId': serverId,
      'uptimeSeconds': uptimeSeconds,
      'dbLatencyMs': dbLatencyMs,
      'totalMatches': totalMatches,
      'waitingMatches': waitingMatches,
      'inProgressMatches': inProgressMatches,
      'completedMatches': completedMatches,
      'totalPlayers': totalPlayers,
      'totalMoves': totalMoves,
      'totalScheduledLogs': totalScheduledLogs,
      'totalLeaderboardRows': totalLeaderboardRows,
      'localCacheEntries': localCacheEntries,
      'localPrioCacheEntries': localPrioCacheEntries,
      'recentMatches': recentMatches.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'recentJobLogs': recentJobLogs.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'recentPlayers': recentPlayers.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AdminDashboardDataImpl extends AdminDashboardData {
  _AdminDashboardDataImpl({
    required DateTime serverTime,
    required String runMode,
    required String serverId,
    required int uptimeSeconds,
    required int dbLatencyMs,
    required int totalMatches,
    required int waitingMatches,
    required int inProgressMatches,
    required int completedMatches,
    required int totalPlayers,
    required int totalMoves,
    required int totalScheduledLogs,
    required int totalLeaderboardRows,
    required int localCacheEntries,
    required int localPrioCacheEntries,
    required List<_i05c3kpq.GameMatch> recentMatches,
    required List<_ika9uxac.ScheduledJobLog> recentJobLogs,
    required List<_i5i3bhsm.PlayerProfile> recentPlayers,
  }) : super._(
         serverTime: serverTime,
         runMode: runMode,
         serverId: serverId,
         uptimeSeconds: uptimeSeconds,
         dbLatencyMs: dbLatencyMs,
         totalMatches: totalMatches,
         waitingMatches: waitingMatches,
         inProgressMatches: inProgressMatches,
         completedMatches: completedMatches,
         totalPlayers: totalPlayers,
         totalMoves: totalMoves,
         totalScheduledLogs: totalScheduledLogs,
         totalLeaderboardRows: totalLeaderboardRows,
         localCacheEntries: localCacheEntries,
         localPrioCacheEntries: localPrioCacheEntries,
         recentMatches: recentMatches,
         recentJobLogs: recentJobLogs,
         recentPlayers: recentPlayers,
       );

  /// Returns a shallow copy of this [AdminDashboardData]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminDashboardData copyWith({
    DateTime? serverTime,
    String? runMode,
    String? serverId,
    int? uptimeSeconds,
    int? dbLatencyMs,
    int? totalMatches,
    int? waitingMatches,
    int? inProgressMatches,
    int? completedMatches,
    int? totalPlayers,
    int? totalMoves,
    int? totalScheduledLogs,
    int? totalLeaderboardRows,
    int? localCacheEntries,
    int? localPrioCacheEntries,
    List<_i05c3kpq.GameMatch>? recentMatches,
    List<_ika9uxac.ScheduledJobLog>? recentJobLogs,
    List<_i5i3bhsm.PlayerProfile>? recentPlayers,
  }) {
    return AdminDashboardData(
      serverTime: serverTime ?? this.serverTime,
      runMode: runMode ?? this.runMode,
      serverId: serverId ?? this.serverId,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      dbLatencyMs: dbLatencyMs ?? this.dbLatencyMs,
      totalMatches: totalMatches ?? this.totalMatches,
      waitingMatches: waitingMatches ?? this.waitingMatches,
      inProgressMatches: inProgressMatches ?? this.inProgressMatches,
      completedMatches: completedMatches ?? this.completedMatches,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      totalMoves: totalMoves ?? this.totalMoves,
      totalScheduledLogs: totalScheduledLogs ?? this.totalScheduledLogs,
      totalLeaderboardRows: totalLeaderboardRows ?? this.totalLeaderboardRows,
      localCacheEntries: localCacheEntries ?? this.localCacheEntries,
      localPrioCacheEntries:
          localPrioCacheEntries ?? this.localPrioCacheEntries,
      recentMatches:
          recentMatches ??
          this.recentMatches.map((e0) => e0.copyWith()).toList(),
      recentJobLogs:
          recentJobLogs ??
          this.recentJobLogs.map((e0) => e0.copyWith()).toList(),
      recentPlayers:
          recentPlayers ??
          this.recentPlayers.map((e0) => e0.copyWith()).toList(),
    );
  }
}
