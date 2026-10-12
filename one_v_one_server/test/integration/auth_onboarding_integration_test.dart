import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Suite H: Player Onboarding & Profile Lifecycle',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      setUpAll(() {
        Serverpod.instance.initializeAuthServices(
          tokenManagerBuilders: [
            JwtConfigFromPasswords(),
          ],
          identityProviderBuilders: [
            EmailIdpConfigFromPasswords(
              registrationVerificationCodeGenerator: () => '1234',
              passwordResetVerificationCodeGenerator: () => '1234',
            ),
          ],
        );
      });

      test('creates new guest player profile with default stats', () async {
        final profile = await endpoints.player.getOrCreateProfile(
          sessionBuilder,
          playerId: 'guest_test_999',
          displayName: 'ApexTactician',
        );

        expect(profile.playerId, equals('guest_test_999'));
        expect(profile.displayName, equals('ApexTactician'));
        expect(profile.totalMatches, equals(0));
        expect(profile.wins, equals(0));
        expect(profile.losses, equals(0));
        expect(profile.trianglesCaptured, equals(0));
      });

      test(
        'updates display name / callsign for existing player profile',
        () async {
          await endpoints.player.getOrCreateProfile(
            sessionBuilder,
            playerId: 'guest_update_123',
            displayName: 'InitialName',
          );

          final updated = await endpoints.player.getOrCreateProfile(
            sessionBuilder,
            playerId: 'guest_update_123',
            displayName: 'CommanderPrime',
          );

          expect(updated.playerId, equals('guest_update_123'));
          expect(updated.displayName, equals('CommanderPrime'));
        },
      );

      test('fetches existing profile via getProfile', () async {
        await endpoints.player.getOrCreateProfile(
          sessionBuilder,
          playerId: 'fetch_target_456',
          displayName: 'TargetPlayer',
        );

        final fetched = await endpoints.player.getProfile(
          sessionBuilder,
          'fetch_target_456',
        );

        expect(fetched, isNotNull);
        expect(fetched!.displayName, equals('TargetPlayer'));
      });

      test(
        'startRegistration and verify with default code 1234 succeeds',
        () async {
          final reqId = await endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: 'cadet_onboarding@1v1.game',
          );

          expect(reqId, isNotNull);

          final token = await endpoints.emailIdp.verifyRegistrationCode(
            sessionBuilder,
            accountRequestId: reqId,
            verificationCode: '1234',
          );

          expect(token, isNotEmpty);
        },
      );

      test('registered email user gets email prefix as displayName', () async {
        final reqId = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: 'shadow_ninja99@1v1.game',
        );
        final token = await endpoints.emailIdp.verifyRegistrationCode(
          sessionBuilder,
          accountRequestId: reqId,
          verificationCode: '1234',
        );
        final authSuccess = await endpoints.emailIdp.finishRegistration(
          sessionBuilder,
          registrationToken: token,
          password: 'Password123!',
        );

        final profile = await endpoints.player.getOrCreateProfile(
          sessionBuilder,
          playerId: authSuccess.authUserId.toString(),
          displayName: 'Player_01a12f',
        );
        expect(profile.displayName, equals('shadow_ninja99'));

        final refreshed = await endpoints.player.getOrCreateProfile(
          sessionBuilder,
          playerId: authSuccess.authUserId.toString(),
          displayName: 'Player_01a12f',
        );
        expect(refreshed.displayName, equals('shadow_ninja99'));
      });
    },
  );
}
