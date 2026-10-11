import 'package:game_core/game_core.dart';

/// Pre-baked, deterministic scenarios for critical gameplay mechanics
/// as mandated by the release validation requirements.
class ReferenceScenarios {
  /// Scenario 1: Quiet move that completes 0 triangles -> Turn switches to opponent.
  static void runQuietMoveScenario() {
    final engine = TriangleTacticsEngine();
    final initial = TriangleTacticsState.initial(
      player1Id: 'alice',
      player2Id: 'bob',
      boardSize: 3,
    );

    // Alice connects (0, 0) to (1, 0)
    final move = TriangleTacticsMove(
      node1: const GridNode(0, 0),
      node2: const GridNode(1, 0),
    );

    final result = engine.applyMove(initial, 'alice', move);
    if (result is! MoveAccepted) {
      throw StateError('Quiet move expected to be accepted');
    }

    if (result.extraTurnAwarded) {
      throw StateError('Quiet move should not award extra turn');
    }
    if (result.nextPlayerId != 'bob') {
      throw StateError('Turn should pass to bob');
    }
    if (result.newlyClaimedTriangles.isNotEmpty) {
      throw StateError('No triangles should be claimed');
    }
  }

  /// Scenario 2: Single triangle completion -> 1 point scored + Extra turn awarded.
  static void runSingleTriangleCompletionScenario() {
    final engine = TriangleTacticsEngine();
    var state = TriangleTacticsState.initial(
      player1Id: 'alice',
      player2Id: 'bob',
      boardSize: 3,
    );

    // Alice places (0,0)-(1,0) [down-left of tri_up_0_0] -> Turn passes to Bob
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

    // Bob places (0,0)-(1,1) [down-right of tri_up_0_0] -> Turn passes to Alice
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

    // Alice places (1,0)-(1,1) [horizontal base of tri_up_0_0]
    final result = engine.applyMove(
      state,
      'alice',
      TriangleTacticsMove(
        node1: const GridNode(1, 0),
        node2: const GridNode(1, 1),
      ),
    );

    if (result is! MoveAccepted) {
      throw StateError('Move expected to be accepted');
    }

    if (!result.extraTurnAwarded) {
      throw StateError('Completing triangle must award extra turn');
    }
    if (result.nextPlayerId != 'alice') {
      throw StateError('Alice should retain active turn');
    }
    if (result.newlyClaimedTriangles.length != 1 ||
        result.newlyClaimedTriangles.first != 'tri_up_0_0') {
      throw StateError('tri_up_0_0 must be claimed');
    }
    if (result.nextState.player1Score != 1 ||
        result.nextState.player2Score != 0) {
      throw StateError('Alice score must be 1, Bob 0');
    }
  }

  /// Scenario 3: Double triangle completion -> 2 points scored + Extra turn.
  /// On board size 3:
  /// Upright tri_up_1_0 has vertices (1,0), (2,0), (2,1) with base (2,0)-(2,1).
  /// Inverted tri_down_1_0 has vertices (1,0), (1,1), (2,1).
  /// They share edge (1,0)-(2,1) or down-right edge.
  /// Let's look at upright tri_up_1_0 and inverted tri_down_1_0:
  /// tri_up_0_0: (0,0), (1,0), (1,1). Base is (1,0)-(1,1).
  /// tri_down_1_0: (1,0), (1,1), (2,1). Top edge is (1,0)-(1,1).
  /// Thus edge (1,0)-(1,1) is shared by tri_up_0_0 (upright) and tri_down_1_0 (inverted)!
  static void runDoubleTriangleCompletionScenario() {
    final engine = TriangleTacticsEngine();
    var state = TriangleTacticsState.initial(
      player1Id: 'alice',
      player2Id: 'bob',
      boardSize: 3,
    );

    // Build the other 2 edges of tri_up_0_0:
    // 1. (0,0)-(1,0)
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

    // 2. (0,0)-(1,1)
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

    // Build the other 2 edges of tri_down_1_0:
    // tri_down_1_0 edges: (1,0)-(1,1) [shared], (1,0)-(2,1) [down-right], (1,1)-(2,1) [down-left]
    // 3. (1,0)-(2,1)
    state =
        (engine.applyMove(
                  state,
                  'alice',
                  TriangleTacticsMove(
                    node1: const GridNode(1, 0),
                    node2: const GridNode(2, 1),
                  ),
                )
                as MoveAccepted)
            .nextState;

    // 4. (1,1)-(2,1)
    state =
        (engine.applyMove(
                  state,
                  'bob',
                  TriangleTacticsMove(
                    node1: const GridNode(1, 1),
                    node2: const GridNode(2, 1),
                  ),
                )
                as MoveAccepted)
            .nextState;

    // Now it's Alice's turn. Alice places the shared edge (1,0)-(1,1)!
    final result = engine.applyMove(
      state,
      'alice',
      TriangleTacticsMove(
        node1: const GridNode(1, 0),
        node2: const GridNode(1, 1),
      ),
    );

    if (result is! MoveAccepted) {
      throw StateError('Move expected to be accepted');
    }

    if (result.newlyClaimedTriangles.length != 2) {
      throw StateError(
        'Expected 2 triangles claimed, got ${result.newlyClaimedTriangles.length}: ${result.newlyClaimedTriangles}',
      );
    }

    if (!result.extraTurnAwarded) {
      throw StateError('Extra turn must be awarded on double capture');
    }
    if (result.nextState.player1Score != 2) {
      throw StateError('Alice score must be 2 points');
    }
  }

  /// Scenario 4: Rejection of out-of-turn move.
  static void runOutOfTurnRejectionScenario() {
    final engine = TriangleTacticsEngine();
    final initial = TriangleTacticsState.initial(
      player1Id: 'alice',
      player2Id: 'bob',
      boardSize: 3,
    );

    // Bob attempts to move while Alice is active player
    final result = engine.applyMove(
      initial,
      'bob',
      TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(1, 0),
      ),
    );

    if (result is! MoveRejected ||
        result.violation.type != RuleViolationType.notYourTurn) {
      throw StateError('Expected notYourTurn violation');
    }
  }

  /// Scenario 5: Rejection of duplicate edge move.
  static void runDuplicateEdgeRejectionScenario() {
    final engine = TriangleTacticsEngine();
    final initial = TriangleTacticsState.initial(
      player1Id: 'alice',
      player2Id: 'bob',
      boardSize: 3,
    );

    final move = TriangleTacticsMove(
      node1: const GridNode(0, 0),
      node2: const GridNode(1, 0),
    );

    final accepted =
        (engine.applyMove(initial, 'alice', move) as MoveAccepted).nextState;

    // Bob tries to place the exact same edge
    final result = engine.applyMove(accepted, 'bob', move);

    if (result is! MoveRejected ||
        result.violation.type != RuleViolationType.edgeAlreadyOccupied) {
      throw StateError('Expected edgeAlreadyOccupied violation');
    }
  }
}
