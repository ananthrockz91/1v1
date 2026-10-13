import 'connect_four_move.dart';
import 'connect_four_state.dart';
import 'game_engine_interface.dart';
import 'move_result.dart';
import 'rule_violation.dart';

class ConnectFourEngine
    implements GameEngine<ConnectFourState, ConnectFourMove> {
  static const String engineGameId = 'connect_four';
  static const String engineRulesetVersion = '1.1.0';

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

    if (move.column < 0 || move.column >= state.numCols) {
      return RuleViolation.invalidCoordinates(
        'Column ${move.column} is out of bounds (valid: 0..${state.numCols - 1}).',
      );
    }

    switch (move.action) {
      case ConnectFourAction.drop:
        if (state.isColumnFull(move.column)) {
          return RuleViolation.occupiedSlot(
            'Column ${move.column} is full and cannot accept more discs.',
          );
        }
        break;

      case ConnectFourAction.popOut:
        if (!state.canPopOut(move.column, playerId)) {
          return RuleViolation.invalidCoordinates(
            'Cannot pop out column ${move.column}: bottom piece does not belong to "$playerId" or is blocked.',
          );
        }
        break;

      case ConnectFourAction.powerDrop:
        if (state.isPowerUsed(playerId)) {
          return RuleViolation.malformedAction(
            'Player "$playerId" has already used their once-per-match Heavy Breaker Disc.',
          );
        }
        if (!state.canPowerDrop(move.column, playerId)) {
          return RuleViolation.occupiedSlot(
            'Cannot use Heavy Breaker Disc in column ${move.column}: column is blocked.',
          );
        }
        break;
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

    final opponentId = state.player1Id == playerId
        ? state.player2Id
        : state.player1Id;

    final newGrid = List.generate(
      state.numRows,
      (r) => List<String?>.from(state.grid[r]),
    );

    bool p1PowerUsed = state.p1PowerUsed;
    bool p2PowerUsed = state.p2PowerUsed;
    List<List<int>> winningStreak = [];
    String? winnerId;
    int affectedRow = 0;

    if (move.action == ConnectFourAction.drop) {
      final targetRow = state.getLowestOpenRow(move.column);
      if (targetRow == null) {
        return MoveRejected(
          RuleViolation.occupiedSlot('Column ${move.column} is full.'),
        );
      }
      affectedRow = targetRow;
      newGrid[targetRow][move.column] = playerId;

      final streak = _findWinningStreak(
        newGrid,
        targetRow,
        move.column,
        playerId,
        state.targetStreak,
      );
      if (streak != null && streak.isNotEmpty) {
        winningStreak = streak;
        winnerId = playerId;
      }
    } else if (move.action == ConnectFourAction.powerDrop) {
      if (playerId == state.player1Id) {
        p1PowerUsed = true;
      } else {
        p2PowerUsed = true;
      }

      if (state.isColumnFull(move.column)) {
        // Crushes and replaces the top opponent disc
        newGrid[0][move.column] = playerId;
        affectedRow = 0;
      } else {
        final targetRow = state.getLowestOpenRow(move.column)!;
        // Check if crushing the opponent piece directly below
        if (targetRow + 1 < state.numRows &&
            newGrid[targetRow + 1][move.column] == opponentId &&
            !state.isObstacle(targetRow + 1, move.column)) {
          newGrid[targetRow + 1][move.column] = playerId;
          affectedRow = targetRow + 1;
        } else {
          newGrid[targetRow][move.column] = playerId;
          affectedRow = targetRow;
        }
      }

      final streak = _findWinningStreak(
        newGrid,
        affectedRow,
        move.column,
        playerId,
        state.targetStreak,
      );
      if (streak != null && streak.isNotEmpty) {
        winningStreak = streak;
        winnerId = playerId;
      }
    } else if (move.action == ConnectFourAction.popOut) {
      final col = move.column;
      // Gravity drop down the column after popping the bottom piece
      for (int r = state.numRows - 1; r > 0; r--) {
        if (!state.isObstacle(r, col)) {
          // If slot above is obstacle, skip above it or take null
          int fromR = r - 1;
          while (fromR >= 0 && state.isObstacle(fromR, col)) {
            fromR--;
          }
          newGrid[r][col] = fromR >= 0 ? newGrid[fromR][col] : null;
          if (fromR >= 0) newGrid[fromR][col] = null;
        }
      }
      if (!state.isObstacle(0, col)) {
        newGrid[0][col] = null;
      }
      affectedRow = state.numRows - 1;

      // Scan full board for wins for both players
      final p1Streak = _findBoardWin(
        newGrid,
        state.player1Id,
        state.targetStreak,
      );
      final p2Streak = _findBoardWin(
        newGrid,
        state.player2Id,
        state.targetStreak,
      );

      if (playerId == state.player1Id && p1Streak != null) {
        winnerId = state.player1Id;
        winningStreak = p1Streak;
      } else if (playerId == state.player2Id && p2Streak != null) {
        winnerId = state.player2Id;
        winningStreak = p2Streak;
      } else if (p1Streak != null) {
        winnerId = state.player1Id;
        winningStreak = p1Streak;
      } else if (p2Streak != null) {
        winnerId = state.player2Id;
        winningStreak = p2Streak;
      }
    }

    final isWin = winnerId != null && winningStreak.isNotEmpty;
    final List<List<int>> sortedCoords = [];
    if (isWin) {
      sortedCoords.addAll(winningStreak);
      sortedCoords.sort((a, b) {
        final colComp = a[1].compareTo(b[1]);
        if (colComp != 0) return colComp;
        return a[0].compareTo(b[0]);
      });
    }

    // Check board full (excluding obstacles)
    int nonObstacleCells = 0;
    int filledNonObstacle = 0;
    for (int r = 0; r < state.numRows; r++) {
      for (int c = 0; c < state.numCols; c++) {
        if (!state.isObstacle(r, c)) {
          nonObstacleCells++;
          if (newGrid[r][c] != null) filledNonObstacle++;
        }
      }
    }

    final isDraw = !isWin && (filledNonObstacle >= nonObstacleCells);
    final isTerminal = isWin || isDraw;
    final nextPlayer = opponentId;

    final nextState = state.copyWith(
      grid: newGrid,
      stateVersion: state.stateVersion + 1,
      activePlayerId: isTerminal ? state.activePlayerId : nextPlayer,
      p1PowerUsed: p1PowerUsed,
      p2PowerUsed: p2PowerUsed,
      isTerminal: isTerminal,
      winnerId: isWin ? winnerId : null,
      isDraw: isDraw,
      winningCoords: isWin ? sortedCoords : const [],
      moveHistory: [...state.moveHistory, move.column],
    );

    return MoveAccepted(
      nextState: nextState,
      nextPlayerId: nextState.activePlayerId,
      edgeId: '${move.action.name}_col_${move.column}_row_$affectedRow',
      newlyClaimedTriangles: const [],
      extraTurnAwarded: false,
      isTerminal: isTerminal,
      winnerId: nextState.winnerId,
      isDraw: isDraw,
    );
  }

  /// Scans entire grid for any streak of [targetStreak] discs of [player].
  List<List<int>>? _findBoardWin(
    List<List<String?>> grid,
    String player,
    int targetStreak,
  ) {
    final rows = grid.length;
    final cols = grid[0].length;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == player) {
          final streak = _findWinningStreak(grid, r, c, player, targetStreak);
          if (streak != null && streak.isNotEmpty) return streak;
        }
      }
    }
    return null;
  }

  /// Checks if the disc placed at (row, col) creates a line of at least [targetStreak].
  List<List<int>>? _findWinningStreak(
    List<List<String?>> grid,
    int r,
    int c,
    String player,
    int targetStreak,
  ) {
    const directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal down-right \
      [-1, 1], // Diagonal up-right /
    ];

    final rows = grid.length;
    final cols = grid[0].length;

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
        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) break;
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
        if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) break;
        if (grid[nr][nc] == player) {
          coords.add([nr, nc]);
          step++;
        } else {
          break;
        }
      }

      if (coords.length >= targetStreak) {
        return coords;
      }
    }
    return null;
  }

  @override
  StateValidationResult validateInvariants(ConnectFourState state) {
    final errors = <String>[];

    // Invariant: Gravity - no floating discs unless blocked by obstacle
    for (int c = 0; c < state.numCols; c++) {
      bool seenEmpty = false;
      for (int r = state.numRows - 1; r >= 0; r--) {
        final cell = state.grid[r][c];
        final isObs = state.isObstacle(r, c);
        if (cell == null && !isObs) {
          seenEmpty = true;
        } else if (cell != null && seenEmpty) {
          // Check if there is an obstacle beneath it preventing fall
          bool hasObstacleBelow = false;
          for (int checkR = r + 1; checkR < state.numRows; checkR++) {
            if (state.isObstacle(checkR, c)) {
              hasObstacleBelow = true;
              break;
            }
          }
          if (!hasObstacleBelow) {
            errors.add(
              'Gravity invariant violated at col $c, row $r: disc floating above empty space.',
            );
          }
        }
      }
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
