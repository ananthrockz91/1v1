import 'dart:math';
import 'package:meta/meta.dart';
import 'band_line.dart';
import 'board_edge.dart';
import 'grid_node.dart';
import 'triangle_face.dart';

enum BoardShape { triangle, hexagon }

/// Point on 2D normalized plane for lattice geometry.
@immutable
class LatticePoint {
  final double x;
  final double y;

  const LatticePoint(this.x, this.y);

  double distanceTo(LatticePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  String toString() => '($x, $y)';
}

/// Precomputes and caches the static geometry, graph structure, faces,
/// and 4-peg straight lines for the game lattice.
@immutable
class BoardGeometry {
  final int size;
  final BoardShape shape;
  final List<GridNode> nodes;
  final List<BoardEdge> edges;
  final List<TriangleFace> triangles;
  final List<BandLine> bands;

  final Map<String, GridNode> nodeMap;
  final Map<String, BoardEdge> edgeMap;
  final Map<String, TriangleFace> triangleMap;
  final Map<String, List<TriangleFace>> edgeToTriangles;
  final Map<String, BandLine> bandMap;
  final Map<String, LatticePoint> nodePositions;

  static final Map<String, BoardGeometry> _cache = {};

  factory BoardGeometry(int size, {BoardShape shape = BoardShape.triangle}) {
    assert(size >= 1, 'Board size must be at least 1');
    final cacheKey = '$size:${shape.name}';
    return _cache.putIfAbsent(
      cacheKey,
      () => BoardGeometry._generate(size, shape),
    );
  }

  factory BoardGeometry.hexagonal([int size = 4]) =>
      BoardGeometry(size, shape: BoardShape.hexagon);

  factory BoardGeometry.triangular([int size = 4]) =>
      BoardGeometry(size, shape: BoardShape.triangle);

  BoardGeometry._({
    required this.size,
    required this.shape,
    required this.nodes,
    required this.edges,
    required this.triangles,
    required this.bands,
    required this.nodeMap,
    required this.edgeMap,
    required this.triangleMap,
    required this.edgeToTriangles,
    required this.bandMap,
    required this.nodePositions,
  });

  factory BoardGeometry._generate(int size, BoardShape shape) {
    if (shape == BoardShape.hexagon) {
      return _generateHexagonal(size);
    } else {
      return _generateTriangular(size);
    }
  }

  static BoardGeometry _generateTriangular(int size) {
    final nodes = <GridNode>[];
    final nodeMap = <String, GridNode>{};
    final nodePositions = <String, LatticePoint>{};

    final h = sqrt(3) / 2;

    for (int r = 0; r <= size; r++) {
      for (int c = 0; c <= r; c++) {
        final node = GridNode(r, c);
        nodes.add(node);
        nodeMap[node.id] = node;
        nodePositions[node.id] = LatticePoint((c - r / 2.0), r * h);
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
      shape: BoardShape.triangle,
      nodes: List.unmodifiable(nodes),
      edges: List.unmodifiable(edges),
      triangles: List.unmodifiable(triangles),
      bands: const [],
      nodeMap: Map.unmodifiable(nodeMap),
      edgeMap: Map.unmodifiable(edgeMap),
      triangleMap: Map.unmodifiable(triangleMap),
      edgeToTriangles: Map.unmodifiable(edgeToTriangles),
      bandMap: const {},
      nodePositions: Map.unmodifiable(nodePositions),
    );
  }

  static BoardGeometry _generateHexagonal(int size) {
    // Authentic Triggle board: size = 4 pegs per outer side (7 rows: 4, 5, 6, 7, 6, 5, 4)
    final nodes = <GridNode>[];
    final nodeMap = <String, GridNode>{};
    final nodePositions = <String, LatticePoint>{};

    final h = sqrt(3) / 2;
    const totalRows = 7;
    const centerRow = 3;

    for (int r = 0; r < totalRows; r++) {
      final pegCount = r <= centerRow ? (4 + r) : (4 + (6 - r));
      final mid = (pegCount - 1) / 2.0;
      for (int c = 0; c < pegCount; c++) {
        final node = GridNode(r, c);
        nodes.add(node);
        nodeMap[node.id] = node;
        final x = (c - mid) * 1.0;
        final y = (r - centerRow) * h;
        nodePositions[node.id] = LatticePoint(x, y);
      }
    }

    final edges = <BoardEdge>[];
    final edgeMap = <String, BoardEdge>{};

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final u = nodes[i];
        final v = nodes[j];
        final pu = nodePositions[u.id]!;
        final pv = nodePositions[v.id]!;
        final d = pu.distanceTo(pv);
        if ((d - 1.0).abs() < 0.05) {
          final edge = BoardEdge(u, v);
          edges.add(edge);
          edgeMap[edge.id] = edge;
        }
      }
    }

