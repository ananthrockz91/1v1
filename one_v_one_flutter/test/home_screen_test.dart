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

    // Verify brand header and arena selector
    expect(find.text('SELECT YOUR ARENA'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);

    // Verify game touch points
    expect(find.text('Triangle Tactics'), findsOneWidget);
    expect(find.text('Gravity Drop Duel'), findsOneWidget);
    expect(find.text('Chroma Reversi'), findsOneWidget);
    expect(find.text('Play'), findsNWidgets(3));

    // Verify platform actions & theme toggle
    expect(find.text('Teal Cyber'), findsOneWidget);
    expect(find.byTooltip('Leaderboards'), findsOneWidget);
    expect(find.byTooltip('Serverpod Live Admin Board'), findsOneWidget);
    expect(find.text('Full Catalogue'), findsOneWidget);

    // Verify private room card
    expect(find.text('Have a Private Room Code?'), findsOneWidget);
    expect(find.text('Join Room'), findsOneWidget);
  });
}
