import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import '../generated/protocol.dart';

class PlayerService {
  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static Future<PlayerProfile> getOrCreateProfile(
    Session session, {
    required String playerId,
    String? displayName,
    String? avatarSeed,
    Transaction? transaction,
  }) async {
    String? resolvedName = displayName;

    // If displayName is null or a generic fallback, try to resolve the email prefix
    // Only query EmailAccount if playerId is a valid UUID string to prevent PostgreSQL type errors
    if ((resolvedName == null ||
            resolvedName.startsWith('Player_') ||
            resolvedName.startsWith('Guest_')) &&
        _uuidRegex.hasMatch(playerId)) {
      try {
        final uuid = UuidValue.fromString(playerId);
        // Run outside the caller transaction to avoid aborting tx on any lookup failure
        final emailAccount = await EmailAccount.db.findFirstRow(
          session,
          where: (t) => t.authUserId.equals(uuid),
        );
        if (emailAccount != null && emailAccount.email.contains('@')) {
          final prefix = emailAccount.email.split('@').first;
          if (prefix.isNotEmpty) {
            resolvedName = prefix;
          }
        }
      } catch (_) {}
    }

    final existing = await PlayerProfile.db.findFirstRow(
      session,
      where: (t) => t.playerId.equals(playerId),
      transaction: transaction,
    );

    if (existing != null) {
      existing.lastActiveAt = DateTime.now();

      final isExistingGeneric =
          existing.displayName.startsWith('Player_') ||
          existing.displayName.startsWith('Guest_') ||
          existing.displayName.isEmpty;

      if (resolvedName != null &&
          resolvedName.isNotEmpty &&
          !resolvedName.startsWith('Player_') &&
          !resolvedName.startsWith('Guest_')) {
        existing.displayName = resolvedName;
      } else if (isExistingGeneric &&
          resolvedName != null &&
          resolvedName.isNotEmpty) {
        existing.displayName = resolvedName;
      }

      if (avatarSeed != null && avatarSeed.isNotEmpty) {
        existing.avatarSeed = avatarSeed;
      }

      return await PlayerProfile.db.updateRow(
        session,
        existing,
        transaction: transaction,
      );
    }

    final newProfile = PlayerProfile(
      playerId: playerId,
      displayName: (resolvedName != null && resolvedName.isNotEmpty)
          ? resolvedName
          : 'Player_${playerId.substring(0, playerId.length > 5 ? 5 : playerId.length)}',
      avatarSeed: (avatarSeed != null && avatarSeed.isNotEmpty)
          ? avatarSeed
          : 'avatar_1',
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

  static Future<PlayerProfile> updateProfile(
    Session session, {
    required String playerId,
    String? displayName,
    String? avatarSeed,
    Transaction? transaction,
  }) async {
    return await getOrCreateProfile(
      session,
      playerId: playerId,
      displayName: displayName,
      avatarSeed: avatarSeed,
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
    try {
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
    } catch (e, st) {
      session.log(
        'Failed to record match result for $playerId: $e',
        level: LogLevel.warning,
        stackTrace: st,
      );
    }
  }
}
