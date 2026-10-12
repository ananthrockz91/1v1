import 'connect_four_engine.dart';
import 'connect_four_move.dart';
import 'connect_four_state.dart';
import 'move_result.dart';

class ConnectFourBot {
  static final ConnectFourEngine _engine = ConnectFourEngine();

  /// Column preference weights (center is strategically highest value)
  static const List<int> columnOrder = [3, 2, 4, 1, 5, 0, 6];

  /// Selects the optimal column for the bot to drop its disc.
  static int selectBestColumn({
    required ConnectFourState state,
    required String botPlayerId,
  }) {
    final opponentId = state.player1Id == botPlayerId
        ? state.player2Id
        : state.player1Id;

    final validCols = <int>[];
    for (int col = 0; col < ConnectFourState.cols; col++) {
      if (!state.isColumnFull(col)) {
        validCols.add(col);
      }
    }

    if (validCols.isEmpty) return 3;

    // 1. Check if we can WIN on this turn
    for (final col in validCols) {
      final res = _engine.applyMove(
        state,
        botPlayerId,
        ConnectFourMove(column: col),
      );
      if (res is MoveAccepted &&
          res.isTerminal &&
          res.winnerId == botPlayerId) {
        return col;
      }
    }

    // 2. Check if opponent can WIN on their next turn, and BLOCK them!
    for (final col in validCols) {
      final res = _engine.applyMove(
        state.copyWith(activePlayerId: opponentId),
        opponentId,
        ConnectFourMove(column: col),
      );
      if (res is MoveAccepted && res.isTerminal && res.winnerId == opponentId) {
        return col;
      }
    }

    // 3. Filter out columns that would allow opponent to win right above our drop
    final safeCols = <int>[];
    for (final col in validCols) {
      final res = _engine.applyMove(
        state,
        botPlayerId,
        ConnectFourMove(column: col),
      );
      if (res is MoveAccepted) {
        final afterState = res.nextState as ConnectFourState;
        // Does dropping here give opponent a winning move on top?
        bool givesOpponentWin = false;
        if (!afterState.isColumnFull(col)) {
          final oppRes = _engine.applyMove(
            afterState.copyWith(activePlayerId: opponentId),
            opponentId,
            ConnectFourMove(column: col),
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

    final candidateCols = safeCols.isNotEmpty ? safeCols : validCols;

    // 4. Pick from candidate columns in order of strategic center preference
    for (final preferredCol in columnOrder) {
      if (candidateCols.contains(preferredCol)) {
        return preferredCol;
      }
    }

    return candidateCols.first;
  }
}
