import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/screens/connect_four_screen.dart';
import 'package:one_v_one_flutter/widgets/connect_four_board.dart';

void main() {
  testWidgets(
    'ConnectFourScreen renders presets and clean board without action bar or hazards',
    (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ConnectFourScreen(),
          ),
        ),
      );

      // Title and status
      expect(find.text('Gravity Drop Duel'), findsOneWidget);
      expect(find.text('vs AI'), findsOneWidget);
      expect(find.text('2-Player'), findsOneWidget);

      // Grid Presets
      expect(find.text('Classic 7×6'), findsOneWidget);
      expect(find.text('Tactical 8×7'), findsOneWidget);
      expect(find.text('Grand 9×8'), findsOneWidget);

      // Hazards and Action buttons removed
      expect(find.text('Hazards ON'), findsNothing);
      expect(find.text('Hazards OFF'), findsNothing);
      expect(find.text('Drop'), findsNothing);
      expect(find.text('Pop-Out'), findsNothing);
      expect(find.text('Breaker [1]'), findsNothing);

      // Board component
      expect(find.byType(ConnectFourBoard), findsOneWidget);

      // Tap Tactical 8x7 preset
      await tester.tap(find.text('Tactical 8×7'));
      await tester.pump();

      // Tap Grand 9x8 preset
      await tester.tap(find.text('Grand 9×8'));
      await tester.pump();
      expect(find.text('Grand 9×8'), findsOneWidget);
    },
  );
}