    final triangles = <TriangleFace>[];
    final triangleMap = <String, TriangleFace>{};
    final edgeToTriangles = <String, List<TriangleFace>>{};

    for (final edge in edges) {
      edgeToTriangles[edge.id] = [];
    }

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        for (int k = j + 1; k < nodes.length; k++) {
          final u = nodes[i];
          final v = nodes[j];
          final w = nodes[k];

          final e1 = BoardEdge(u, v);
          final e2 = BoardEdge(v, w);
          final e3 = BoardEdge(u, w);

          if (edgeMap.containsKey(e1.id) &&
              edgeMap.containsKey(e2.id) &&
              edgeMap.containsKey(e3.id)) {
            final pu = nodePositions[u.id]!;
            final pv = nodePositions[v.id]!;
            final pw = nodePositions[w.id]!;
            final cy = (pu.y + pv.y + pw.y) / 3;
            final isUpright =
                (pu.y < cy - 0.01) || (pv.y < cy - 0.01) || (pw.y < cy - 0.01);
            final tri = TriangleFace.fromNodes(
              id: 'tri_hex_${u.r}_${u.c}_${v.r}_${v.c}_${w.r}_${w.c}',
              orientation: isUpright
                  ? TriangleOrientation.upright
                  : TriangleOrientation.inverted,
              v1: u,
              v2: v,
              v3: w,
            );
            triangles.add(tri);
            triangleMap[tri.id] = tri;
            for (final edgeId in tri.edgeIds) {
              edgeToTriangles[edgeId]?.add(tri);
            }
          }
        }
      }
    }

    // Precompute all valid 4-peg straight rubber band lines
    final bands = <BandLine>[];
    final bandMap = <String, BandLine>{};

    for (int i = 0; i < nodes.length; i++) {
      for (int j = 0; j < nodes.length; j++) {
        if (i == j) continue;
        final p0 = nodes[i];
        final p1 = nodes[j];
        final pos0 = nodePositions[p0.id]!;
        final pos1 = nodePositions[p1.id]!;
        final d01 = pos0.distanceTo(pos1);
        if ((d01 - 1.0).abs() > 0.05) continue;

        final vx = pos1.x - pos0.x;
        final vy = pos1.y - pos0.y;

        final targetX2 = pos1.x + vx;
        final targetY2 = pos1.y + vy;
        GridNode? p2;
        for (final n in nodes) {
          final pn = nodePositions[n.id]!;
          if ((pn.x - targetX2).abs() < 0.05 &&
              (pn.y - targetY2).abs() < 0.05) {
            p2 = n;
            break;
          }
        }
        if (p2 == null) continue;

        final targetX3 = pos1.x + 2 * vx;
        final targetY3 = pos1.y + 2 * vy;
        GridNode? p3;
        for (final n in nodes) {
          final pn = nodePositions[n.id]!;
          if ((pn.x - targetX3).abs() < 0.05 &&
              (pn.y - targetY3).abs() < 0.05) {
            p3 = n;
            break;
          }
        }
        if (p3 == null) continue;

        if (p0.compareTo(p3) < 0) {
          final band = BandLine(a: p0, b: p3, intermediateNodes: [p1, p2]);
          bands.add(band);
          bandMap[band.id] = band;
        }
      }
    }

    return BoardGeometry._(
      size: size,
      shape: BoardShape.hexagon,
      nodes: List.unmodifiable(nodes),
      edges: List.unmodifiable(edges),
      triangles: List.unmodifiable(triangles),
      bands: List.unmodifiable(bands),
      nodeMap: Map.unmodifiable(nodeMap),
      edgeMap: Map.unmodifiable(edgeMap),
      triangleMap: Map.unmodifiable(triangleMap),
      edgeToTriangles: Map.unmodifiable(edgeToTriangles),
      bandMap: Map.unmodifiable(bandMap),
      nodePositions: Map.unmodifiable(nodePositions),
    );
  }

  /// Finds a 4-peg straight band between two endpoints [a] and [b].
  BandLine? findBandByEndpoints(GridNode a, GridNode b) {
    final start = a.compareTo(b) <= 0 ? a : b;
    final end = a.compareTo(b) <= 0 ? b : a;
    final id = 'band_${start.r}_${start.c}_${end.r}_${end.c}';
    return bandMap[id];
  }

  bool containsNode(GridNode node) => nodeMap.containsKey(node.id);

  bool containsEdge(String edgeId) => edgeMap.containsKey(edgeId);

  bool containsTriangle(String triangleId) =>
      triangleMap.containsKey(triangleId);

  bool containsBand(String bandId) => bandMap.containsKey(bandId);
}
