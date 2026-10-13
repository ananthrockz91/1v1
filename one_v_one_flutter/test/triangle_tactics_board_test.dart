import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_core/game_core.dart';
import 'package:one_v_one_flutter/widgets/triangle_tactics_board.dart';

void main() {
  group('TriangleTacticsBoard Widget Tests', () {
    late TriangleTacticsState initialState;

    setUp(() {
      initialState = TriangleTacticsState.initial(
        player1Id: 'p1',
        player2Id: 'p2',
        boardSize: 3,
      );
    });

    testWidgets('renders CustomPaint with TriangleBoardPainter and nodes', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: TriangleTacticsBoard(
                    state: initialState,
                    currentUserId: 'p1',
                    isInteractive: true,
                    onMoveSubmitted: (n1, n2) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify CustomPaint is rendered
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(TriangleTacticsBoard), findsOneWidget);
    });

    testWidgets('tap interaction triggers onMoveSubmitted between adjacent nodes', (
      tester,
    ) async {
      GridNode? submittedN1;
      GridNode? submittedN2;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: TriangleTacticsBoard(
                    state: initialState,
                    currentUserId: 'p1',
                    isInteractive: true,
                    onMoveSubmitted: (n1, n2) {
                      submittedN1 = n1;
                      submittedN2 = n2;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Node (0,0) is at top-center
      // Node (1,0) is below to the left
      // In 300x300, boardSize = 3, (row 0, col 0) is around x = 150, y = margin + pegRadius
      // We can find the center of the widget and tap
      final boardFinder = find.byType(TriangleTacticsBoard);
      final boardTopLeft = tester.getTopLeft(boardFinder);

      // Node (0,0): row = 0, col = 0
      // dx = 30 + (300 - 60) * (3 - 0) / 6 + 0 * spacingX = 30 + 240 * 0.5 = 150
      // dy = 30 + 0 * spacingY = 30
      final n0Pos = boardTopLeft + const Offset(150, 30);

      // Tap on node (0,0)
      await tester.tapAt(n0Pos);
      await tester.pump();

      // Node (1,0): row = 1, col = 0
      // rowOffset = (3-1)/6 * 240 = 2/6 * 240 = 80
      // dx = 30 + 80 = 110
      // dy = 30 + 1 * (240 / 3) = 110
      final n1Pos = boardTopLeft + const Offset(110, 110);

      // Tap on node (1,0)
      await tester.tapAt(n1Pos);
      await tester.pump();

      expect(submittedN1, isNotNull);
      expect(submittedN2, isNotNull);
      expect(submittedN1, equals(const GridNode(0, 0)));
      expect(submittedN2, equals(const GridNode(1, 0)));
    });

    testWidgets('non-interactive board ignores tap gestures', (tester) async {
      GridNode? submittedN1;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: TriangleTacticsBoard(
                    state: initialState,
                    currentUserId: 'p1',
                    isInteractive: false,
                    onMoveSubmitted: (n1, n2) {
                      submittedN1 = n1;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final boardFinder = find.byType(TriangleTacticsBoard);
      final boardTopLeft = tester.getTopLeft(boardFinder);
      final n0Pos = boardTopLeft + const Offset(150, 30);

      await tester.tapAt(n0Pos);
      await tester.pump();

      final n1Pos = boardTopLeft + const Offset(110, 110);
      await tester.tapAt(n1Pos);
      await tester.pump();

      expect(submittedN1, isNull);
    });

    testWidgets(
      'drag and connect gesture submits move between adjacent nodes',
      (
        tester,
      ) async {
        GridNode? submittedN1;
        GridNode? submittedN2;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: TriangleTacticsBoard(
                      state: initialState,
                      currentUserId: 'p1',
                      isInteractive: true,
                      onMoveSubmitted: (n1, n2) {
                        submittedN1 = n1;
                        submittedN2 = n2;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final boardFinder = find.byType(TriangleTacticsBoard);
        final boardTopLeft = tester.getTopLeft(boardFinder);
        final n0Pos = boardTopLeft + const Offset(150, 30);
        final n1Pos = boardTopLeft + const Offset(110, 110);

        // Drag from n0 to n1
        final gesture = await tester.startGesture(n0Pos);
        await tester.pump();
        await gesture.moveTo(n1Pos);
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(submittedN1, equals(const GridNode(0, 0)));
        expect(submittedN2, equals(const GridNode(1, 0)));
      },
    );

    testWidgets('drag into empty space does not submit move', (tester) async {
      GridNode? submittedN1;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: TriangleTacticsBoard(
                    state: initialState,
                    currentUserId: 'p1',
                    isInteractive: true,
                    onMoveSubmitted: (n1, n2) {
                      submittedN1 = n1;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final boardFinder = find.byType(TriangleTacticsBoard);
      final boardTopLeft = tester.getTopLeft(boardFinder);
      final n0Pos = boardTopLeft + const Offset(150, 30);
      final emptySpace = boardTopLeft + const Offset(10, 10);

      final gesture = await tester.startGesture(n0Pos);
      await tester.pump();
      await gesture.moveTo(emptySpace);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(submittedN1, isNull);
    });

    testWidgets(
      'single tap keeps node selected and does not disappear on pointer up',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: TriangleTacticsBoard(
                      state: initialState,
                      currentUserId: 'p1',
                      isInteractive: true,
                      onMoveSubmitted: (n1, n2) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final boardFinder = find.byType(TriangleTacticsBoard);
        final boardTopLeft = tester.getTopLeft(boardFinder);
        final n0Pos = boardTopLeft + const Offset(150, 30);

        // Single tap on node (0, 0)
        await tester.tapAt(n0Pos);
        await tester.pump();

        // Find the CustomPaint inside TriangleTacticsBoard
        final customPaintFinder = find.descendant(
          of: boardFinder,
          matching: find.byType(CustomPaint),
        );
        expect(customPaintFinder, findsWidgets);

        // Verify the painter has selectedNode == (0, 0) persistently
        final customPaints = tester.widgetList<CustomPaint>(customPaintFinder);
        bool foundSelectedNode = false;
        for (final cp in customPaints) {
          final painter = cp.painter;
          if (painter != null && painter.toString().contains('_BoardPainter')) {
            // Dynamic inspection of selectedNode
            dynamic dynPainter = painter;
            if (dynPainter.selectedNode == const GridNode(0, 0)) {
              foundSelectedNode = true;
              break;
            }
          }
        }
        expect(foundSelectedNode, isTrue);

        // Tap on node (0, 0) again to deselect
        await tester.tapAt(n0Pos);
        await tester.pump();

        bool stillSelected = false;
        for (final cp in tester.widgetList<CustomPaint>(customPaintFinder)) {
          final painter = cp.painter;
          if (painter != null && painter.toString().contains('_BoardPainter')) {
            dynamic dynPainter = painter;
            if (dynPainter.selectedNode != null) {
              stillSelected = true;
            }
          }
        }
        expect(stillSelected, isFalse);
      },
    );
  });
}
