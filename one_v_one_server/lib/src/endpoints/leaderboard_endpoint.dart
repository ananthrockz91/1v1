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

  /// Fetch leaderboard filtered by gameType ('all', 'triangle_tactics', 'connect_four', 'reversi').
  /// Computes game-specific wins and standings from completed matches.
  Future<List<PlayerProfile>> getGameLeaderboard(
    Session session, {
    required String gameType,
    int limit = 50,
  }) async {
    if (gameType == 'all' || gameType.isEmpty) {
      return await getAllTimeLeaderboard(session, limit: limit);
    }

    final cacheKey = 'game_leaderboard_${gameType}_$limit';
    try {
      final cachedJson = await session.caches.local.get<String>(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as List;
        return decoded
            .map((item) => PlayerProfile.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    final matches = await GameMatch.db.find(
      session,
      where: (t) => t.status.equals('completed') & t.gameType.equals(gameType),
      limit: 1000,
    );

    final Map<String, int> winsMap = {};
    final Map<String, int> totalMap = {};
    for (final m in matches) {
      final p1 = m.player1Id;
      final p2 = m.player2Id;
      totalMap[p1] = (totalMap[p1] ?? 0) + 1;
      if (p2 != null) totalMap[p2] = (totalMap[p2] ?? 0) + 1;
      if (m.winnerId != null) {
        winsMap[m.winnerId!] = (winsMap[m.winnerId!] ?? 0) + 1;
      }
    }

    final sortedPlayerIds = totalMap.keys.toList()
      ..sort((a, b) {
        final cmp = (winsMap[b] ?? 0).compareTo(winsMap[a] ?? 0);
        if (cmp != 0) return cmp;
        return (totalMap[b] ?? 0).compareTo(totalMap[a] ?? 0);
      });

    final targetIds = sortedPlayerIds.take(limit).toList();
    if (targetIds.isEmpty) return [];

    final profiles = await PlayerProfile.db.find(
      session,
      where: (t) => t.playerId.inSet(targetIds.toSet()),
    );
    final profileMap = {for (final p in profiles) p.playerId: p};

    final result = <PlayerProfile>[];
    for (final id in targetIds) {
      final existing = profileMap[id];
      final wins = winsMap[id] ?? 0;
      final total = totalMap[id] ?? 0;
      final p = PlayerProfile(
        id: existing?.id,
        playerId: id,
        displayName:
            existing?.displayName ??
            'Player_${id.length > 5 ? id.substring(0, 5) : id}',
        avatarSeed: existing?.avatarSeed ?? 'avatar_1',
        totalMatches: total,
        wins: wins,
        losses: total - wins,
        draws: 0,
        trianglesCaptured: existing?.trianglesCaptured ?? 0,
        createdAt: existing?.createdAt ?? DateTime.now(),
        lastActiveAt: existing?.lastActiveAt ?? DateTime.now(),
      );
      result.add(p);
    }

    try {
      final encoded = jsonEncode(result.map((r) => r.toJson()).toList());
      await session.caches.local.put(
        cacheKey,
        encoded,
        lifetime: const Duration(minutes: 2),
        group: 'leaderboards',
      );
    } catch (_) {}

    return result;
  }
}
