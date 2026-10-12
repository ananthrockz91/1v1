/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:one_v_one_client/src/protocol/daily_leaderboard.dart'
    as _iqbb7t4g;
import 'package:one_v_one_client/src/protocol/game_match.dart' as _i5zwpjwi;
import 'package:one_v_one_client/src/protocol/match_move_record.dart'
    as _i7uf79mb;
import 'package:one_v_one_client/src/protocol/player_profile.dart' as _i380unr6;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'admin_dashboard_data.dart' as _iede5zvu;
import 'daily_leaderboard.dart' as _iujnqntu;
import 'game_match.dart' as _i05c3kpq;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'match_event.dart' as _is31pezq;
import 'match_move_record.dart' as _inszzmuc;
import 'player_profile.dart' as _i5i3bhsm;
import 'scheduled_job_log.dart' as _ika9uxac;
export 'admin_dashboard_data.dart';
export 'daily_leaderboard.dart';
export 'game_match.dart';
export 'greetings/greeting.dart';
export 'match_event.dart';
export 'match_move_record.dart';
export 'player_profile.dart';
export 'scheduled_job_log.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iede5zvu.AdminDashboardData) {
      return _iede5zvu.AdminDashboardData.fromJson(data) as T;
    }
    if (t == _iujnqntu.DailyLeaderboard) {
      return _iujnqntu.DailyLeaderboard.fromJson(data) as T;
    }
    if (t == _i05c3kpq.GameMatch) {
      return _i05c3kpq.GameMatch.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _is31pezq.MatchEvent) {
      return _is31pezq.MatchEvent.fromJson(data) as T;
    }
    if (t == _inszzmuc.MatchMoveRecord) {
      return _inszzmuc.MatchMoveRecord.fromJson(data) as T;
    }
    if (t == _i5i3bhsm.PlayerProfile) {
      return _i5i3bhsm.PlayerProfile.fromJson(data) as T;
    }
    if (t == _ika9uxac.ScheduledJobLog) {
      return _ika9uxac.ScheduledJobLog.fromJson(data) as T;
    }
    if (t == _isc.getType<_iede5zvu.AdminDashboardData?>()) {
      return (data != null ? _iede5zvu.AdminDashboardData.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iujnqntu.DailyLeaderboard?>()) {
      return (data != null ? _iujnqntu.DailyLeaderboard.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i05c3kpq.GameMatch?>()) {
      return (data != null ? _i05c3kpq.GameMatch.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_is31pezq.MatchEvent?>()) {
      return (data != null ? _is31pezq.MatchEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_inszzmuc.MatchMoveRecord?>()) {
      return (data != null ? _inszzmuc.MatchMoveRecord.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i5i3bhsm.PlayerProfile?>()) {
      return (data != null ? _i5i3bhsm.PlayerProfile.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ika9uxac.ScheduledJobLog?>()) {
      return (data != null ? _ika9uxac.ScheduledJobLog.fromJson(data) : null)
          as T;
    }
    if (t == List<_i05c3kpq.GameMatch>) {
      return (data as List)
              .map((e) => deserialize<_i05c3kpq.GameMatch>(e))
              .toList()
          as T;
    }
    if (t == List<_ika9uxac.ScheduledJobLog>) {
      return (data as List)
              .map((e) => deserialize<_ika9uxac.ScheduledJobLog>(e))
              .toList()
          as T;
    }
    if (t == List<_i5i3bhsm.PlayerProfile>) {
      return (data as List)
              .map((e) => deserialize<_i5i3bhsm.PlayerProfile>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_iqbb7t4g.DailyLeaderboard>) {
      return (data as List)
              .map((e) => deserialize<_iqbb7t4g.DailyLeaderboard>(e))
              .toList()
          as T;
    }
    if (t == List<_i380unr6.PlayerProfile>) {
      return (data as List)
              .map((e) => deserialize<_i380unr6.PlayerProfile>(e))
              .toList()
          as T;
    }
    if (t == List<_i5zwpjwi.GameMatch>) {
      return (data as List)
              .map((e) => deserialize<_i5zwpjwi.GameMatch>(e))
              .toList()
          as T;
    }
    if (t == List<_i7uf79mb.MatchMoveRecord>) {
      return (data as List)
              .map((e) => deserialize<_i7uf79mb.MatchMoveRecord>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iede5zvu.AdminDashboardData => 'AdminDashboardData',
      _iujnqntu.DailyLeaderboard => 'DailyLeaderboard',
      _i05c3kpq.GameMatch => 'GameMatch',
      _izw8z7ou.Greeting => 'Greeting',
      _is31pezq.MatchEvent => 'MatchEvent',
      _inszzmuc.MatchMoveRecord => 'MatchMoveRecord',
      _i5i3bhsm.PlayerProfile => 'PlayerProfile',
      _ika9uxac.ScheduledJobLog => 'ScheduledJobLog',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('one_v_one.', '');
    }

    switch (data) {
      case _iede5zvu.AdminDashboardData():
        return 'AdminDashboardData';
      case _iujnqntu.DailyLeaderboard():
        return 'DailyLeaderboard';
      case _i05c3kpq.GameMatch():
        return 'GameMatch';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _is31pezq.MatchEvent():
        return 'MatchEvent';
      case _inszzmuc.MatchMoveRecord():
        return 'MatchMoveRecord';
      case _i5i3bhsm.PlayerProfile():
        return 'PlayerProfile';
      case _ika9uxac.ScheduledJobLog():
        return 'ScheduledJobLog';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminDashboardData') {
      return deserialize<_iede5zvu.AdminDashboardData>(data['data']);
    }
    if (dataClassName == 'DailyLeaderboard') {
      return deserialize<_iujnqntu.DailyLeaderboard>(data['data']);
    }
    if (dataClassName == 'GameMatch') {
      return deserialize<_i05c3kpq.GameMatch>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'MatchEvent') {
      return deserialize<_is31pezq.MatchEvent>(data['data']);
    }
    if (dataClassName == 'MatchMoveRecord') {
      return deserialize<_inszzmuc.MatchMoveRecord>(data['data']);
    }
    if (dataClassName == 'PlayerProfile') {
      return deserialize<_i5i3bhsm.PlayerProfile>(data['data']);
    }
    if (dataClassName == 'ScheduledJobLog') {
      return deserialize<_ika9uxac.ScheduledJobLog>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('one_v_one', this);
    _iacc.Protocol().registerHostProtocol('one_v_one', this);
  }

  @override
  String getModuleName() => 'one_v_one';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
