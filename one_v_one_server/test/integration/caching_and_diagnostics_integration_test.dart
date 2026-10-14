import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Suite I: Server Caching, Cloud Storage & Diagnostics', (
    sessionBuilder,
    endpoints,
  ) {
    test('player profile caching and cache invalidation on update', () async {
      const testPlayerId = 'caching_test_user_1';

      // 1. Initial creation
      final created = await endpoints.player.getOrCreateProfile(
        sessionBuilder,
        playerId: testPlayerId,
        displayName: 'CachedPlayer',
        avatarSeed: 'avatar_1',
      );
      expect(created.displayName, equals('CachedPlayer'));

      // 2. Read through cached getProfile
      final fetched = await endpoints.player.getProfile(
        sessionBuilder,
        testPlayerId,
      );
      expect(fetched, isNotNull);
      expect(fetched!.displayName, equals('CachedPlayer'));

      // 3. Update profile invalidates and updates cache
      final updated = await endpoints.player.updateProfile(
        sessionBuilder,
        playerId: testPlayerId,
        displayName: 'UpdatedCachedPlayer',
        avatarSeed: 'avatar_3',
      );
      expect(updated.displayName, equals('UpdatedCachedPlayer'));

      // 4. Subsequent read returns updated profile
      final reFetched = await endpoints.player.getProfile(
        sessionBuilder,
        testPlayerId,
      );
      expect(reFetched, isNotNull);
      expect(reFetched!.displayName, equals('UpdatedCachedPlayer'));
    });

    test('profile custom avatar (data URI) persists across reload', () async {
      const testPlayerId = 'avatar_persistence_user';
      const customAvatar =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      // 1. Initial creation
      await endpoints.player.getOrCreateProfile(
        sessionBuilder,
        playerId: testPlayerId,
        displayName: 'AvatarPlayer',
        avatarSeed: 'avatar_1',
      );

      // 2. User updates their profile picture with a custom image
      final updated = await endpoints.player.updateProfile(
        sessionBuilder,
        playerId: testPlayerId,
        avatarSeed: customAvatar,
      );
      expect(updated.avatarSeed, equals(customAvatar));

      // 3. Simulating browser reload: getOrCreateProfile called with no avatarSeed
      final reloaded = await endpoints.player.getOrCreateProfile(
        sessionBuilder,
        playerId: testPlayerId,
      );
      expect(reloaded.avatarSeed, equals(customAvatar));

      // 4. getProfile also returns the custom avatar
      final fetched = await endpoints.player.getProfile(
        sessionBuilder,
        testPlayerId,
      );
      expect(fetched?.avatarSeed, equals(customAvatar));
    });

    test('leaderboard caching and clearCaches administrative tool', () async {
      // 1. Fetch daily leaderboard (warms cache)
      final daily = await endpoints.leaderboard.getDailyLeaderboard(
        sessionBuilder,
        dateString: '2026-10-12',
        limit: 10,
      );
      expect(daily, isNotNull);

      // 2. Fetch all-time leaderboard (warms cache)
      final allTime = await endpoints.leaderboard.getAllTimeLeaderboard(
        sessionBuilder,
        limit: 10,
      );
      expect(allTime, isNotNull);

      // 3. Clear cache via admin endpoint
      final clearSuccess = await endpoints.admin.clearCaches(sessionBuilder);
      expect(clearSuccess, isTrue);

      // 4. Reading after cache clear repopulates gracefully
      final postClearDaily = await endpoints.leaderboard.getDailyLeaderboard(
        sessionBuilder,
        dateString: '2026-10-12',
        limit: 10,
      );
      expect(postClearDaily, isNotNull);
    });

    test('getAvatarUploadDescription generates upload description', () async {
      const testPlayerId = 'avatar_upload_test_user';
      final uploadDesc = await endpoints.player.getAvatarUploadDescription(
        sessionBuilder,
        playerId: testPlayerId,
      );

      // Should return a valid upload description string containing endpoint/URL info
      expect(uploadDesc, isNotNull);
      expect(uploadDesc, contains(testPlayerId));
    });

    test(
      'getDashboardData returns live system, database, and cache metrics',
      () async {
        final overview = await endpoints.admin.getDashboardData(sessionBuilder);

        expect(overview.serverId, isNotEmpty);
        expect(overview.runMode, equals('test'));
        expect(overview.dbLatencyMs, greaterThanOrEqualTo(0));
        expect(overview.totalMatches, greaterThanOrEqualTo(0));
        expect(overview.totalPlayers, greaterThanOrEqualTo(0));
        expect(overview.localCacheEntries, greaterThanOrEqualTo(0));
        expect(overview.recentMatches, isA<List>());
        expect(overview.recentJobLogs, isA<List>());
        expect(overview.recentPlayers, isA<List>());
      },
    );
  });
}
