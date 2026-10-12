import 'package:meta/meta.dart';
import 'board_edge.dart';
import 'grid_node.dart';

enum TriangleOrientation {
  upright, // Apex at top: (r,c), (r+1,c), (r+1,c+1)
  inverted, // Base at top: (r,c), (r,c+1), (r+1,c+1)
}

/// Represents an elementary triangular face on the board bounded by 3 edges.
@immutable
class TriangleFace {
  final String id;
  final TriangleOrientation orientation;
  final GridNode topOrTopLeft;
  final List<GridNode> vertices;
  final Set<String> edgeIds;

  const TriangleFace._({
    required this.id,
    required this.orientation,
    required this.topOrTopLeft,
    required this.vertices,
    required this.edgeIds,
  });

  /// Factory for an upright triangle with top vertex at (r, c).
  factory TriangleFace.upright(int r, int c) {
    final vTop = GridNode(r, c);
    final vBottomLeft = GridNode(r + 1, c);
    final vBottomRight = GridNode(r + 1, c + 1);

    final edgeLeft = BoardEdge(vTop, vBottomLeft);
    final edgeRight = BoardEdge(vTop, vBottomRight);
    final edgeBottom = BoardEdge(vBottomLeft, vBottomRight);

    return TriangleFace._(
      id: 'tri_up_${r}_$c',
      orientation: TriangleOrientation.upright,
      topOrTopLeft: vTop,
      vertices: [vTop, vBottomLeft, vBottomRight],
      edgeIds: {edgeLeft.id, edgeRight.id, edgeBottom.id},
    );
  }

  /// Factory for an inverted triangle with top-left vertex at (r, c).
  factory TriangleFace.inverted(int r, int c) {
    final vTopLeft = GridNode(r, c);
    final vTopRight = GridNode(r, c + 1);
    final vBottom = GridNode(r + 1, c + 1);

    final edgeTop = BoardEdge(vTopLeft, vTopRight);
    final edgeLeft = BoardEdge(vTopLeft, vBottom);
    final edgeRight = BoardEdge(vTopRight, vBottom);

    return TriangleFace._(
      id: 'tri_down_${r}_$c',
      orientation: TriangleOrientation.inverted,
      topOrTopLeft: vTopLeft,
      vertices: [vTopLeft, vTopRight, vBottom],
      edgeIds: {edgeTop.id, edgeLeft.id, edgeRight.id},
    );
  }

  /// General factory creating an elementary triangle from 3 given nodes.
  factory TriangleFace.fromNodes({
    required String id,
    required TriangleOrientation orientation,
    required GridNode v1,
    required GridNode v2,
    required GridNode v3,
  }) {
    final e1 = BoardEdge(v1, v2);
    final e2 = BoardEdge(v2, v3);
    final e3 = BoardEdge(v3, v1);
    final sortedVertices = [v1, v2, v3]..sort((a, b) => a.compareTo(b));
    return TriangleFace._(
      id: id,
      orientation: orientation,
      topOrTopLeft: sortedVertices.first,
      vertices: List.unmodifiable(sortedVertices),
      edgeIds: {e1.id, e2.id, e3.id},
    );
  }

  /// Returns true if all 3 boundary edges are present in [occupiedEdges].
  bool isCompleted(Set<String> occupiedEdges) {
    return edgeIds.every(occupiedEdges.contains);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriangleFace &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}
