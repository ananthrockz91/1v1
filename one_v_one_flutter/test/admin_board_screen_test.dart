import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_v_one_flutter/screens/admin_board_screen.dart';

void main() {
  testWidgets('AdminBoardScreen renders tabs and header properly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminBoardScreen(),
        ),
      ),
    );

    // Header title check
    expect(find.text('Serverpod Command Center'), findsOneWidget);
    expect(find.text('Live Authoritative Backend Inspector'), findsOneWidget);

    // Tabs check
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Live Matches'), findsOneWidget);
    expect(find.text('Cron Logs'), findsOneWidget);
    expect(find.text('Architecture'), findsOneWidget);
  });
}
