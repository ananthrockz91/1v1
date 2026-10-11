import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders platform navigation and action cards', (
    tester,
  ) async {
    // Provide a larger screen size so the entire scrollable home screen layout fits without overflow
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

    // Verify brand header
    expect(find.text('PLAY. COMPETE. WIN.'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);

    // Verify main action buttons
    expect(find.text('Play Online (Quick Match)'), findsOneWidget);
    expect(find.text('Create Room'), findsOneWidget);
    expect(find.text('Join Room'), findsOneWidget);

    // Verify list tiles and actions
    expect(find.byTooltip('Leaderboards'), findsOneWidget);
    expect(find.text('Game Catalogue'), findsOneWidget);

    // Verify hackathon demo controls banner
    expect(find.text('HACKATHON DEMO CONTROLS'), findsOneWidget);
  });
}
