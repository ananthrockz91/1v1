import 'package:meta/meta.dart';
import 'board_edge.dart';
import 'grid_node.dart';
import 'triangle_face.dart';

/// Precomputes and caches the static geometry, graph structure, and faces
/// for a triangular lattice of side length [size].
@immutable
class BoardGeometry {
  final int size;
  final List<GridNode> nodes;
  final List<BoardEdge> edges;
  final List<TriangleFace> triangles;

  final Map<String, GridNode> nodeMap;
  final Map<String, BoardEdge> edgeMap;
  final Map<String, TriangleFace> triangleMap;
  final Map<String, List<TriangleFace>> edgeToTriangles;

  static final Map<int, BoardGeometry> _cache = {};

  factory BoardGeometry(int size) {
    assert(size >= 1, 'Board size must be at least 1');
    return _cache.putIfAbsent(size, () => BoardGeometry._generate(size));
  }

  BoardGeometry._({
    required this.size,
    required this.nodes,
    required this.edges,
    required this.triangles,
    required this.nodeMap,
    required this.edgeMap,
    required this.triangleMap,
    required this.edgeToTriangles,
  });

  factory BoardGeometry._generate(int size) {
    final nodes = <GridNode>[];
    final nodeMap = <String, GridNode>{};

    for (int r = 0; r <= size; r++) {
      for (int c = 0; c <= r; c++) {
        final node = GridNode(r, c);
        nodes.add(node);
        nodeMap[node.id] = node;
      }
    }

    final edges = <BoardEdge>[];
    final edgeMap = <String, BoardEdge>{};

    // 1. Horizontal edges
    for (int r = 1; r <= size; r++) {
      for (int c = 0; c < r; c++) {
        final edge = BoardEdge(GridNode(r, c), GridNode(r, c + 1));
        edges.add(edge);
        edgeMap[edge.id] = edge;
      }
    }

    // 2. Down-left and Down-right edges
    for (int r = 0; r < size; r++) {
      for (int c = 0; c <= r; c++) {
        final dl = BoardEdge(GridNode(r, c), GridNode(r + 1, c));
        edges.add(dl);
        edgeMap[dl.id] = dl;

        final dr = BoardEdge(GridNode(r, c), GridNode(r + 1, c + 1));
        edges.add(dr);
        edgeMap[dr.id] = dr;
      }
    }

    final triangles = <TriangleFace>[];
    final triangleMap = <String, TriangleFace>{};
    final edgeToTriangles = <String, List<TriangleFace>>{};

    for (final edge in edges) {
      edgeToTriangles[edge.id] = [];
    }

    // Upright triangles
    for (int r = 0; r < size; r++) {
      for (int c = 0; c <= r; c++) {
        final tri = TriangleFace.upright(r, c);
        triangles.add(tri);
        triangleMap[tri.id] = tri;
        for (final edgeId in tri.edgeIds) {
          edgeToTriangles[edgeId]?.add(tri);
        }
      }
    }

    // Inverted triangles
    for (int r = 1; r < size; r++) {
      for (int c = 0; c < r; c++) {
        final tri = TriangleFace.inverted(r, c);
        triangles.add(tri);
        triangleMap[tri.id] = tri;
        for (final edgeId in tri.edgeIds) {
          edgeToTriangles[edgeId]?.add(tri);
        }
      }
    }

    return BoardGeometry._(
      size: size,
      nodes: List.unmodifiable(nodes),
      edges: List.unmodifiable(edges),
      triangles: List.unmodifiable(triangles),
      nodeMap: Map.unmodifiable(nodeMap),
      edgeMap: Map.unmodifiable(edgeMap),
      triangleMap: Map.unmodifiable(triangleMap),
      edgeToTriangles: Map.unmodifiable(edgeToTriangles),
    );
  }

  /// Theoretical expected nodes for side length n: (n + 1) * (n + 2) / 2
  static int expectedNodeCount(int n) => (n + 1) * (n + 2) ~/ 2;

  /// Theoretical expected elementary triangles for side length n: n * n
  static int expectedTriangleCount(int n) => n * n;

  /// Theoretical expected elementary edges for side length n: 3 * n * (n + 1) / 2
  static int expectedEdgeCount(int n) => 3 * n * (n + 1) ~/ 2;

  bool containsNode(GridNode node) =>
      node.r >= 0 && node.r <= size && node.c >= 0 && node.c <= node.r;

  bool containsEdge(String edgeId) => edgeMap.containsKey(edgeId);

  bool containsTriangle(String triangleId) =>
      triangleMap.containsKey(triangleId);
}
