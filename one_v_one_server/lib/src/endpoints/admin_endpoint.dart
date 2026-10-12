import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/daily_maintenance_processor.dart';

class AdminEndpoint extends Endpoint {
  /// Development/demo manual trigger to run the daily maintenance process
  /// on demand without waiting for 1:00 AM IST.
  Future<ScheduledJobLog> triggerDailyMaintenance(
    Session session, {
    String? targetDate,
  }) async {
    final caller = session.authenticated?.userIdentifier ?? 'development_user';
    session.log(
      'Manual trigger of daily maintenance requested by $caller',
      level: LogLevel.info,
    );
    return await DailyMaintenanceProcessor.run(
      session,
      targetDate: targetDate,
    );
  }

  /// Clears in-memory caches across leaderboards and profiles.
  Future<bool> clearCaches(Session session) async {
    try {
      await session.caches.local.clear();
      await session.caches.localPrio.clear();
      session.log('Admin cleared server local caches', level: LogLevel.info);
      return true;
    } catch (e) {
      session.log('Failed to clear caches: $e', level: LogLevel.error);
      return false;
    }
  }

  static final DateTime _startedAt = DateTime.now();

  /// Comprehensive real-time backend overview aggregating Serverpod runtime metrics,
  /// PostgreSQL table counts, in-memory cache statistics, and recent activity records.
  Future<AdminDashboardData> getDashboardData(Session session) async {
    final sw = Stopwatch()..start();
    final logCount = await ScheduledJobLog.db.count(session);
    sw.stop();

    final totalMatches = await GameMatch.db.count(session);
    final waitingMatches = await GameMatch.db.count(
      session,
      where: (t) => t.status.equals('waiting'),
    );
    final inProgressMatches = await GameMatch.db.count(
      session,
      where: (t) => t.status.equals('in_progress'),
    );
    final completedMatches = await GameMatch.db.count(
      session,
      where: (t) => t.status.equals('completed'),
    );
    final totalPlayers = await PlayerProfile.db.count(session);
    final totalMoves = await MatchMoveRecord.db.count(session);
    final totalLeaderboards = await DailyLeaderboard.db.count(session);

    final recentMatches = await GameMatch.db.find(
      session,
      orderByList: (t) => [t.createdAt.desc()],
      limit: 10,
    );

    final recentJobLogs = await ScheduledJobLog.db.find(
      session,
      orderByList: (t) => [t.executedAt.desc()],
      limit: 6,
    );

    final recentPlayers = await PlayerProfile.db.find(
      session,
      orderByList: (t) => [t.wins.desc(), t.totalMatches.desc()],
      limit: 6,
    );

    final uptime = DateTime.now().difference(_startedAt).inSeconds;

    return AdminDashboardData(
      serverTime: DateTime.now().toUtc(),
      runMode: session.server.runMode,
      serverId: session.server.serverId,
      uptimeSeconds: uptime,
      dbLatencyMs: sw.elapsedMilliseconds,
      totalMatches: totalMatches,
      waitingMatches: waitingMatches,
      inProgressMatches: inProgressMatches,
      completedMatches: completedMatches,
      totalPlayers: totalPlayers,
      totalMoves: totalMoves,
      totalScheduledLogs: logCount,
      totalLeaderboardRows: totalLeaderboards,
      localCacheEntries: session.caches.local.localSize,
      localPrioCacheEntries: session.caches.localPrio.localSize,
      recentMatches: recentMatches,
      recentJobLogs: recentJobLogs,
      recentPlayers: recentPlayers,
    );
  }
}
