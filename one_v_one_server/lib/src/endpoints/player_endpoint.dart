import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/player_service.dart';

class PlayerEndpoint extends Endpoint {
  /// Fetches an existing player profile or creates one if it doesn't exist.
  Future<PlayerProfile> getOrCreateProfile(
    Session session, {
    required String playerId,
    String? displayName,
    String? avatarSeed,
  }) async {
    final profile = await PlayerService.getOrCreateProfile(
      session,
      playerId: playerId,
      displayName: displayName,
      avatarSeed: avatarSeed,
    );
    try {
      await session.caches.local.put(
        'PlayerProfile-$playerId',
        profile,
        lifetime: const Duration(minutes: 5),
        group: 'profiles',
      );
    } catch (_) {}
    return profile;
  }

  /// Updates player profile (displayName and avatarSeed) and refreshes cache.
  Future<PlayerProfile> updateProfile(
    Session session, {
    required String playerId,
    String? displayName,
    String? avatarSeed,
  }) async {
    final updated = await PlayerService.updateProfile(
      session,
      playerId: playerId,
      displayName: displayName,
      avatarSeed: avatarSeed,
    );
    try {
      await session.caches.local.invalidateKey('PlayerProfile-$playerId');
      await session.caches.local.put(
        'PlayerProfile-$playerId',
        updated,
        lifetime: const Duration(minutes: 5),
        group: 'profiles',
      );
    } catch (_) {}
    return updated;
  }

  /// Fetches a player profile using fast local in-memory caching.
  Future<PlayerProfile?> getProfile(
    Session session,
    String playerId,
  ) async {
    try {
      final cached = await session.caches.local.get<PlayerProfile>(
        'PlayerProfile-$playerId',
      );
      if (cached != null) return cached;
    } catch (_) {}

    final profile = await PlayerService.getOrCreateProfile(
      session,
      playerId: playerId,
    );
    try {
      await session.caches.local.put(
        'PlayerProfile-$playerId',
        profile,
        lifetime: const Duration(minutes: 5),
        group: 'profiles',
      );
    } catch (_) {}
    return profile;
  }

  /// Generates a Serverpod Cloud Storage direct upload description for avatar photos.
  Future<String?> getAvatarUploadDescription(
    Session session, {
    required String playerId,
  }) async {
    final path = 'avatars/$playerId.png';
    return await session.storage.createUploadDescription(
      storageId: 'public',
      path: path,
    );
  }

  /// Verifies an uploaded avatar file in Cloud Storage, persists its public URL, and invalidates cache.
  Future<PlayerProfile?> verifyAvatarUpload(
    Session session, {
    required String playerId,
  }) async {
    final path = 'avatars/$playerId.png';
    final verified = await session.storage.verifyUpload(
      storageId: 'public',
      path: path,
    );
    if (!verified) return null;

    final publicUrl = await session.storage.publicDownloadUrl(
      storageId: 'public',
      path: path,
    );

    return await updateProfile(
      session,
      playerId: playerId,
      avatarSeed: publicUrl.toString(),
    );
  }
}
