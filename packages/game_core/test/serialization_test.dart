import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization & State Codecs (Suite B)', () {
    test('serializes and deserializes initial state with exact equality', () {
      final initial = TriangleTacticsState.initial(
        player1Id: 'player_a',
        player2Id: 'player_b',
        boardSize: 4,
      );

      final json = initial.toJson();
      final restored = TriangleTacticsState.fromJson(json);

      expect(restored, equals(initial));
    });

    test('serializes and deserializes state with move history and scores', () {
      final engine = TriangleTacticsEngine();
      var state = TriangleTacticsState.initial(
        player1Id: 'alice',
        player2Id: 'bob',
        boardSize: 3,
      );

      state =
          (engine.applyMove(
                    state,
                    'alice',
                    TriangleTacticsMove(
                      node1: const GridNode(0, 0),
                      node2: const GridNode(1, 0),
                    ),
                  )
                  as MoveAccepted)
              .nextState;

      state =
          (engine.applyMove(
                    state,
                    'bob',
                    TriangleTacticsMove(
                      node1: const GridNode(0, 0),
                      node2: const GridNode(1, 1),
                    ),
                  )
                  as MoveAccepted)
              .nextState;

      final json = state.toJson();
      final restored = TriangleTacticsState.fromJson(json);

      expect(restored.stateVersion, equals(2));
      expect(restored.occupiedEdges.length, equals(2));
      expect(restored.moveHistory.length, equals(2));
      expect(restored, equals(state));

      // Invariants must hold on restored state
      final geometry = engine.getGeometry(state.boardSize);
      final validation = StateValidator.validate(restored, geometry);
      expect(validation.isValid, isTrue);
    });
  });
}
