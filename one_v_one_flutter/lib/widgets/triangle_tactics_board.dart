import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_core/game_core.dart';
import '../theme/app_colors.dart';

class TriangleTacticsBoard extends StatefulWidget {
  final TriangleTacticsState state;
  final String currentUserId;
  final Function(GridNode node1, GridNode node2) onMoveSubmitted;
  final bool isInteractive;

  const TriangleTacticsBoard({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.onMoveSubmitted,
    this.isInteractive = true,
  });

  @override
  State<TriangleTacticsBoard> createState() => _TriangleTacticsBoardState();
}

class _TriangleTacticsBoardState extends State<TriangleTacticsBoard>
    with SingleTickerProviderStateMixin {
  GridNode? _selectedNode;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(widget.state.boardSize);
    final nodePositions = _computeNodePositions(size, geometry);

    // Find clicked node within threshold radius
    const hitRadius = 32.0;
    GridNode? clickedNode;

    for (final entry in nodePositions.entries) {
      final distance = (entry.value - localPosition).distance;
      if (distance <= hitRadius) {
        clickedNode = entry.key;
        break;
      }
    }

    if (clickedNode == null) return;

    if (_selectedNode == null) {
      setState(() {
        _selectedNode = clickedNode;
      });
    } else {
      if (_selectedNode == clickedNode) {
        setState(() {
          _selectedNode = null;
        });
      } else {
        final edge = BoardEdge(_selectedNode!, clickedNode);
        if (edge.isAdjacent && !widget.state.occupiedEdges.contains(edge.id)) {
          final first = _selectedNode!;
          setState(() {
            _selectedNode = null;
          });
          widget.onMoveSubmitted(first, clickedNode);
        } else {
          setState(() {
            _selectedNode = clickedNode;
          });
        }
      }
    }
  }

  Map<GridNode, Offset> _computeNodePositions(
    Size size,
    BoardGeometry geometry,
  ) {
    final n = geometry.size;
    final padding = 40.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    final spacingX = availableWidth / n;
    final rowHeight = spacingX * (sqrt(3) / 2);
    final totalGridHeight = n * rowHeight;

    final offsetY = (availableHeight - totalGridHeight) / 2 + padding;

    final positions = <GridNode, Offset>{};

    for (final node in geometry.nodes) {
      final rowWidth = node.r * spacingX;
      final startX = (size.width - rowWidth) / 2;
      final x = startX + node.c * spacingX;
      final y = offsetY + node.r * rowHeight;
      positions[node] = Offset(x, y);
    }

    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              onTapUp: (details) =>
                  _handleTap(details.localPosition, boardSize),
              child: CustomPaint(
                size: boardSize,
                painter: _BoardPainter(
                  state: widget.state,
                  selectedNode: _selectedNode,
                  pulseValue: _pulseController.value,
                  computePositions: _computeNodePositions,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  final TriangleTacticsState state;
  final GridNode? selectedNode;
  final double pulseValue;
  final Map<GridNode, Offset> Function(Size size, BoardGeometry geometry)
  computePositions;

  _BoardPainter({
    required this.state,
    required this.selectedNode,
    required this.pulseValue,
    required this.computePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardGeometry(state.boardSize);
    final positions = computePositions(size, geometry);

    // 1. Draw claimed triangles filled paths
    for (final entry in state.claimedTriangles.entries) {
      final triId = entry.key;
      final ownerId = entry.value;
      final tri = geometry.triangleMap[triId];
      if (tri == null) continue;

      final p0 = positions[tri.vertices[0]]!;
      final p1 = positions[tri.vertices[1]]!;
      final p2 = positions[tri.vertices[2]]!;

      final path = Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      final isP1 = ownerId == state.player1Id;
      final fillPaint = Paint()
        ..color = isP1
            ? AppColors.player1.withValues(alpha: 0.35)
            : AppColors.player2.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);

      final borderPaint = Paint()
        ..color = isP1 ? AppColors.player1 : AppColors.player2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(path, borderPaint);

      // Centroid icon / dot
      final cx = (p0.dx + p1.dx + p2.dx) / 3;
      final cy = (p0.dy + p1.dy + p2.dy) / 3;
      final centerPaint = Paint()
        ..color = isP1 ? AppColors.player1 : AppColors.player2
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 4.5, centerPaint);
    }

    // 2. Draw unplaced grid guideline edges
    final guidePaint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        final p1 = positions[edge.node1]!;
        final p2 = positions[edge.node2]!;
        canvas.drawLine(p1, p2, guidePaint);
      }
    }

    // 3. Highlight valid candidate connections if node is selected
    if (selectedNode != null) {
      final validCandidatePaint = Paint()
        ..color = AppColors.player1.withValues(alpha: 0.5 + 0.3 * pulseValue)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final selPos = positions[selectedNode!]!;

      for (final edge in geometry.edges) {
        if (!state.occupiedEdges.contains(edge.id)) {
          if (edge.node1 == selectedNode || edge.node2 == selectedNode) {
            final otherNode = edge.node1 == selectedNode
                ? edge.node2
                : edge.node1;
            final otherPos = positions[otherNode]!;
            canvas.drawLine(selPos, otherPos, validCandidatePaint);

            // Pulsing target indicator on target node
            final targetRing = Paint()
              ..color = AppColors.player1.withValues(alpha: 0.6 * pulseValue)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;
            canvas.drawCircle(otherPos, 14.0 + 4.0 * pulseValue, targetRing);
          }
        }
      }
    }

    // 4. Draw placed occupied edges (rubber-band bands with glow)
    final lastMoveEdgeId = state.moveHistory.isNotEmpty
        ? state.moveHistory.last.edgeId
        : null;

    for (final edge in geometry.edges) {
      if (state.occupiedEdges.contains(edge.id)) {
        final p1 = positions[edge.node1]!;
        final p2 = positions[edge.node2]!;

        final isLastMove = edge.id == lastMoveEdgeId;

        // Determine edge color from who placed it
        Color edgeColor = AppColors.pegNode;
        for (final m in state.moveHistory) {
          if (m.edgeId == edge.id) {
            edgeColor = m.playerId == state.player1Id
                ? AppColors.player1
                : AppColors.player2;
            break;
          }
        }

        // Glow
        final glowPaint = Paint()
          ..color = edgeColor.withValues(alpha: isLastMove ? 0.6 : 0.3)
          ..strokeWidth = isLastMove ? 8.0 + 2.0 * pulseValue : 6.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, glowPaint);

        // Solid line
        final edgePaint = Paint()
          ..color = edgeColor
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, edgePaint);
      }
    }

    // 5. Draw pegs (lattice nodes)
    final nodeBasePaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.fill;

    final nodeBorderPaint = Paint()
      ..color = AppColors.pegNode
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final entry in positions.entries) {
      final node = entry.key;
      final pos = entry.value;

      final isSelected = selectedNode == node;

      if (isSelected) {
        final selectedGlow = Paint()
          ..color = AppColors.player1.withValues(alpha: 0.5 + 0.4 * pulseValue)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 14.0 + 2.0 * pulseValue, selectedGlow);
      }

      canvas.drawCircle(pos, 7.5, nodeBasePaint);
      canvas.drawCircle(
        pos,
        7.5,
        isSelected
            ? (Paint()
                ..color = AppColors.player1
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0)
            : nodeBorderPaint,
      );

      // Core white highlight
      canvas.drawCircle(pos, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.pulseValue != pulseValue;
  }
}
