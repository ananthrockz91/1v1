import 'dart:math';
import 'package:game_core/game_core.dart';

class SimulationResult {
  final bool success;
  final int matchesCompleted;
  final int totalMovesPlayed;
  final int? failureSeed;
  final String? failureMessage;

  const SimulationResult({
    required this.success,
    required this.matchesCompleted,
    required this.totalMovesPlayed,
    this.failureSeed,
    this.failureMessage,
  });

  @override
  String toString() => success
      ? 'Simulation SUCCESS: $matchesCompleted matches, $totalMovesPlayed moves'
      : 'Simulation FAILED at seed $failureSeed: $failureMessage';
}

/// Seeded property-based simulator that generates hundreds of random legal matches,
/// injects negative test moves, and verifies state invariants at every transition.
class RandomMatchSimulator {
  static SimulationResult run({
    required int matchCount,
    required int initialSeed,
    int boardSize = 3,
    bool injectInvalidMoves = true,
  }) {
    final engine = TriangleTacticsEngine();
    final geometry = engine.getGeometry(boardSize);
    int totalMoves = 0;

    for (int m = 0; m < matchCount; m++) {
      final matchSeed = initialSeed + m * 997;
      final rng = Random(matchSeed);

      var state = TriangleTacticsState.initial(
        player1Id: 'player_1',
        player2Id: 'player_2',
        boardSize: boardSize,
      );

      while (!state.isTerminal) {
        final activePlayer = state.activePlayerId;
        final opponent = state.opponentOf(activePlayer);

        // Optionally test negative invariant: out-of-turn submission must be rejected
        // and leave state completely unmutated.
        if (injectInvalidMoves && rng.nextDouble() < 0.2) {
          final legalMoves = engine.getLegalMoves(state);
          if (legalMoves.isNotEmpty) {
            final invalidMove = legalMoves.first;
            final rejected = engine.applyMove(state, opponent, invalidMove);
            if (rejected is! MoveRejected ||
                rejected.violation.type != RuleViolationType.notYourTurn) {
              return SimulationResult(
                success: false,
                matchesCompleted: m,
                totalMovesPlayed: totalMoves,
                failureSeed: matchSeed,
                failureMessage:
                    'Failed to reject out-of-turn move: got $rejected',
              );
            }
          }
        }

        final legalMoves = engine.getLegalMoves(state);
        if (legalMoves.isEmpty) {
          return SimulationResult(
            success: false,
            matchesCompleted: m,
            totalMovesPlayed: totalMoves,
            failureSeed: matchSeed,
            failureMessage: 'No legal moves found in non-terminal state',
          );
        }

        final move = legalMoves[rng.nextInt(legalMoves.length)];
        final result = engine.applyMove(state, activePlayer, move);

        if (result is! MoveAccepted) {
          return SimulationResult(
            success: false,
            matchesCompleted: m,
            totalMovesPlayed: totalMoves,
            failureSeed: matchSeed,
            failureMessage:
                'Legal move $move was unexpectedly rejected: ${(result as MoveRejected).violation.message}',
          );
        }

        state = result.nextState;
        totalMoves++;

        // Verify invariants on state
        final validation = StateValidator.validate(
          state,
          geometry,
          verifyReplay: false,
        );
        if (!validation.isValid) {
          return SimulationResult(
            success: false,
            matchesCompleted: m,
            totalMovesPlayed: totalMoves,
            failureSeed: matchSeed,
            failureMessage:
                'State invariant violation: ${validation.violations.join("; ")}',
          );
        }
      }

      // Terminal state validation with full replay
      final terminalValidation = StateValidator.validate(
        state,
        geometry,
        verifyReplay: true,
      );
      if (!terminalValidation.isValid) {
        return SimulationResult(
          success: false,
          matchesCompleted: m,
          totalMovesPlayed: totalMoves,
          failureSeed: matchSeed,
          failureMessage:
              'Terminal state invariant violation: ${terminalValidation.violations.join("; ")}',
        );
      }
    }

    return SimulationResult(
      success: true,
      matchesCompleted: matchCount,
      totalMovesPlayed: totalMoves,
    );
  }
}
