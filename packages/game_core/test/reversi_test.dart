import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('Chroma Reversi (Othello Duel) Engine Tests', () {
    late ReversiEngine engine;
    late ReversiState state;

    setUp(() {
      engine = ReversiEngine();
      state = ReversiState.initial(
        player1Id: 'Player 1',
        player2Id: 'Player 2',
      );
    });

    test('initializes with standard 8x8 layout and 4 center discs', () {
      expect(state.boardSize, equals(8));
      expect(state.player1Score, equals(2));
      expect(state.player2Score, equals(2));
      expect(state.activePlayerId, equals('Player 1'));
      expect(state.isTerminal, isFalse);

      // Center layout:
      // (3, 3) = P2 (2), (3, 4) = P1 (1)
      // (4, 3) = P1 (1), (4, 4) = P2 (2)
      expect(state.cellAt(3, 3), equals(2));
      expect(state.cellAt(3, 4), equals(1));
      expect(state.cellAt(4, 3), equals(1));
      expect(state.cellAt(4, 4), equals(2));
    });

    test(
      'opening turn provides exactly 4 valid placement moves for Player 1',
      () {
        final validMoves = engine.getValidMoves(state, 'Player 1');
        expect(validMoves.length, equals(4));

        final expectedMoves = [
          const ReversiMove(row: 2, col: 3),
          const ReversiMove(row: 3, col: 2),
          const ReversiMove(row: 4, col: 5),
          const ReversiMove(row: 5, col: 4),
        ];

        for (final m in expectedMoves) {
          expect(validMoves.contains(m), isTrue, reason: 'Expected move $m');
        }
      },
    );

    test('applying valid move flips opponent disc and updates scores', () {
      // Player 1 plays (2, 3), flanking (3, 3) downwards to (4, 3)
      final move = const ReversiMove(row: 2, col: 3);
      final result = engine.applyMove(state, 'Player 1', move);

      expect(result, isA<MoveAccepted>());
      final accepted = result as MoveAccepted;
      final next = accepted.nextState as ReversiState;

      expect(next.cellAt(2, 3), equals(1));
      expect(next.cellAt(3, 3), equals(1)); // Flanked from P2 (2) to P1 (1)!
      expect(next.player1Score, equals(4)); // 2 initial + 1 placed + 1 flipped
      expect(next.player2Score, equals(1)); // 2 initial - 1 flipped
      expect(next.activePlayerId, equals('Player 2'));
      expect(next.lastFlipped.length, equals(1));
      expect(next.lastFlipped.first, equals([3, 3]));
      expect(next.stateVersion, equals(1));
    });

    test('rejects move on occupied cell or non-flanking cell', () {
      // Occupied cell (3, 3)
      final occupiedResult = engine.applyMove(
        state,
        'Player 1',
        const ReversiMove(row: 3, col: 3),
      );
      expect(occupiedResult, isA<MoveRejected>());

      // Non-flanking corner cell (0, 0)
      final noFlankResult = engine.applyMove(
        state,
        'Player 1',
        const ReversiMove(row: 0, col: 0),
      );
      expect(noFlankResult, isA<MoveRejected>());
    });

    test('rejects out of turn moves', () {
      final result = engine.applyMove(
        state,
        'Player 2',
        const ReversiMove(row: 2, col: 3),
      );
      expect(result, isA<MoveRejected>());
      final rejected = result as MoveRejected;
      expect(rejected.violation.type, equals(RuleViolationType.notYourTurn));
    });

    test('serialization roundtrip preserves complete state', () {
      final move = const ReversiMove(row: 2, col: 3);
      final result = engine.applyMove(state, 'Player 1', move) as MoveAccepted;
      final nextState = result.nextState as ReversiState;

      final json = engine.serializeState(nextState);
      final deserialized = engine.deserializeState(json);

      expect(deserialized.grid, equals(nextState.grid));
      expect(deserialized.player1Score, equals(nextState.player1Score));
      expect(deserialized.player2Score, equals(nextState.player2Score));
      expect(deserialized.activePlayerId, equals(nextState.activePlayerId));
      expect(deserialized.stateVersion, equals(nextState.stateVersion));
      expect(deserialized.lastFlipped, equals(nextState.lastFlipped));
    });

    test('ReversiBot evaluates and selects smart opening move', () {
      final bot = ReversiBot(engine: engine, maxDepth: 2);
      final botMove = bot.selectBestMove(state);

      expect(botMove.isPass, isFalse);
      expect(botMove.row, inInclusiveRange(0, 7));
      expect(botMove.col, inInclusiveRange(0, 7));

      final validMoves = engine.getValidMoves(state, 'Player 1');
      expect(validMoves.contains(botMove), isTrue);
    });
  });
}
