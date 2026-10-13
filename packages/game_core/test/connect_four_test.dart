import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectFourEngine Tests', () {
    late ConnectFourEngine engine;
    late ConnectFourState state;

    setUp(() {
      engine = ConnectFourEngine();
      state = ConnectFourState.initial(
        player1Id: 'Player 1',
        player2Id: 'Player 2',
      );
    });

    test('Initial state is valid and empty', () {
      expect(state.player1Id, 'Player 1');
      expect(state.player2Id, 'Player 2');
      expect(state.activePlayerId, 'Player 1');
      expect(state.isTerminal, false);
      expect(state.winnerId, null);
      expect(state.totalPiecesPlaced, 0);

      final inv = engine.validateInvariants(state);
      expect(inv.isValid, true);
    });

    test('Pieces obey gravity into the lowest row (row 5)', () {
      final res = engine.applyMove(
        state,
        'Player 1',
        const ConnectFourMove(column: 3),
      );
      expect(res is MoveAccepted, true);
      final next = (res as MoveAccepted).nextState as ConnectFourState;

      expect(next.grid[5][3], 'Player 1');
      expect(next.totalPiecesPlaced, 1);
      expect(next.activePlayerId, 'Player 2');

      // Second piece in same column lands on row 4
      final res2 = engine.applyMove(
        next,
        'Player 2',
        const ConnectFourMove(column: 3),
      );
      expect(res2 is MoveAccepted, true);
      final next2 = (res2 as MoveAccepted).nextState as ConnectFourState;

      expect(next2.grid[4][3], 'Player 2');
      expect(next2.grid[5][3], 'Player 1');
      expect(next2.totalPiecesPlaced, 2);

      final inv = engine.validateInvariants(next2);
      expect(inv.isValid, true);
    });

    test('Rejects moves out of turn and into full columns', () {
      final outOfTurn = engine.applyMove(
        state,
        'Player 2',
        const ConnectFourMove(column: 0),
      );
      expect(outOfTurn is MoveRejected, true);

      // Fill column 0
      var cur = state;
      for (int i = 0; i < 6; i++) {
        final player = cur.activePlayerId;
        final res = engine.applyMove(
          cur,
          player,
          const ConnectFourMove(column: 0),
        );
        expect(res is MoveAccepted, true);
        cur = (res as MoveAccepted).nextState as ConnectFourState;
      }
      expect(cur.isColumnFull(0), true);

      // 7th drop into col 0 is rejected
      final rejected = engine.applyMove(
        cur,
        cur.activePlayerId,
        const ConnectFourMove(column: 0),
      );
      expect(rejected is MoveRejected, true);
    });

    test('Detects horizontal win (4 in a row)', () {
      // P1: col 0, P2: col 0
      // P1: col 1, P2: col 1
      // P1: col 2, P2: col 2
      // P1: col 3 -> P1 wins horizontally on row 5!
      var cur = state;
      final moves = [
        0, 0, // P1, P2
        1, 1, // P1, P2
        2, 2, // P1, P2
        3, // P1
      ];

      MoveResult lastRes = MoveRejected(
        RuleViolation.invalidCoordinates('none'),
      );
      for (final col in moves) {
        lastRes = engine.applyMove(
          cur,
          cur.activePlayerId,
          ConnectFourMove(column: col),
        );
        expect(lastRes is MoveAccepted, true);
        cur = (lastRes as MoveAccepted).nextState as ConnectFourState;
      }

      expect(cur.isTerminal, true);
      expect(cur.winnerId, 'Player 1');
      expect(cur.winningCoords.length, 4);
      expect(lastRes.isTerminal, true);
    });

    test('Detects vertical win (4 in a column)', () {
      // P1: col 0, P2: col 1
      // P1: col 0, P2: col 1
      // P1: col 0, P2: col 1
      // P1: col 0 -> P1 wins vertically in col 0!
      var cur = state;
      final moves = [0, 1, 0, 1, 0, 1, 0];
      for (final col in moves) {
        final res = engine.applyMove(
          cur,
          cur.activePlayerId,
          ConnectFourMove(column: col),
        );
        expect(res is MoveAccepted, true);
        cur = (res as MoveAccepted).nextState as ConnectFourState;
      }

      expect(cur.isTerminal, true);
      expect(cur.winnerId, 'Player 1');
      expect(cur.winningCoords.length, 4);
    });

    test('Bot blocks immediate winning move', () {
      // P1 has cols 0, 1, 2 on row 5
      var cur = state;
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove(column: 0))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove(column: 6))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove(column: 1))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove(column: 6))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove(column: 2))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      // Now it is Player 2's turn. Player 1 threatens to win on column 3!
      final botCol = ConnectFourBot.selectBestColumn(
        state: cur,
        botPlayerId: 'Player 2',
      );
      expect(botCol, 3); // Bot must block column 3!
    });

    test('Serialization round-trip preserves state exactly', () {
      var cur = state;
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove(column: 3))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove(column: 2))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      final json = engine.serializeState(cur);
      final restored = engine.deserializeState(json);

      expect(restored.player1Id, cur.player1Id);
      expect(restored.player2Id, cur.player2Id);
      expect(restored.activePlayerId, cur.activePlayerId);
      expect(restored.stateVersion, cur.stateVersion);
      expect(restored.moveHistory, cur.moveHistory);
      expect(restored.grid[5][3], 'Player 1');
      expect(restored.grid[5][2], 'Player 2');
    });

    test('Grand Arena 9x8 requires 5-in-a-row to win', () {
      final grandState = ConnectFourState.initial(
        player1Id: 'P1',
        player2Id: 'P2',
        rows: 8,
        cols: 9,
        targetStreak: 5,
      );
      expect(grandState.numRows, 8);
      expect(grandState.numCols, 9);
      expect(grandState.targetStreak, 5);

      // Place 4 in a row - should NOT be terminal
      var cur = grandState;
      for (int c = 0; c < 4; c++) {
        cur =
            (engine.applyMove(cur, 'P1', ConnectFourMove.drop(c))
                        as MoveAccepted)
                    .nextState
                as ConnectFourState;
        if (c < 3) {
          cur =
              (engine.applyMove(cur, 'P2', ConnectFourMove.drop(c))
                          as MoveAccepted)
                      .nextState
                  as ConnectFourState;
        }
      }
      expect(cur.isTerminal, false);

      // Now P2 plays somewhere else, and P1 plays 5th disc in col 4
      cur =
          (engine.applyMove(cur, 'P2', const ConnectFourMove.drop(8))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      cur =
          (engine.applyMove(cur, 'P1', const ConnectFourMove.drop(4))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      expect(cur.isTerminal, true);
      expect(cur.winnerId, 'P1');
      expect(cur.winningCoords.length, 5);
    });

    test('Pop-Out mechanic drops column and checks victory', () {
      var cur = state;
      // Player 1 drops col 0 (bottom row 5)
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove.drop(0))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      // Player 2 drops col 0 (row 4)
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove.drop(0))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      expect(cur.grid[5][0], 'Player 1');
      expect(cur.grid[4][0], 'Player 2');

      // Now Player 1 pops out bottom disc in col 0
      final popRes = engine.applyMove(
        cur,
        'Player 1',
        const ConnectFourMove.popOut(0),
      );
      expect(popRes is MoveAccepted, true);
      cur = (popRes as MoveAccepted).nextState as ConnectFourState;

      // Player 2's piece fell into row 5, row 4 is now null
      expect(cur.grid[5][0], 'Player 2');
      expect(cur.grid[4][0], null);
    });

    test('Power Disc (Heavy Breaker) crushes opponent disc', () {
      var cur = state;
      // Player 1 drops col 3
      cur =
          (engine.applyMove(cur, 'Player 1', const ConnectFourMove.drop(3))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;
      // Player 2 drops col 3 (lands on row 4)
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove.drop(3))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      expect(cur.grid[4][3], 'Player 2');

      // Player 1 uses Heavy Breaker Disc into col 3 -> crushes Player 2's piece at row 4!
      final powerRes = engine.applyMove(
        cur,
        'Player 1',
        const ConnectFourMove.powerDrop(3),
      );
      expect(powerRes is MoveAccepted, true);
      cur = (powerRes as MoveAccepted).nextState as ConnectFourState;

      expect(cur.grid[4][3], 'Player 1');
      expect(cur.p1PowerUsed, true);

      // Advance turn with Player 2 normal drop
      cur =
          (engine.applyMove(cur, 'Player 2', const ConnectFourMove.drop(1))
                      as MoveAccepted)
                  .nextState
              as ConnectFourState;

      // Attempting to use power disc again by Player 1 is rejected
      final rejected = engine.applyMove(
        cur,
        'Player 1',
        const ConnectFourMove.powerDrop(2),
      );
      expect(rejected is MoveRejected, true);
    });

    test('Obstacle pegs block falling discs', () {
      final hazardState = ConnectFourState.initial(
        player1Id: 'P1',
        player2Id: 'P2',
        obstacles: [
          [4, 3], // obstacle at row 4, col 3
        ],
      );

      expect(hazardState.isObstacle(4, 3), true);

      // Drop into col 3 - lands at row 3 (on top of obstacle at 4)
      final res = engine.applyMove(
        hazardState,
        'P1',
        const ConnectFourMove.drop(3),
      );
      expect(res is MoveAccepted, true);
      final next = (res as MoveAccepted).nextState as ConnectFourState;

      expect(next.grid[3][3], 'P1');
      expect(next.grid[4][3], null); // obstacle cell is not a player disc

      final inv = engine.validateInvariants(next);
      expect(inv.isValid, true);
    });
  });
}
