import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/widgets/game_rules_dialog.dart';

void main() {
  testWidgets('GameRulesDialog renders overview and tabs properly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => GameRulesDialog.show(context),
              child: const Text('Open Rules'),
            ),
          ),
        ),
      ),
    );

    // Open the rules dialog
    await tester.tap(find.text('Open Rules'));
    await tester.pumpAndSettle();

    // Verify dialog header
    expect(find.text('How to Play Triangle Tactics'), findsOneWidget);
    expect(find.text('Game Rules, Controls & Strategy Guide'), findsOneWidget);

    // Verify overview tab content
    expect(find.text('The Goal: Conquer More Triangles'), findsOneWidget);
    expect(find.text('QUICK RULES AT A GLANCE'), findsOneWidget);

    // Switch to Bands tab
    await tester.tap(find.text('Bands'));
    await tester.pumpAndSettle();
    expect(find.text('The 4-Peg Straight Line Rule'), findsOneWidget);
    expect(find.text('Option A: Drag & Snap'), findsOneWidget);

    // Switch to Conquering tab
    await tester.tap(find.text('Conquering'));
    await tester.pumpAndSettle();
    expect(find.text('Conquering & 3D Pegs'), findsOneWidget);
    expect(find.text('Territory Claim & Colored Token'), findsOneWidget);

    // Switch to Strategy tab
    await tester.tap(find.text('Strategy'));
    await tester.pumpAndSettle();
    expect(find.text('In-Game Tactical Threat Radar'), findsOneWidget);
    expect(
      find.text('Glowing Player Color (Victory Capture)'),
      findsOneWidget,
    );

    // Tap footer action button to close
    await tester.tap(find.text('Got It, Let\'s Play!'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.text('How to Play Triangle Tactics'), findsNothing);
  });
}
