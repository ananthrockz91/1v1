import 'package:meta/meta.dart';
import 'grid_node.dart';

/// Represents a potential or placed edge between two adjacent nodes on the board.
/// Always canonically orders nodes so node1 <= node2.
@immutable
class BoardEdge {
  final GridNode node1;
  final GridNode node2;

  BoardEdge._(this.node1, this.node2);

  factory BoardEdge(GridNode a, GridNode b) {
    if (a.compareTo(b) <= 0) {
      return BoardEdge._(a, b);
    } else {
      return BoardEdge._(b, a);
    }
  }

  String get id => 'edge_${node1.r}_${node1.c}_${node2.r}_${node2.c}';

  /// Returns true if this edge connects immediately adjacent nodes.
  /// Valid connections on an equilateral lattice:
  /// 1. Horizontal: (r, c) to (r, c+1)
  /// 2. Down-left: (r, c) to (r+1, c)
  /// 3. Down-right: (r, c) to (r+1, c+1)
  bool get isAdjacent {
    final dr = node2.r - node1.r;
    final dc = node2.c - node1.c;
    if (dr == 0 && dc == 1) return true; // Horizontal
    if (dr == 1 && dc == 0) return true; // Down-left
    if (dr == 1 && dc == 1) return true; // Down-right
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardEdge &&
          runtimeType == other.runtimeType &&
          node1 == other.node1 &&
          node2 == other.node2;

  @override
  int get hashCode => Object.hash(node1, node2);

  @override
  String toString() => '$node1 <-> $node2';

  Map<String, dynamic> toJson() => {
    'node1': node1.toJson(),
    'node2': node2.toJson(),
  };

  factory BoardEdge.fromJson(Map<String, dynamic> json) => BoardEdge(
    GridNode.fromJson(json['node1'] as Map<String, dynamic>),
    GridNode.fromJson(json['node2'] as Map<String, dynamic>),
  );
}
