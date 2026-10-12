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
  });
}
