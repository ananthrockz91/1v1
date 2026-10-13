import 'connect_four_engine.dart';
import 'connect_four_move.dart';
import 'connect_four_state.dart';
import 'move_result.dart';

class ConnectFourBot {
  static final ConnectFourEngine _engine = ConnectFourEngine();

  /// Generates strategic column ordering from center outwards for any [cols] width.
  static List<int> getColumnOrder(int cols) {
    final order = <int>[];
    final mid = cols ~/ 2;
    order.add(mid);
    for (int offset = 1; offset <= mid; offset++) {
      if (mid - offset >= 0) order.add(mid - offset);
      if (mid + offset < cols) order.add(mid + offset);
    }
    return order;
  }

  /// Selects the optimal move (standard drop, power drop, or pop-out) for the bot.
  static ConnectFourMove selectBestMove({
    required ConnectFourState state,
    required String botPlayerId,
  }) {
    final opponentId = state.player1Id == botPlayerId
        ? state.player2Id
        : state.player1Id;

    final numCols = state.numCols;
    final validDropCols = <int>[];
    for (int col = 0; col < numCols; col++) {
      if (!state.isColumnFull(col)) {
        validDropCols.add(col);
      }
    }

    // 1. Check if we can WIN immediately on this turn with a standard drop
    for (final col in validDropCols) {
      final res = _engine.applyMove(
        state,
        botPlayerId,
        ConnectFourMove.drop(col),
      );
      if (res is MoveAccepted &&
          res.isTerminal &&
          res.winnerId == botPlayerId) {
        return ConnectFourMove.drop(col);
      }
    }

    // 2. Check if we can WIN with Pop-Out
    for (int col = 0; col < numCols; col++) {
      if (state.canPopOut(col, botPlayerId)) {
        final res = _engine.applyMove(
          state,
          botPlayerId,
          ConnectFourMove.popOut(col),
        );
        if (res is MoveAccepted &&
            res.isTerminal &&
            res.winnerId == botPlayerId) {
          return ConnectFourMove.popOut(col);
        }
      }
    }

    // 3. Check if we can WIN with Power Drop (Heavy Breaker)
    if (!state.isPowerUsed(botPlayerId)) {
      for (int col = 0; col < numCols; col++) {
        if (state.canPowerDrop(col, botPlayerId)) {
          final res = _engine.applyMove(
            state,
            botPlayerId,
            ConnectFourMove.powerDrop(col),
          );
          if (res is MoveAccepted &&
              res.isTerminal &&
              res.winnerId == botPlayerId) {
            return ConnectFourMove.powerDrop(col);
          }
        }
      }
    }

    // 4. Check if opponent can WIN on their next turn, and BLOCK them!
    for (final col in validDropCols) {
      final res = _engine.applyMove(
        state.copyWith(activePlayerId: opponentId),
        opponentId,
        ConnectFourMove.drop(col),
      );
      if (res is MoveAccepted && res.isTerminal && res.winnerId == opponentId) {
        return ConnectFourMove.drop(col);
      }
    }

    // 5. Filter out drop columns that would immediately hand opponent a win right above us
    final safeCols = <int>[];
    for (final col in validDropCols) {
      final res = _engine.applyMove(
        state,
        botPlayerId,
        ConnectFourMove.drop(col),
      );
      if (res is MoveAccepted) {
        final afterState = res.nextState as ConnectFourState;
        bool givesOpponentWin = false;
        if (!afterState.isColumnFull(col)) {
          final oppRes = _engine.applyMove(
            afterState.copyWith(activePlayerId: opponentId),
            opponentId,
            ConnectFourMove.drop(col),
          );
          if (oppRes is MoveAccepted &&
              oppRes.isTerminal &&
              oppRes.winnerId == opponentId) {
            givesOpponentWin = true;
          }
        }
        if (!givesOpponentWin) {
          safeCols.add(col);
        }
      }
    }

    final candidateCols = safeCols.isNotEmpty ? safeCols : validDropCols;
    final columnOrder = getColumnOrder(numCols);

    if (candidateCols.isNotEmpty) {
      for (final preferredCol in columnOrder) {
        if (candidateCols.contains(preferredCol)) {
          return ConnectFourMove.drop(preferredCol);
        }
      }
      return ConnectFourMove.drop(candidateCols.first);
    }

    // Fallback: If no normal drop columns available, try power drop or pop-out
    if (!state.isPowerUsed(botPlayerId)) {
      for (final col in columnOrder) {
        if (state.canPowerDrop(col, botPlayerId)) {
          return ConnectFourMove.powerDrop(col);
        }
      }
    }

    for (int col = 0; col < numCols; col++) {
      if (state.canPopOut(col, botPlayerId)) {
        return ConnectFourMove.popOut(col);
      }
    }

    return const ConnectFourMove.drop(0);
  }

  /// Backward-compatible method returning column index
  static int selectBestColumn({
    required ConnectFourState state,
    required String botPlayerId,
  }) {
    return selectBestMove(state: state, botPlayerId: botPlayerId).column;
  }
}
