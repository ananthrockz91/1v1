import 'connect_four_move.dart';
import 'connect_four_state.dart';
import 'game_engine_interface.dart';
import 'move_result.dart';
import 'rule_violation.dart';

class ConnectFourEngine
    implements GameEngine<ConnectFourState, ConnectFourMove> {
  static const String engineGameId = 'connect_four';
  static const String engineRulesetVersion = '1.0.0';

  @override
  String get gameId => engineGameId;

  @override
  String get rulesetVersion => engineRulesetVersion;

  @override
  RuleViolation? validateMove(
    ConnectFourState state,
    String playerId,
    ConnectFourMove move,
  ) {
    if (state.isTerminal) {
      return RuleViolation.gameAlreadyFinished(
        'Match is already terminal. Winner: ${state.winnerId ?? "Draw"}.',
      );
    }

    if (state.activePlayerId != playerId) {
      return RuleViolation.outOfTurn(
        'It is not player "$playerId"\'s turn. Active player: "${state.activePlayerId}".',
      );
    }

    if (move.column < 0 || move.column >= ConnectFourState.cols) {
      return RuleViolation.invalidCoordinates(
        'Column ${move.column} is out of bounds (valid: 0..${ConnectFourState.cols - 1}).',
      );
    }

    if (state.isColumnFull(move.column)) {
      return RuleViolation.occupiedSlot(
        'Column ${move.column} is full and cannot accept more discs.',
      );
    }

    return null;
  }

  @override
  MoveResult applyMove(
    ConnectFourState state,
    String playerId,
    ConnectFourMove move,
  ) {
    final violation = validateMove(state, playerId, move);
    if (violation != null) {
      return MoveRejected(violation);
    }

    final targetRow = state.getLowestOpenRow(move.column);
    if (targetRow == null) {
      return MoveRejected(
        RuleViolation.occupiedSlot('Column ${move.column} is full.'),
      );
    }

    // Clone grid with new disc
    final newGrid = List.generate(
      ConnectFourState.rows,
      (r) => List<String?>.from(state.grid[r]),
    );
    newGrid[targetRow][move.column] = playerId;

    // Check for 4-in-a-row
    final winningStreak = _findWinningStreak(
      newGrid,
      targetRow,
      move.column,
      playerId,
    );

    final isWin = winningStreak != null && winningStreak.isNotEmpty;
    final totalPlaced = state.totalPiecesPlaced + 1;
    final isBoardFull =
        totalPlaced >= (ConnectFourState.rows * ConnectFourState.cols);
    final isDraw = !isWin && isBoardFull;
    final isTerminal = isWin || isDraw;

    final nextPlayer = state.player1Id == playerId
        ? state.player2Id
        : state.player1Id;

    final nextState = state.copyWith(
      grid: newGrid,
      stateVersion: state.stateVersion + 1,
      activePlayerId: isTerminal ? state.activePlayerId : nextPlayer,
      isTerminal: isTerminal,
      winnerId: isWin ? playerId : null,
      isDraw: isDraw,
      winningCoords: isWin ? winningStreak : const [],
      moveHistory: [...state.moveHistory, move.column],
    );

    return MoveAccepted(
      nextState: nextState,
      nextPlayerId: nextState.activePlayerId,
      edgeId: 'col_${move.column}_row_$targetRow',
      newlyClaimedTriangles: const [],
      extraTurnAwarded: false,
      isTerminal: isTerminal,
      winnerId: nextState.winnerId,
      isDraw: isDraw,
    );
  }

  /// Checks if the disc placed at (row, col) creates 4-in-a-row.
  /// Returns the coordinates of the 4 winning pieces, or null.
  List<List<int>>? _findWinningStreak(
    List<List<String?>> grid,
    int r,
    int c,
    String player,
  ) {
    const directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal down-right \
      [-1, 1], // Diagonal up-right /
    ];

    for (final dir in directions) {
      final dr = dir[0];
      final dc = dir[1];
      final coords = <List<int>>[
        [r, c],
      ];

      // Step forward
      int step = 1;
      while (true) {
        final nr = r + dr * step;
        final nc = c + dc * step;
        if (nr < 0 ||
            nr >= ConnectFourState.rows ||
            nc < 0 ||
            nc >= ConnectFourState.cols) {
          break;
        }
        if (grid[nr][nc] == player) {
          coords.add([nr, nc]);
          step++;
        } else {
          break;
        }
      }

      // Step backward
      step = 1;
      while (true) {
        final nr = r - dr * step;
        final nc = c - dc * step;
        if (nr < 0 ||
            nr >= ConnectFourState.rows ||
            nc < 0 ||
            nc >= ConnectFourState.cols) {
          break;
        }
        if (grid[nr][nc] == player) {
          coords.add([nr, nc]);
          step++;
        } else {
          break;
        }
      }

      if (coords.length >= 4) {
        return coords;
      }
    }
    return null;
  }

  @override
  StateValidationResult validateInvariants(ConnectFourState state) {
    final errors = <String>[];

    // Invariant 1: Gravity - no floating discs
    for (int c = 0; c < ConnectFourState.cols; c++) {
      bool seenEmpty = false;
      for (int r = ConnectFourState.rows - 1; r >= 0; r--) {
        final cell = state.grid[r][c];
        if (cell == null) {
          seenEmpty = true;
        } else if (seenEmpty) {
          errors.add(
            'Gravity invariant violated at col $c, row $r: disc floating above empty space.',
          );
        }
      }
    }

    // Invariant 2: Turn count vs piece count
    final total = state.totalPiecesPlaced;
    if (state.moveHistory.length != total) {
      errors.add(
        'Move count mismatch: history has ${state.moveHistory.length}, grid has $total.',
      );
    }

    return errors.isEmpty
        ? StateValidationResult.valid
        : StateValidationResult.invalid(errors);
  }

  @override
  Map<String, dynamic> serializeState(ConnectFourState state) => state.toJson();

  @override
  ConnectFourState deserializeState(Map<String, dynamic> json) =>
      ConnectFourState.fromJson(json);
}
