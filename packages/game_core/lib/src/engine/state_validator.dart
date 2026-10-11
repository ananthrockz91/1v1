import '../board/board_geometry.dart';
import 'game_engine_interface.dart';
import 'game_replayer.dart';
import 'triangle_tactics_state.dart';

/// Exhaustively validates mathematical, geometric, and game-rule invariants
/// of a TriangleTacticsState.
class StateValidator {
  static StateValidationResult validate(
    TriangleTacticsState state,
    BoardGeometry geometry, {
    bool verifyReplay = true,
  }) {
    final errors = <String>[];

    // 1. Board size consistency
    if (state.boardSize != geometry.size) {
      errors.add(
        'State boardSize (${state.boardSize}) does not match geometry size (${geometry.size})',
      );
    }

    // 2. Ruleset version
    if (state.rulesetVersion != TriangleTacticsState.currentRulesetVersion) {
      errors.add(
        'State rulesetVersion "${state.rulesetVersion}" is not recognized',
      );
    }

    // 3. Participants & Active player
    if (!state.isParticipant(state.activePlayerId)) {
      errors.add(
        'Active player "${state.activePlayerId}" is not a participant (${state.player1Id}, ${state.player2Id})',
      );
    }

    // 4. Edges validity
    for (final edgeId in state.occupiedEdges) {
      if (!geometry.containsEdge(edgeId)) {
        errors.add('Occupied edge "$edgeId" is not part of the board geometry');
      }
    }

    // 5. Triangles validity and completion
    for (final entry in state.claimedTriangles.entries) {
      final triId = entry.key;
      final ownerId = entry.value;

      final tri = geometry.triangleMap[triId];
      if (tri == null) {
        errors.add('Claimed triangle "$triId" is not a valid board face');
        continue;
      }

      if (!state.isParticipant(ownerId)) {
        errors.add('Triangle "$triId" owner "$ownerId" is not a participant');
      }

      // Check that all 3 edges are present in occupiedEdges
      if (!tri.isCompleted(state.occupiedEdges)) {
        errors.add(
          'Claimed triangle "$triId" does not have all 3 boundary edges occupied',
        );
      }
    }

    // 6. Invariant: Every completed triangle MUST be claimed
    for (final tri in geometry.triangles) {
      if (tri.isCompleted(state.occupiedEdges)) {
        if (!state.claimedTriangles.containsKey(tri.id)) {
          errors.add(
            'Completed triangle "${tri.id}" has all 3 boundary edges occupied but is unclaimed',
          );
        }
      }
    }

    // 7. Score consistency
    int p1Count = 0;
    int p2Count = 0;
    for (final owner in state.claimedTriangles.values) {
      if (owner == state.player1Id) p1Count++;
      if (owner == state.player2Id) p2Count++;
    }

    if (state.player1Score != p1Count) {
      errors.add(
        'Player 1 score (${state.player1Score}) does not match claimed triangles count ($p1Count)',
      );
    }
    if (state.player2Score != p2Count) {
      errors.add(
        'Player 2 score (${state.player2Score}) does not match claimed triangles count ($p2Count)',
      );
    }

    // 8. Terminal condition invariants
    final totalEdges = geometry.edges.length;
    final totalTriangles = geometry.triangles.length;
    final allEdgesOccupied = state.occupiedEdges.length == totalEdges;

    if (state.isTerminal != allEdgesOccupied) {
      errors.add(
        'isTerminal (${state.isTerminal}) does not match full edge occupation ($allEdgesOccupied)',
      );
    }

    if (state.isTerminal) {
      if (state.player1Score + state.player2Score != totalTriangles) {
        errors.add(
          'Sum of player scores (${state.player1Score + state.player2Score}) does not equal total triangles ($totalTriangles)',
        );
      }

      if (state.player1Score > state.player2Score) {
        if (state.winnerId != state.player1Id || state.isDraw) {
          errors.add(
            'Expected winner "${state.player1Id}", but winnerId="${state.winnerId}", isDraw=${state.isDraw}',
          );
        }
      } else if (state.player2Score > state.player1Score) {
        if (state.winnerId != state.player2Id || state.isDraw) {
          errors.add(
            'Expected winner "${state.player2Id}", but winnerId="${state.winnerId}", isDraw=${state.isDraw}',
          );
        }
      } else {
        if (state.winnerId != null || !state.isDraw) {
          errors.add(
            'Expected draw with winnerId=null and isDraw=true, but winnerId="${state.winnerId}", isDraw=${state.isDraw}',
          );
        }
      }
    } else {
      if (state.winnerId != null || state.isDraw) {
        errors.add(
          'Non-terminal state must have winnerId=null and isDraw=false',
        );
      }
    }

    // 9. Replay audit
    if (verifyReplay && errors.isEmpty && state.moveHistory.isNotEmpty) {
      final replayResult = GameReplayer.replay(state);
      if (!replayResult.isSuccess) {
        errors.add('State history replay failed: ${replayResult.error}');
      }
    }

    if (errors.isEmpty) {
      return StateValidationResult.valid;
    }
    return StateValidationResult.invalid(errors);
  }
}
