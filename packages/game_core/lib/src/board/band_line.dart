import 'package:meta/meta.dart';
import 'board_edge.dart';
import 'grid_node.dart';

/// Represents a straight rubber band line spanning 4 collinear pegs
/// (covering 3 elementary unit edges) on the game board.
@immutable
class BandLine implements Comparable<BandLine> {
  final String id;
  final GridNode start;
  final GridNode end;
  final List<GridNode> nodes; // 4 nodes in order [P0, P1, P2, P3]
  final List<BoardEdge> edges; // 3 edges [E0, E1, E2]

  const BandLine._({
    required this.id,
    required this.start,
    required this.end,
    required this.nodes,
    required this.edges,
  });

  factory BandLine({
    required GridNode a,
    required GridNode b,
    required List<GridNode> intermediateNodes,
  }) {
    final allNodes = [a, ...intermediateNodes, b];
    if (a.compareTo(b) > 0) {
      allNodes.sort((x, y) => x.compareTo(y));
    }
    final s = allNodes.first;
    final e = allNodes.last;
    final edgeList = <BoardEdge>[];
    for (int i = 0; i < allNodes.length - 1; i++) {
      edgeList.add(BoardEdge(allNodes[i], allNodes[i + 1]));
    }
    return BandLine._(
      id: 'band_${s.r}_${s.c}_${e.r}_${e.c}',
      start: s,
      end: e,
      nodes: List.unmodifiable(allNodes),
      edges: List.unmodifiable(edgeList),
    );
  }

  Set<String> get edgeIds => edges.map((e) => e.id).toSet();

  bool containsNode(GridNode n) => nodes.contains(n);

  @override
  int compareTo(BandLine other) => id.compareTo(other.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BandLine && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BandLine($start -> $end)';
}
