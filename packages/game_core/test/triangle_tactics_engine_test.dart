import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  late TriangleTacticsEngine engine;

  setUp(() {
    engine = TriangleTacticsEngine();
  });

  group('Move Validation & Invariants', () {
    test(
      'accepts legal adjacent edge and toggles turn when no triangle completed',
      () {
        final initial = TriangleTacticsState.initial(
          player1Id: 'alice',
          player2Id: 'bob',
          boardSize: 3,
        );

        final move = TriangleTacticsMove(
          node1: const GridNode(0, 0),
          node2: const GridNode(1, 0),
        );

        final result = engine.applyMove(initial, 'alice', move);
        expect(result, isA<MoveAccepted>());

        final accepted = result as MoveAccepted;
        expect(accepted.edgeId, equals('edge_0_0_1_0'));
        expect(accepted.newlyClaimedTriangles, isEmpty);
        expect(accepted.extraTurnAwarded, isFalse);
        expect(accepted.nextPlayerId, equals('bob'));
        expect(accepted.nextState.occupiedEdges, contains('edge_0_0_1_0'));
        expect(accepted.nextState.stateVersion, equals(1));
      },
    );

    test('rejects out-of-turn moves', () {
      final state = TriangleTacticsState.initial(
        player1Id: 'alice',
        player2Id: 'bob',
        boardSize: 3,
      );

      final move = TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(1, 0),
      );

      final result = engine.applyMove(state, 'bob', move);
      expect(result, isA<MoveRejected>());
      final rejected = result as MoveRejected;
      expect(rejected.violation.type, equals(RuleViolationType.notYourTurn));
    });

    test('rejects non-adjacent nodes', () {
      final state = TriangleTacticsState.initial(
        player1Id: 'alice',
        player2Id: 'bob',
        boardSize: 3,
      );

      // (0, 0) to (2, 0) spans 2 steps
      final move = TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(2, 0),
      );

      final result = engine.applyMove(state, 'alice', move);
      expect(result, isA<MoveRejected>());
      final rejected = result as MoveRejected;
      expect(
        rejected.violation.type,
        equals(RuleViolationType.nonAdjacentNodes),
      );
    });

    test('rejects duplicate edges', () {
      final state = TriangleTacticsState.initial(
        player1Id: 'alice',
        player2Id: 'bob',
        boardSize: 3,
      );

      final move = TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(1, 0),
      );

      final state1 =
          (engine.applyMove(state, 'alice', move) as MoveAccepted).nextState;

      // Bob tries to place identical edge
      final result = engine.applyMove(state1, 'bob', move);
      expect(result, isA<MoveRejected>());
      final rejected = result as MoveRejected;
      expect(
        rejected.violation.type,
        equals(RuleViolationType.edgeAlreadyOccupied),
      );
    });

    test('awards 1 point and extra turn on single triangle completion', () {
      var state = TriangleTacticsState.initial(
        player1Id: 'alice',
        player2Id: 'bob',
        boardSize: 3,
      );

      // 1. Alice: (0,0)-(1,0)
      state =
          (engine.applyMove(
                    state,
                    'alice',
                    TriangleTacticsMove(
                      node1: const GridNode(0, 0),
                      node2: const GridNode(1, 0),
                    ),
                  )
                  as MoveAccepted)
              .nextState;

      // 2. Bob: (0,0)-(1,1)
      state =
          (engine.applyMove(
                    state,
                    'bob',
                    TriangleTacticsMove(
                      node1: const GridNode(0, 0),
                      node2: const GridNode(1, 1),
                    ),
                  )
                  as MoveAccepted)
              .nextState;

      // 3. Alice completes tri_up_0_0 via (1,0)-(1,1)
      final res = engine.applyMove(
        state,
        'alice',
        TriangleTacticsMove(
          node1: const GridNode(1, 0),
          node2: const GridNode(1, 1),
        ),
      );

      expect(res, isA<MoveAccepted>());
      final accepted = res as MoveAccepted;
      expect(accepted.newlyClaimedTriangles, equals(['tri_up_0_0']));
      expect(accepted.extraTurnAwarded, isTrue);
      expect(accepted.nextPlayerId, equals('alice'));
      expect(accepted.nextState.player1Score, equals(1));
      expect(accepted.nextState.player2Score, equals(0));
    });
  });
}
