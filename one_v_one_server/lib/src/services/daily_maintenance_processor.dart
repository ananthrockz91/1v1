import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class DailyMaintenanceProcessor {
  /// Formats a DateTime into YYYY-MM-DD
  static String formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Calculates the next DateTime corresponding to 1:00 AM IST (Asia/Kolkata, UTC+5:30).
  static DateTime getNext1AmIst() {
    final nowUtc = DateTime.now().toUtc();
    // 1:00 AM IST is 19:30 UTC of previous day
    // e.g. If current UTC is before 19:30 today, next trigger is today at 19:30 UTC.
    // If current UTC is after 19:30 today, next trigger is tomorrow at 19:30 UTC.
    var targetUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 19, 30);
    if (!targetUtc.isAfter(nowUtc)) {
      targetUtc = targetUtc.add(const Duration(days: 1));
    }
    return targetUtc;
  }

  /// Executes daily maintenance logic. Fully idempotent.
  static Future<ScheduledJobLog> run(
    Session session, {
    String? targetDate,
  }) async {
    final dateStr = targetDate ?? formatDate(DateTime.now());
    final startTime = DateTime.now();

    int staleLobbiesCount = 0;
    int abandonedMatchesCount = 0;
    int leaderboardsCount = 0;

    try {
      // 1. Expire stale waiting lobbies (> 1 hour old)
      final lobbyCutoff = startTime.subtract(const Duration(hours: 1));
      final staleLobbies = await GameMatch.db.find(
        session,
        where: (t) => t.status.equals('waiting') & (t.createdAt < lobbyCutoff),
      );

      for (final match in staleLobbies) {
        match.status = 'abandoned';
        match.updatedAt = startTime;
        await GameMatch.db.updateRow(session, match);
        staleLobbiesCount++;
      }

      // 2. Process abandoned in_progress matches (> 24 hours inactive)
      final matchCutoff = startTime.subtract(const Duration(hours: 24));
      final abandonedMatches = await GameMatch.db.find(
        session,
        where: (t) =>
            t.status.equals('in_progress') & (t.updatedAt < matchCutoff),
      );

      for (final match in abandonedMatches) {
        match.status = 'abandoned';
        match.updatedAt = startTime;
        await GameMatch.db.updateRow(session, match);
        abandonedMatchesCount++;
      }

      // 3. Aggregate daily match results for targetDate
      // Filter matches completed on this date
      final allCompleted = await GameMatch.db.find(
        session,
        where: (t) => t.status.equals('completed'),
      );

      final dailyMatches = allCompleted.where((m) {
        if (m.completedAt == null) return false;
        return formatDate(m.completedAt!) == dateStr;
      }).toList();

      // Aggregate player stats
      final playerStats = <String, _PlayerDailyAccumulator>{};

      for (final m in dailyMatches) {
        final p1 = m.player1Id;
        final p2 = m.player2Id;

        final acc1 = playerStats.putIfAbsent(
          p1,
          () => _PlayerDailyAccumulator(p1),
        );
        acc1.trianglesCaptured += m.player1Score;

        if (m.isDraw) {
          acc1.draws++;
        } else if (m.winnerId == p1) {
          acc1.wins++;
        } else {
          acc1.losses++;
        }

        if (p2 != null) {
          final acc2 = playerStats.putIfAbsent(
            p2,
            () => _PlayerDailyAccumulator(p2),
          );
          acc2.trianglesCaptured += m.player2Score;
          if (m.isDraw) {
            acc2.draws++;
          } else if (m.winnerId == p2) {
            acc2.wins++;
          } else {
            acc2.losses++;
          }
        }
      }

      // Fetch player display names
      final profiles = await PlayerProfile.db.find(session);
      final profileMap = {for (final p in profiles) p.playerId: p.displayName};

      // Sort players by wins descending, then triangles captured descending
      final sortedAccumulators = playerStats.values.toList()
        ..sort((a, b) {
          if (b.wins != a.wins) return b.wins.compareTo(a.wins);
          return b.trianglesCaptured.compareTo(a.trianglesCaptured);
        });

      // 4. Idempotently write to daily_leaderboard table:
      // Remove existing records for this target date first so reruns are cleanly idempotent!
      await session.db.transaction((tx) async {
        final existingRows = await DailyLeaderboard.db.find(
          session,
          where: (t) => t.dateString.equals(dateStr),
          transaction: tx,
        );
        for (final row in existingRows) {
          await DailyLeaderboard.db.deleteRow(session, row, transaction: tx);
        }

        int rank = 1;
        for (final acc in sortedAccumulators) {
          final totalGames = acc.wins + acc.losses + acc.draws;
          final winRate = totalGames > 0
              ? (acc.wins / totalGames) * 100.0
              : 0.0;
          final name =
              profileMap[acc.playerId] ??
              'Player_${acc.playerId.substring(0, acc.playerId.length > 5 ? 5 : acc.playerId.length)}';

          final entry = DailyLeaderboard(
            dateString: dateStr,
            playerId: acc.playerId,
            displayName: name,
            wins: acc.wins,
            losses: acc.losses,
            draws: acc.draws,
            trianglesCaptured: acc.trianglesCaptured,
            rank: rank++,
            winRate: winRate,
            updatedAt: startTime,
          );

          await DailyLeaderboard.db.insertRow(session, entry, transaction: tx);
          leaderboardsCount++;
        }
      });

      // 5. Record audit log
      final log = ScheduledJobLog(
        jobName: 'daily_maintenance',
        executedAt: startTime,
        targetDate: dateStr,
        staleLobbiesCleaned: staleLobbiesCount,
        abandonedMatchesProcessed: abandonedMatchesCount,
        leaderboardsAggregated: leaderboardsCount,
        success: true,
        errorDetails: null,
      );

      return await ScheduledJobLog.db.insertRow(session, log);
    } catch (e, stack) {
      final failedLog = ScheduledJobLog(
        jobName: 'daily_maintenance',
        executedAt: startTime,
        targetDate: dateStr,
        staleLobbiesCleaned: staleLobbiesCount,
        abandonedMatchesProcessed: abandonedMatchesCount,
        leaderboardsAggregated: leaderboardsCount,
        success: false,
        errorDetails: '$e\n$stack',
      );
      return await ScheduledJobLog.db.insertRow(session, failedLog);
    }
  }
}

class _PlayerDailyAccumulator {
  final String playerId;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int trianglesCaptured = 0;

  _PlayerDailyAccumulator(this.playerId);
}
