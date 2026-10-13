import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/providers/player_provider.dart';
import 'package:one_v_one_flutter/screens/home_screen.dart';

class _AuthenticatedPlayerNotifier extends PlayerProfileNotifier {
  _AuthenticatedPlayerNotifier() {
    state = const PlayerProfileState(
      isAuthenticated: true,
      playerId: 'user_42',
      displayName: 'NeoChampion',
      avatarSeed: 'avatar_2',
    );
  }
}

void main() {
  testWidgets(
    'HomeScreen renders Guest indicator and hides options when not logged in',
    (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify brand header and arena selector
      expect(find.text('SELECT YOUR ARENA'), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);

      // Verify game touch points
      expect(find.text('Triangle Tactics'), findsOneWidget);
      expect(find.text('Gravity Drop Duel'), findsOneWidget);
      expect(find.text('Chroma Reversi'), findsOneWidget);
      expect(find.text('Play'), findsNWidgets(3));

      // Verify Guest mode: only Guest indicator and Sign In action are shown
      expect(find.text('Guest'), findsOneWidget);
      expect(find.byTooltip('Sign In'), findsOneWidget);

      // Verify platform options (Leaderboard & Admin Board) are hidden before login
      expect(find.byTooltip('Leaderboards'), findsNothing);
      expect(find.byTooltip('Serverpod Live Admin Board'), findsNothing);
      expect(find.text('Full Catalogue'), findsOneWidget);

      // Verify private room card
      expect(find.text('Have a Private Room Code?'), findsOneWidget);
      expect(find.text('Join Room'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen renders Leaderboard & Admin Board when authenticated',
    (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerProfileProvider.overrideWith(
              (ref) => _AuthenticatedPlayerNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify authenticated user details
      expect(find.text('NeoChampion'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);

      // Verify platform options are shown when logged in
      expect(find.byTooltip('Leaderboards'), findsOneWidget);
      expect(find.byTooltip('Serverpod Live Admin Board'), findsOneWidget);
      expect(
        find.byTooltip('Serverpod Architecture & Cloud Specs'),
        findsOneWidget,
      );
    },
  );
}
