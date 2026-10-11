import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PlayerService {
  static Future<PlayerProfile> getOrCreateProfile(
    Session session, {
    required String playerId,
    String? displayName,
    Transaction? transaction,
  }) async {
    final existing = await PlayerProfile.db.findFirstRow(
      session,
      where: (t) => t.playerId.equals(playerId),
      transaction: transaction,
    );

    if (existing != null) {
      existing.lastActiveAt = DateTime.now();
      if (displayName != null && displayName.isNotEmpty) {
        existing.displayName = displayName;
      }
      return await PlayerProfile.db.updateRow(
        session,
        existing,
        transaction: transaction,
      );
    }

    final newProfile = PlayerProfile(
      playerId: playerId,
      displayName:
          displayName ??
          'Player_${playerId.substring(0, playerId.length > 5 ? 5 : playerId.length)}',
      avatarSeed: playerId,
      totalMatches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      trianglesCaptured: 0,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    return await PlayerProfile.db.insertRow(
      session,
      newProfile,
      transaction: transaction,
    );
  }

  static Future<void> recordMatchResult(
    Session session, {
    required String playerId,
    required bool isWin,
    required bool isLoss,
    required bool isDraw,
    required int trianglesCaptured,
    Transaction? transaction,
  }) async {
    final profile = await getOrCreateProfile(
      session,
      playerId: playerId,
      transaction: transaction,
    );

    profile.totalMatches += 1;
    if (isWin) profile.wins += 1;
    if (isLoss) profile.losses += 1;
    if (isDraw) profile.draws += 1;
    profile.trianglesCaptured += trianglesCaptured;
    profile.lastActiveAt = DateTime.now();

    await PlayerProfile.db.updateRow(
      session,
      profile,
      transaction: transaction,
    );
  }
}
