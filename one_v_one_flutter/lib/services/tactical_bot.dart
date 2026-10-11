import 'package:game_core/game_core.dart';

/// Intelligent AI player for Triangle Tactics with multi-level tactical heuristics.
class TacticalBot {
  /// Evaluates the board state and returns the optimal move for [botPlayerId].
  static TriangleTacticsMove? selectBestMove({
    required TriangleTacticsState state,
    required String botPlayerId,
  }) {
    final geometry = BoardGeometry(state.boardSize);
    final availableEdges = <BoardEdge>[];

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        availableEdges.add(edge);
      }
    }

    if (availableEdges.isEmpty) return null;

    // 1. TACTICAL PRIORITY 1: Immediate Captures (Completes 1 or 2 triangles)
    final doubleCaptures = <BoardEdge>[];
    final crownCaptures = <BoardEdge>[];
    final singleCaptures = <BoardEdge>[];

    for (final edge in availableEdges) {
      final adjTriangles = geometry.edgeToTriangles[edge.id] ?? [];
      int completes = 0;
      bool isCrown = false;

      for (final tri in adjTriangles) {
        if (!state.claimedTriangles.containsKey(tri.id)) {
          // Count how many of the other 2 edges are occupied
          int otherOccupied = 0;
          for (final eId in tri.edgeIds) {
            if (eId != edge.id && state.occupiedEdges.contains(eId)) {
              otherOccupied++;
            }
          }
          if (otherOccupied == 2) {
            completes++;
            if (_isCrownTriangle(tri.id, state.boardSize)) {
              isCrown = true;
            }
          }
        }
      }

      if (completes == 2) {
        doubleCaptures.add(edge);
      } else if (completes == 1) {
        if (isCrown) {
          crownCaptures.add(edge);
        } else {
          singleCaptures.add(edge);
        }
      }
    }

    // Double capture is the ultimate priority
    if (doubleCaptures.isNotEmpty) {
      return TriangleTacticsMove(
        node1: doubleCaptures.first.node1,
        node2: doubleCaptures.first.node2,
      );
    }

    // Crown captures next
    if (crownCaptures.isNotEmpty) {
      return TriangleTacticsMove(
        node1: crownCaptures.first.node1,
        node2: crownCaptures.first.node2,
      );
    }

    // Single captures
    if (singleCaptures.isNotEmpty) {
      return TriangleTacticsMove(
        node1: singleCaptures.first.node1,
        node2: singleCaptures.first.node2,
      );
    }

    // 2. TACTICAL PRIORITY 2: Safe Edges (Edges that DO NOT leave any triangle with 2 edges)
    final safeEdges = <BoardEdge>[];
    final centerSafeEdges = <BoardEdge>[];

    for (final edge in availableEdges) {
      final adjTriangles = geometry.edgeToTriangles[edge.id] ?? [];
      bool createsThreat = false;

      for (final tri in adjTriangles) {
        if (!state.claimedTriangles.containsKey(tri.id)) {
          int otherOccupied = 0;
          for (final eId in tri.edgeIds) {
            if (eId != edge.id && state.occupiedEdges.contains(eId)) {
              otherOccupied++;
            }
          }
          // If 1 edge was occupied, adding this makes it 2 occupied edges -> threat!
          if (otherOccupied == 1) {
            createsThreat = true;
            break;
          }
        }
      }

      if (!createsThreat) {
        safeEdges.add(edge);
        // Prefer central edges
        if (_isCentralEdge(edge, state.boardSize)) {
          centerSafeEdges.add(edge);
        }
      }
    }

    if (centerSafeEdges.isNotEmpty) {
      return TriangleTacticsMove(
        node1: centerSafeEdges.first.node1,
        node2: centerSafeEdges.first.node2,
      );
    }

    if (safeEdges.isNotEmpty) {
      // Pick the first safe edge
      return TriangleTacticsMove(
        node1: safeEdges.first.node1,
        node2: safeEdges.first.node2,
      );
    }

    // 3. TACTICAL PRIORITY 3: Smart Sacrifice (Give away the smallest chain)
    // When all moves create threats, find the move that gives the opponent the fewest captures
    BoardEdge bestSacrifice = availableEdges.first;
    int minGaveAway = 999;

    for (final edge in availableEdges) {
      int gaveAway = 0;
      final adjTriangles = geometry.edgeToTriangles[edge.id] ?? [];
      for (final tri in adjTriangles) {
        if (!state.claimedTriangles.containsKey(tri.id)) {
          int otherOccupied = 0;
          for (final eId in tri.edgeIds) {
            if (eId != edge.id && state.occupiedEdges.contains(eId)) {
              otherOccupied++;
            }
          }
          if (otherOccupied == 1) {
            gaveAway++;
          }
        }
      }
      if (gaveAway < minGaveAway) {
        minGaveAway = gaveAway;
        bestSacrifice = edge;
      }
    }

    return TriangleTacticsMove(
      node1: bestSacrifice.node1,
      node2: bestSacrifice.node2,
    );
  }

  static bool _isCrownTriangle(String triId, int boardSize) {
    if (boardSize == 3) {
      return triId == 'tri_down_1_0';
    } else if (boardSize == 4) {
      return triId == 'tri_down_1_0' ||
          triId == 'tri_down_2_0' ||
          triId == 'tri_down_2_1';
    } else if (boardSize == 5) {
      return triId == 'tri_down_2_1' ||
          triId == 'tri_up_2_1' ||
          triId == 'tri_down_2_0';
    }
    return false;
  }

  static bool _isCentralEdge(BoardEdge edge, int boardSize) {
    final midR = boardSize / 2;
    final r1 = edge.node1.r;
    final r2 = edge.node2.r;
    return (r1 - midR).abs() <= 1 && (r2 - midR).abs() <= 1;
  }
}
