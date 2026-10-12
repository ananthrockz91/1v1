import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/daily_maintenance_processor.dart';

class LeaderboardEndpoint extends Endpoint {
  /// Fetch daily leaderboard for a specific date (defaults to today).
  /// Uses Serverpod in-memory local caching (5-minute TTL) with group invalidation.
  Future<List<DailyLeaderboard>> getDailyLeaderboard(
    Session session, {
    String? dateString,
    int limit = 50,
  }) async {
    final date =
        dateString ?? DailyMaintenanceProcessor.formatDate(DateTime.now());
    final cacheKey = 'daily_leaderboard_${date}_$limit';

    try {
      final cachedJson = await session.caches.local.get<String>(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as List;
        return decoded
            .map(
              (item) => DailyLeaderboard.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      session.log(
        'Cache read error for $cacheKey: $e',
        level: LogLevel.warning,
      );
    }

    final rows = await DailyLeaderboard.db.find(
      session,
      where: (t) => t.dateString.equals(date),
      orderByList: (t) => [t.rank.asc()],
      limit: limit,
    );

    try {
      final encoded = jsonEncode(rows.map((r) => r.toJson()).toList());
      await session.caches.local.put(
        cacheKey,
        encoded,
        lifetime: const Duration(minutes: 5),
        group: 'leaderboards',
      );
    } catch (e) {
      session.log(
        'Cache write error for $cacheKey: $e',
        level: LogLevel.warning,
      );
    }

    return rows;
  }

  /// Fetch all-time leaderboard from player profiles.
  /// Uses Serverpod in-memory local caching (2-minute TTL).
  Future<List<PlayerProfile>> getAllTimeLeaderboard(
    Session session, {
    int limit = 50,
  }) async {
    final cacheKey = 'all_time_leaderboard_$limit';

    try {
      final cachedJson = await session.caches.local.get<String>(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as List;
        return decoded
            .map((item) => PlayerProfile.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      session.log(
        'Cache read error for $cacheKey: $e',
        level: LogLevel.warning,
      );
    }

    final rows = await PlayerProfile.db.find(
      session,
      where: (t) => t.totalMatches > 0,
      orderByList: (t) => [t.wins.desc()],
      limit: limit,
    );

    try {
      final encoded = jsonEncode(rows.map((r) => r.toJson()).toList());
      await session.caches.local.put(
        cacheKey,
        encoded,
        lifetime: const Duration(minutes: 2),
        group: 'leaderboards',
      );
    } catch (e) {
      session.log(
        'Cache write error for $cacheKey: $e',
        level: LogLevel.warning,
      );
    }

    return rows;
  }
}
