import 'package:game_core/game_core.dart';

/// Intelligent AI player for Triggle & Triangle Tactics with multi-level tactical heuristics.
class TacticalBot {
  /// Evaluates the board state and returns the optimal move for [botPlayerId].
  static TriangleTacticsMove? selectBestMove({
    required TriangleTacticsState state,
    required String botPlayerId,
  }) {
    final engine = TriangleTacticsEngine();
    final legalMoves = engine.getLegalMoves(state);

    if (legalMoves.isEmpty) return null;

    final geometry = engine.getGeometry(state.boardSize, state.boardShape);

    TriangleTacticsMove? bestMove;
    int bestScore = -999999;

    for (final move in legalMoves) {
      final result = engine.applyMove(state, botPlayerId, move);
      if (result is! MoveAccepted) continue;

      int score = 0;
      final completed = result.newlyClaimedTriangles.length;

      // 1. Massive reward for completing triangles (and earning extra turns)
      if (completed > 0) {
        score += completed * 500;
        // Bonus for chain reaction extra turn
        score += 200;
      } else {
        // 2. Penalty if this move leaves any uncompleted triangle with 2 edges occupied
        // (which gives the opponent an easy immediate capture)
        int threatsCreated = 0;
        final nextEdges = result.nextState.occupiedEdges;

        for (final tri in geometry.triangles) {
          if (!result.nextState.claimedTriangles.containsKey(tri.id)) {
            int occupiedCount = 0;
            for (final edgeId in tri.edgeIds) {
              if (nextEdges.contains(edgeId)) {
                occupiedCount++;
              }
            }
            if (occupiedCount == 2) {
              threatsCreated++;
            }
          }
        }

        // Heavy penalty for gifting captures to opponent
        score -= threatsCreated * 150;

        // Slight bonus for moves near the center of the board
        final pos1 = geometry.nodePositions[move.node1.id];
        final pos2 = geometry.nodePositions[move.node2.id];
        if (pos1 != null && pos2 != null) {
          final avgDist =
              (pos1.distanceTo(const LatticePoint(0, 0)) +
                  pos2.distanceTo(const LatticePoint(0, 0))) /
              2.0;
          score += (10 - avgDist.round() * 2);
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? legalMoves.first;
  }
}
