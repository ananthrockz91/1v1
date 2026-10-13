import 'game_engine_interface.dart';
import 'move_result.dart';
import 'reversi_move.dart';
import 'reversi_state.dart';
import 'rule_violation.dart';

class ReversiEngine implements GameEngine<ReversiState, ReversiMove> {
  static const String engineGameId = 'reversi';
  static const String engineRulesetVersion = '1.0.0';

  @override
  String get gameId => engineGameId;

  @override
  String get rulesetVersion => engineRulesetVersion;

  static const List<List<int>> directions = [
    [-1, -1], // NW
    [-1, 0], // N
    [-1, 1], // NE
    [0, -1], // W
    [0, 1], // E
    [1, -1], // SW
    [1, 0], // S
    [1, 1], // SE
  ];

  /// Returns all opponent disk coordinates flanked by placing a disk at (row, col)
  List<List<int>> getFlipsForMove(
    ReversiState state,
    int playerNum,
    int row,
    int col,
  ) {
    if (!state.isCellEmpty(row, col)) return const [];

    final opponentNum = playerNum == 1 ? 2 : 1;
    final flips = <List<int>>[];

    for (final dir in directions) {
      final dr = dir[0];
      final dc = dir[1];
      int r = row + dr;
      int c = col + dc;
      final dirFlips = <List<int>>[];

      while (r >= 0 && r < state.boardSize && c >= 0 && c < state.boardSize) {
        final cell = state.cellAt(r, c);
        if (cell == opponentNum) {
          dirFlips.add([r, c]);
          r += dr;
          c += dc;
        } else if (cell == playerNum) {
          // Bounded by player's disk -> flank confirmed
          if (dirFlips.isNotEmpty) {
            flips.addAll(dirFlips);
          }
          break;
        } else {
          // Empty cell -> line broken
          break;
        }
      }
    }

    return flips;
  }

  /// Returns all valid moves for the given player
  List<ReversiMove> getValidMoves(ReversiState state, String playerId) {
    if (state.isTerminal) return const [];
    final playerNum = state.getPlayerNumber(playerId);
    if (playerNum == 0) return const [];

    final validMoves = <ReversiMove>[];
    for (int r = 0; r < state.boardSize; r++) {
      for (int c = 0; c < state.boardSize; c++) {
        if (state.isCellEmpty(r, c)) {
          final flips = getFlipsForMove(state, playerNum, r, c);
          if (flips.isNotEmpty) {
            validMoves.add(ReversiMove(row: r, col: c));
          }
        }
      }
    }

    // If no regular placement is possible, a pass move is allowed if match is not terminal
    if (validMoves.isEmpty) {
      validMoves.add(const ReversiMove.pass());
    }

    return validMoves;
  }

  @override
  RuleViolation? validateMove(
    ReversiState state,
    String playerId,
    ReversiMove move,
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

    final validMoves = getValidMoves(state, playerId);

    if (move.isPass) {
      // Pass is only permitted if there are NO placement moves available
      final hasPlacementMoves = validMoves.any((m) => !m.isPass);
      if (hasPlacementMoves) {
        return RuleViolation.invalidCoordinates(
          'Cannot pass when valid disk placements are available.',
        );
      }
      return null;
    }

    if (move.row < 0 ||
        move.row >= state.boardSize ||
        move.col < 0 ||
        move.col >= state.boardSize) {
      return RuleViolation.invalidCoordinates(
        'Cell (${move.row}, ${move.col}) is outside the ${state.boardSize}x${state.boardSize} grid.',
      );
    }

    if (!state.isCellEmpty(move.row, move.col)) {
      return RuleViolation.occupiedSlot(
        'Cell (${move.row}, ${move.col}) is already occupied.',
      );
    }

    final playerNum = state.getPlayerNumber(playerId);
    final flips = getFlipsForMove(state, playerNum, move.row, move.col);
    if (flips.isEmpty) {
      return RuleViolation.invalidCoordinates(
        'Must flank and trap at least one opponent disk in a straight line.',
      );
    }

    return null;
  }

