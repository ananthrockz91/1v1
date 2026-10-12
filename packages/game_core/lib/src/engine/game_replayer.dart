import 'move_result.dart';
import 'triangle_tactics_engine.dart';
import 'triangle_tactics_move.dart';
import 'triangle_tactics_state.dart';

class ReplayResult {
  final bool isSuccess;
  final TriangleTacticsState? finalState;
  final String? error;

  const ReplayResult.success(this.finalState) : isSuccess = true, error = null;

  const ReplayResult.failure(this.error) : isSuccess = false, finalState = null;
}

/// Deterministically replays a complete match from its historical MoveRecords
/// to audit and verify that every state transition was legal and produces
/// the exact stored authoritative state.
class GameReplayer {
  static ReplayResult replay(TriangleTacticsState targetState) {
    if (targetState.moveHistory.isEmpty) {
      return ReplayResult.success(targetState);
    }

    final engine = TriangleTacticsEngine();
    final firstMove = targetState.moveHistory.first;

    var current = TriangleTacticsState.initial(
      player1Id: targetState.player1Id,
      player2Id: targetState.player2Id,
      boardSize: targetState.boardSize,
      boardShape: targetState.boardShape,
      startingPlayerId: firstMove.playerId,
    );

    for (int i = 0; i < targetState.moveHistory.length; i++) {
      final record = targetState.moveHistory[i];
      final move = TriangleTacticsMove(
        node1: record.node1,
        node2: record.node2,
      );

      final result = engine.applyMove(current, record.playerId, move);

      if (result is MoveRejected) {
        return ReplayResult.failure(
          'Replay rejected at step $i (${record.edgeId}): ${result.violation.message}',
        );
      }

      final accepted = result as MoveAccepted;

      // Invariant: replayed claims and extra turn must match stored record
      if (accepted.newlyClaimedTriangles.length !=
              record.claimedTriangles.length ||
          !accepted.newlyClaimedTriangles.toSet().containsAll(
            record.claimedTriangles,
          )) {
        return ReplayResult.failure(
          'Replay claim mismatch at step $i: replayed=${accepted.newlyClaimedTriangles}, stored=${record.claimedTriangles}',
        );
      }

      if (accepted.extraTurnAwarded != record.extraTurn) {
        return ReplayResult.failure(
          'Replay extraTurn mismatch at step $i: replayed=${accepted.extraTurnAwarded}, stored=${record.extraTurn}',
        );
      }

      current = accepted.nextState;
    }

    // Verify final state matches targetState
    if (current.player1Score != targetState.player1Score ||
        current.player2Score != targetState.player2Score ||
        current.isTerminal != targetState.isTerminal ||
        current.winnerId != targetState.winnerId ||
        current.isDraw != targetState.isDraw ||
        current.occupiedEdges.length != targetState.occupiedEdges.length ||
        current.claimedTriangles.length !=
            targetState.claimedTriangles.length) {
      return ReplayResult.failure(
        'Replay final state does not match target state. '
        'Scores: replayed=(${current.player1Score}, ${current.player2Score}) vs target=(${targetState.player1Score}, ${targetState.player2Score}). '
        'Terminal: ${current.isTerminal} vs ${targetState.isTerminal}. '
        'Winner: ${current.winnerId} vs ${targetState.winnerId}.',
      );
    }

    return ReplayResult.success(current);
  }
}
