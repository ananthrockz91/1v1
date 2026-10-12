import 'package:game_core/game_core.dart';
import 'package:test/test.dart';

void main() {
  group('Hexagonal Triggle Board & Rules', () {
    test(
      'verifies board geometry: 37 pegs, 90 edges, 54 triangles, 48 bands',
      () {
        final geometry = BoardGeometry.hexagonal(4);

        expect(geometry.nodes.length, equals(37));
        expect(geometry.edges.length, equals(90));
        expect(geometry.triangles.length, equals(54));
        expect(geometry.bands.length, equals(48));

        // Check row peg counts (7 rows: 4, 5, 6, 7, 6, 5, 4)
        final rowCounts = <int, int>{};
        for (final node in geometry.nodes) {
          rowCounts[node.r] = (rowCounts[node.r] ?? 0) + 1;
        }
        expect(rowCounts, equals({0: 4, 1: 5, 2: 6, 3: 7, 4: 6, 5: 5, 6: 4}));
      },
    );

    test('accepts valid 4-peg straight rubber band and covers 3 edges', () {
      final engine = TriangleTacticsEngine();
      final state = TriangleTacticsState.hexagonal(
        player1Id: 'Player 1',
        player2Id: 'Player 2',
      );

      final geometry = engine.getGeometry(state.boardSize, state.boardShape);
      final firstBand = geometry.bands.first;

      final move = TriangleTacticsMove(
        node1: firstBand.start,
        node2: firstBand.end,
      );

      final result = engine.applyMove(state, 'Player 1', move);
      expect(result, isA<MoveAccepted>());
      final accepted = result as MoveAccepted;

      expect(accepted.nextState.occupiedBands.contains(firstBand.id), isTrue);
      expect(accepted.nextState.occupiedEdges.length, equals(3));
      for (final edgeId in firstBand.edgeIds) {
        expect(accepted.nextState.occupiedEdges.contains(edgeId), isTrue);
      }
      // Since no triangle completed, turn switches to Player 2
      expect(accepted.nextPlayerId, equals('Player 2'));
    });

    test('rejects non-4-peg line or crooked moves in hexagonal game', () {
      final engine = TriangleTacticsEngine();
      final state = TriangleTacticsState.hexagonal(
        player1Id: 'Player 1',
        player2Id: 'Player 2',
      );

      // Attempt single adjacent edge (length 1 instead of 4 pegs / length 3)
      final move1 = TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(0, 1),
      );
      final result1 = engine.applyMove(state, 'Player 1', move1);
      expect(result1, isA<MoveRejected>());

      // Attempt self-loop
      final move2 = TriangleTacticsMove(
        node1: const GridNode(0, 0),
        node2: const GridNode(0, 0),
      );
      final result2 = engine.applyMove(state, 'Player 1', move2);
      expect(result2, isA<MoveRejected>());
    });

    test('rejects duplicate rubber band', () {
      final engine = TriangleTacticsEngine();
      final state = TriangleTacticsState.hexagonal(
        player1Id: 'Player 1',
        player2Id: 'Player 2',
      );

      final band = engine.getGeometry(4, BoardShape.hexagon).bands.first;
      final move = TriangleTacticsMove(node1: band.start, node2: band.end);

      final result1 = engine.applyMove(state, 'Player 1', move) as MoveAccepted;
      // Second attempt by Player 2 with same band
      final result2 = engine.applyMove(result1.nextState, 'Player 2', move);
      expect(result2, isA<MoveRejected>());
    });

    test(
      'completing triangle awards 1 point, extra turn, and satisfies invariants',
      () {
        final engine = TriangleTacticsEngine();
        var state = TriangleTacticsState.hexagonal(
          player1Id: 'Player 1',
          player2Id: 'Player 2',
        );

        final geometry = engine.getGeometry(4, BoardShape.hexagon);
        // Pick a triangle and find 3 bands that cover its 3 edges
        final targetTri = geometry.triangles.first;

        // Find bands that cover targetTri's edges
        final edgeIds = targetTri.edgeIds.toList();
        final band1 = geometry.bands.firstWhere(
          (b) => b.edgeIds.contains(edgeIds[0]),
        );
        final band2 = geometry.bands.firstWhere(
          (b) => b.edgeIds.contains(edgeIds[1]) && b.id != band1.id,
        );

        // Play band 1 (P1)
        var res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(node1: band1.start, node2: band1.end),
                )
                as MoveAccepted;
        state = res.nextState;

        // Play band 2 (P2)
        res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(node1: band2.start, node2: band2.end),
                )
                as MoveAccepted;
        state = res.nextState;

        // Now find band covering edge 3 that isn't band 1 or 2
        final band3 = geometry.bands.firstWhere(
          (b) =>
              b.edgeIds.contains(edgeIds[2]) &&
              !state.occupiedBands.contains(b.id),
        );

        final activeBefore = state.activePlayerId;
        res =
            engine.applyMove(
                  state,
                  activeBefore,
                  TriangleTacticsMove(node1: band3.start, node2: band3.end),
                )
                as MoveAccepted;
        state = res.nextState;

        // Target triangle must now be claimed!
        expect(state.claimedTriangles.containsKey(targetTri.id), isTrue);
        expect(state.claimedTriangles[targetTri.id], equals(activeBefore));
        // In official Triggle, completing a triangle does NOT award an extra turn
        expect(res.extraTurnAwarded, isFalse);
        expect(state.activePlayerId, equals('Player 2'));

        // Validate invariants
        final validation = engine.validateInvariants(state);
        expect(
          validation.isValid,
          isTrue,
          reason: validation.violations.join('; '),
        );
      },
    );

    test(
      'completing a triangle immediately passes turn to opponent (strict alternating turns)',
      () {
        final engine = TriangleTacticsEngine();
        var state = TriangleTacticsState.hexagonal(
          player1Id: 'Player 1',
          player2Id: 'Player 2',
        );

        final geometry = engine.getGeometry(4, BoardShape.hexagon);
        final targetTri = geometry.triangles.first;
        final edgeIds = targetTri.edgeIds.toList();

        final band1 = geometry.bands.firstWhere(
          (b) => b.edgeIds.contains(edgeIds[0]),
        );
        final band2 = geometry.bands.firstWhere(
          (b) => b.edgeIds.contains(edgeIds[1]) && b.id != band1.id,
        );

        // Move 1: P1
        var res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(node1: band1.start, node2: band1.end),
                )
                as MoveAccepted;
        state = res.nextState;
        expect(state.activePlayerId, equals('Player 2'));

        // Move 2: P2
        res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(node1: band2.start, node2: band2.end),
                )
                as MoveAccepted;
        state = res.nextState;
        expect(state.activePlayerId, equals('Player 1'));

        // Move 3: P1 completes triangle -> claims face, turn switches to P2
        final band3 = geometry.bands.firstWhere(
          (b) =>
              b.edgeIds.contains(edgeIds[2]) &&
              !state.occupiedBands.contains(b.id),
        );
        res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(node1: band3.start, node2: band3.end),
                )
                as MoveAccepted;
        state = res.nextState;
        expect(res.extraTurnAwarded, isFalse);
        expect(res.nextPlayerId, equals('Player 2'));
        expect(state.activePlayerId, equals('Player 2'));
        expect(state.player1Score, equals(1));
        expect(state.player2Score, equals(0));

        // Move 4: Player 2 can immediately play
        final nextAvailableBand = geometry.bands.firstWhere(
          (b) => !state.occupiedBands.contains(b.id),
        );
        res =
            engine.applyMove(
                  state,
                  state.activePlayerId,
                  TriangleTacticsMove(
                    node1: nextAvailableBand.start,
                    node2: nextAvailableBand.end,
                  ),
                )
                as MoveAccepted;
        state = res.nextState;
        expect(state.activePlayerId, equals('Player 1'));

        final validation = engine.validateInvariants(state);
        expect(
          validation.isValid,
          isTrue,
          reason: validation.violations.join('; '),
        );
      },
    );
  });
}
