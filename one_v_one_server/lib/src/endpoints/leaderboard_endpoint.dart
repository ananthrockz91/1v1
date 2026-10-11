import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/daily_maintenance_processor.dart';

class LeaderboardEndpoint extends Endpoint {
  /// Fetch daily leaderboard for a specific date (defaults to today).
  Future<List<DailyLeaderboard>> getDailyLeaderboard(
    Session session, {
    String? dateString,
    int limit = 50,
  }) async {
    final date =
        dateString ?? DailyMaintenanceProcessor.formatDate(DateTime.now());
    return await DailyLeaderboard.db.find(
      session,
      where: (t) => t.dateString.equals(date),
      orderByList: (t) => [t.rank.asc()],
      limit: limit,
    );
  }

  /// Fetch all-time leaderboard from player profiles.
  Future<List<PlayerProfile>> getAllTimeLeaderboard(
    Session session, {
    int limit = 50,
  }) async {
    return await PlayerProfile.db.find(
      session,
      where: (t) => t.totalMatches > 0,
      orderByList: (t) => [t.wins.desc()],
      limit: limit,
    );
  }
}
