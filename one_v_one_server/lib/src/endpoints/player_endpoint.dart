import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/player_service.dart';

class PlayerEndpoint extends Endpoint {
  /// Fetches an existing player profile or creates one if it doesn't exist.
  Future<PlayerProfile> getOrCreateProfile(
    Session session, {
    required String playerId,
    String? displayName,
  }) async {
    return await PlayerService.getOrCreateProfile(
      session,
      playerId: playerId,
      displayName: displayName,
    );
  }

  /// Fetches a player profile.
  Future<PlayerProfile?> getProfile(
    Session session,
    String playerId,
  ) async {
    return await PlayerProfile.db.findFirstRow(
      session,
      where: (t) => t.playerId.equals(playerId),
    );
  }
}
