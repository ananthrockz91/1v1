import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/screens/game_catalogue_screen.dart';

void main() {
  testWidgets('GameCatalogueScreen displays active and upcoming game titles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GameCatalogueScreen(),
        ),
      ),
    );

    // Verify title and categories
    expect(find.text('Game Catalogue'), findsOneWidget);
    expect(find.text('ACTIVE TITLES'), findsOneWidget);
    expect(
      find.text('COMING SOON'),
      findsNWidgets(4),
    ); // 1 section header + 3 game badges

    // Verify Triangle Tactics playable card
    expect(find.text('Triangle Tactics'), findsOneWidget);
    expect(find.text('PLAYABLE NOW'), findsOneWidget);

    // Verify future titles
    expect(find.text('Tic-Tac-Toe Duel'), findsOneWidget);
    expect(find.text('Connect Four'), findsOneWidget);
    expect(find.text('Memory Duel'), findsOneWidget);
  });
}