  @override
  MoveResult applyMove(ReversiState state, String playerId, ReversiMove move) {
    final violation = validateMove(state, playerId, move);
    if (violation != null) {
      return MoveRejected(violation);
    }

    final playerNum = state.getPlayerNumber(playerId);
    final opponentId = state.opponentId;

    // Handle pass move
    if (move.isPass) {
      final consecutivePasses = state.consecutivePasses + 1;
      final bothPassed = consecutivePasses >= 2;

      // Check if opponent also has no moves
      final opponentMoves = getValidMoves(
        state.copyWith(activePlayerId: opponentId),
        opponentId,
      );
      final opponentHasPlacement = opponentMoves.any((m) => !m.isPass);

      final isTerminal = bothPassed || !opponentHasPlacement;
      String? winnerId;
      bool isDraw = false;

      if (isTerminal) {
        if (state.player1Score > state.player2Score) {
          winnerId = state.player1Id;
        } else if (state.player2Score > state.player1Score) {
          winnerId = state.player2Id;
        } else {
          isDraw = true;
        }
      }

      final nextState = state.copyWith(
        activePlayerId: opponentId,
        stateVersion: state.stateVersion + 1,
        isTerminal: isTerminal,
        winnerId: winnerId,
        isDraw: isDraw,
        lastMove: move,
        lastFlipped: const [],
        consecutivePasses: consecutivePasses,
      );

      return MoveAccepted(
        nextState: nextState,
        edgeId: 'pass',
        newlyClaimedTriangles: const [],
        extraTurnAwarded: false,
        nextPlayerId: isTerminal ? state.activePlayerId : opponentId,
        isTerminal: isTerminal,
        winnerId: winnerId,
        isDraw: isDraw,
      );
    }

    // Placement move: flank and flip disks
    final flips = getFlipsForMove(state, playerNum, move.row, move.col);
    final newGrid = List<int>.from(state.grid);

    // Place new disk
    newGrid[move.row * state.boardSize + move.col] = playerNum;

    // Flip all flanked disks
    for (final f in flips) {
      newGrid[f[0] * state.boardSize + f[1]] = playerNum;
    }

    // Count disks
    int p1Score = 0;
    int p2Score = 0;
    int emptyCells = 0;

    for (final cell in newGrid) {
      if (cell == 1)
        p1Score++;
      else if (cell == 2)
        p2Score++;
      else
        emptyCells++;
    }

    // Determine if game concludes
    final onePlayerWipedOut = p1Score == 0 || p2Score == 0;
    final boardFull = emptyCells == 0;

    // Check if next player has valid placement moves
    final intermediateState = state.copyWith(
      grid: List.unmodifiable(newGrid),
      player1Score: p1Score,
      player2Score: p2Score,
      activePlayerId: opponentId,
    );

    final opponentMoves = getValidMoves(intermediateState, opponentId);
    final opponentHasPlacement = opponentMoves.any((m) => !m.isPass);

    // If opponent has no moves, check if current player has moves
    String nextActive = opponentId;

    bool isTerminal = boardFull || onePlayerWipedOut;
    if (!isTerminal && !opponentHasPlacement) {
      final currentAgainMoves = getValidMoves(
        intermediateState.copyWith(activePlayerId: playerId),
        playerId,
      );
      final currentHasMoves = currentAgainMoves.any((m) => !m.isPass);
      if (!currentHasMoves) {
        // Neither player has moves -> terminal!
        isTerminal = true;
      } else {
        // Opponent is forced to pass, current player plays again!
        nextActive = playerId;
      }
    }

    String? winnerId;
    bool isDraw = false;
    if (isTerminal) {
      if (p1Score > p2Score) {
        winnerId = state.player1Id;
      } else if (p2Score > p1Score) {
        winnerId = state.player2Id;
      } else {
        isDraw = true;
      }
    }

    final nextState = state.copyWith(
      grid: List.unmodifiable(newGrid),
      player1Score: p1Score,
      player2Score: p2Score,
      activePlayerId: nextActive,
      stateVersion: state.stateVersion + 1,
      isTerminal: isTerminal,
      winnerId: winnerId,
      isDraw: isDraw,
      lastMove: move,
      lastFlipped: List.unmodifiable(flips),
      consecutivePasses: 0,
    );

    return MoveAccepted(
      nextState: nextState,
      edgeId: '${move.row}_${move.col}',
      newlyClaimedTriangles: const [],
      extraTurnAwarded: nextActive == playerId && !isTerminal,
      nextPlayerId: nextActive,
      isTerminal: isTerminal,
      winnerId: winnerId,
      isDraw: isDraw,
    );
  }

  @override
  StateValidationResult validateInvariants(ReversiState state) {
    final errors = <String>[];
    if (state.grid.length != state.boardSize * state.boardSize) {
      errors.add('Grid size mismatch');
    }
    return errors.isEmpty
        ? StateValidationResult.valid
        : StateValidationResult.invalid(errors);
  }

  @override
  Map<String, dynamic> serializeState(ReversiState state) => state.toJson();

  @override
  ReversiState deserializeState(Map<String, dynamic> json) =>
      ReversiState.fromJson(json);
}
