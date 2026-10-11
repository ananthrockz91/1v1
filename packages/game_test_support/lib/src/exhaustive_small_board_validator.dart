import 'dart:collection';
import 'package:game_core/game_core.dart';

class ExhaustiveValidationResult {
  final bool success;
  final int uniqueStatesExplored;
  final int terminalStatesReached;
  final String? error;

  const ExhaustiveValidationResult({
    required this.success,
    required this.uniqueStatesExplored,
    required this.terminalStatesReached,
    this.error,
  });

  @override
  String toString() => success
      ? 'Exhaustive Validation SUCCESS: $uniqueStatesExplored unique states, $terminalStatesReached terminal states'
      : 'Exhaustive Validation FAILED: $error';
}

/// Exhaustively verifies the complete state space on a small board (n = 2).
/// A size 2 board has 6 nodes, 9 edges, and 4 triangles.
class ExhaustiveSmallBoardValidator {
  static ExhaustiveValidationResult run({
    int boardSize = 2,
    int maxStates = 10000,
  }) {
    final engine = TriangleTacticsEngine();
    final geometry = engine.getGeometry(boardSize);

    final initial = TriangleTacticsState.initial(
      player1Id: 'p1',
      player2Id: 'p2',
      boardSize: boardSize,
    );

    final queue = Queue<TriangleTacticsState>()..add(initial);
    final visited = <String>{};

    int statesCount = 0;
    int terminalCount = 0;

    String stateKey(TriangleTacticsState s) {
      final sortedEdges = s.occupiedEdges.toList()..sort();
      return '${s.activePlayerId}|${s.player1Score}|${s.player2Score}|${sortedEdges.join(",")}';
    }

    visited.add(stateKey(initial));

    while (queue.isNotEmpty) {
      if (statesCount >= maxStates) {
        break;
      }

      final current = queue.removeFirst();
      statesCount++;

      // Verify invariants
      final validation = StateValidator.validate(
        current,
        geometry,
        verifyReplay: true,
      );
      if (!validation.isValid) {
        return ExhaustiveValidationResult(
          success: false,
          uniqueStatesExplored: statesCount,
          terminalStatesReached: terminalCount,
          error:
              'Invariant violated in state: ${validation.violations.join("; ")}',
        );
      }

      if (current.isTerminal) {
        terminalCount++;
        continue;
      }

      final legalMoves = engine.getLegalMoves(current);
      for (final move in legalMoves) {
        final result = engine.applyMove(current, current.activePlayerId, move);
        if (result is! MoveAccepted) {
          return ExhaustiveValidationResult(
            success: false,
            uniqueStatesExplored: statesCount,
            terminalStatesReached: terminalCount,
            error:
                'Move $move was rejected in legal state: ${(result as MoveRejected).violation.message}',
          );
        }

        final key = stateKey(result.nextState);
        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(result.nextState);
        }
      }
    }

    return ExhaustiveValidationResult(
      success: true,
      uniqueStatesExplored: statesCount,
      terminalStatesReached: terminalCount,
    );
  }
}
