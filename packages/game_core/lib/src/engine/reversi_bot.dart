import 'move_result.dart';
import 'reversi_engine.dart';
import 'reversi_move.dart';
import 'reversi_state.dart';

/// Tactical AI bot for solo and practice Reversi matches.
class ReversiBot {
  final ReversiEngine engine;
  final int maxDepth;

  ReversiBot({ReversiEngine? engine, this.maxDepth = 3})
    : engine = engine ?? ReversiEngine();

  // Positional weights matrix for 8x8 Reversi
  static const List<int> _positionWeights = [
    100,
    -25,
    15,
    8,
    8,
    15,
    -25,
    100,
    -25,
    -45,
    -5,
    -5,
    -5,
    -5,
    -45,
    -25,
    15,
    -5,
    5,
    2,
    2,
    5,
    -5,
    15,
    8,
    -5,
    2,
    1,
    1,
    2,
    -5,
    8,
    8,
    -5,
    2,
    1,
    1,
    2,
    -5,
    8,
    15,
    -5,
    5,
    2,
    2,
    5,
    -5,
    15,
    -25,
    -45,
    -5,
    -5,
    -5,
    -5,
    -45,
    -25,
    100,
    -25,
    15,
    8,
    8,
    15,
    -25,
    100,
  ];

  /// Finds the best tactical move for the active bot player
  ReversiMove selectBestMove(ReversiState state) {
    final validMoves = engine.getValidMoves(state, state.activePlayerId);
    if (validMoves.isEmpty) return const ReversiMove.pass();
    if (validMoves.length == 1) return validMoves.first;

    // Filter placement moves vs pass
    final placementMoves = validMoves.where((m) => !m.isPass).toList();
    if (placementMoves.isEmpty) return const ReversiMove.pass();

    ReversiMove bestMove = placementMoves.first;
    double bestScore = -double.infinity;

    final botNum = state.getPlayerNumber(state.activePlayerId);

    for (final move in placementMoves) {
      final result = engine.applyMove(state, state.activePlayerId, move);
      if (result is MoveAccepted) {
        final nextState = result.nextState as ReversiState;
        final score = _minimax(
          nextState,
          maxDepth - 1,
          -double.infinity,
          double.infinity,
          false,
          botNum,
        );
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
    }

    return bestMove;
  }

  double _minimax(
    ReversiState state,
    int depth,
    double alpha,
    double beta,
    bool isMaximizing,
    int botNum,
  ) {
    if (depth == 0 || state.isTerminal) {
      return _evaluateState(state, botNum);
    }

    final validMoves = engine.getValidMoves(state, state.activePlayerId);
    if (validMoves.isEmpty) {
      return _evaluateState(state, botNum);
    }

    if (isMaximizing) {
      double maxEval = -double.infinity;
      for (final move in validMoves) {
        final result = engine.applyMove(state, state.activePlayerId, move);
        if (result is MoveAccepted) {
          final nextState = result.nextState as ReversiState;
          final eval = _minimax(
            nextState,
            depth - 1,
            alpha,
            beta,
            false,
            botNum,
          );
          if (eval > maxEval) maxEval = eval;
          if (eval > alpha) alpha = eval;
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in validMoves) {
        final result = engine.applyMove(state, state.activePlayerId, move);
        if (result is MoveAccepted) {
          final nextState = result.nextState as ReversiState;
          final eval = _minimax(
            nextState,
            depth - 1,
            alpha,
            beta,
            true,
            botNum,
          );
          if (eval < minEval) minEval = eval;
          if (eval < beta) beta = eval;
          if (beta <= alpha) break;
        }
      }
      return minEval;
    }
  }

  double _evaluateState(ReversiState state, int botNum) {
    if (state.isTerminal) {
      final botId = state.getPlayerIdFromNumber(botNum);
      if (state.winnerId == botId) return 10000.0;
      if (state.isDraw) return 0.0;
      return -10000.0;
    }

    final opponentNum = botNum == 1 ? 2 : 1;
    double score = 0;

    int botDisks = 0;
    int oppDisks = 0;

    for (int i = 0; i < state.grid.length; i++) {
      final cell = state.grid[i];
      final weight = i < _positionWeights.length ? _positionWeights[i] : 1;

      if (cell == botNum) {
        botDisks++;
        score += weight;
      } else if (cell == opponentNum) {
        oppDisks++;
        score -= weight;
      }
    }

    // Mobility evaluation (freedom of movement)
    final botId = state.getPlayerIdFromNumber(botNum);
    final oppId = state.getPlayerIdFromNumber(opponentNum);
    final botMoves = engine
        .getValidMoves(state, botId)
        .where((m) => !m.isPass)
        .length;
    final oppMoves = engine
        .getValidMoves(state, oppId)
        .where((m) => !m.isPass)
        .length;

    score += (botMoves - oppMoves) * 5.0;

    // Disc parity towards late game (if > 48 discs on board)
    final totalDisks = botDisks + oppDisks;
    if (totalDisks > 48) {
      score += (botDisks - oppDisks) * 10.0;
    }

    return score;
  }
}
