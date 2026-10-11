import 'package:meta/meta.dart';
import '../board/board_edge.dart';
import '../board/grid_node.dart';

/// Represents an intended move by a player to place an edge between two nodes.
@immutable
class TriangleTacticsMove {
  final GridNode node1;
  final GridNode node2;
  final String? clientRequestId;

  const TriangleTacticsMove({
    required this.node1,
    required this.node2,
    this.clientRequestId,
  });

  BoardEdge get edge => BoardEdge(node1, node2);
  String get edgeId => edge.id;

  Map<String, dynamic> toJson() => {
    'node1': node1.toJson(),
    'node2': node2.toJson(),
    if (clientRequestId != null) 'clientRequestId': clientRequestId,
  };

  factory TriangleTacticsMove.fromJson(Map<String, dynamic> json) =>
      TriangleTacticsMove(
        node1: GridNode.fromJson(json['node1'] as Map<String, dynamic>),
        node2: GridNode.fromJson(json['node2'] as Map<String, dynamic>),
        clientRequestId: json['clientRequestId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriangleTacticsMove &&
          runtimeType == other.runtimeType &&
          edge == other.edge;

  @override
  int get hashCode => edge.hashCode;

  @override
  String toString() => 'Move($node1 <-> $node2)';
}
