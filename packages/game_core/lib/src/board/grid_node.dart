import 'package:meta/meta.dart';

/// Represents a discrete node/peg on the triangular lattice.
@immutable
class GridNode implements Comparable<GridNode> {
  final int r;
  final int c;

  const GridNode(this.r, this.c)
    : assert(r >= 0, 'Row must be non-negative'),
      assert(c >= 0 && c <= r, 'Column must be between 0 and row');

  String get id => 'node_${r}_$c';

  @override
  int compareTo(GridNode other) {
    if (r != other.r) {
      return r.compareTo(other.r);
    }
    return c.compareTo(other.c);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridNode &&
          runtimeType == other.runtimeType &&
          r == other.r &&
          c == other.c;

  @override
  int get hashCode => Object.hash(r, c);

  @override
  String toString() => '($r, $c)';

  Map<String, dynamic> toJson() => {'r': r, 'c': c};

  factory GridNode.fromJson(Map<String, dynamic> json) =>
      GridNode(json['r'] as int, json['c'] as int);
}
