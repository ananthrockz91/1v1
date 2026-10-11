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

abstract class ScheduledJobLog
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      executedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['executedAt'],
      ),
      targetDate: jsonSerialization['targetDate'] as String,
      staleLobbiesCleaned: jsonSerialization['staleLobbiesCleaned'] as int,
      abandonedMatchesProcessed:
          jsonSerialization['abandonedMatchesProcessed'] as int,
      leaderboardsAggregated:
          jsonSerialization['leaderboardsAggregated'] as int,
      success: _isc.BoolJsonExtension.fromJson(jsonSerialization['success']),
      errorDetails: jsonSerialization['errorDetails'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String jobName;

  DateTime executedAt;

  String targetDate;

  int staleLobbiesCleaned;

  int abandonedMatchesProcessed;

  int leaderboardsAggregated;

  bool success;

  String? errorDetails;

  /// Returns a shallow copy of this [ScheduledJobLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
