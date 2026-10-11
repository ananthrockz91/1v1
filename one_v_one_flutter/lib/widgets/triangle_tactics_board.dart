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
  GridNode? _dragStartNode;
  Offset? _dragPosition;
  GridNode? _hoveredSnapNode;
  bool _isDragging = false;

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

  GridNode? _findNearestNode(
    Offset position,
    Map<GridNode, Offset> nodePositions, {
    double threshold = 34.0,
  }) {
    GridNode? nearest;
    double minDistance = double.infinity;

    for (final entry in nodePositions.entries) {
      final distance = (entry.value - position).distance;
      if (distance <= threshold && distance < minDistance) {
        minDistance = distance;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  List<GridNode> _getValidAdjacentTargets(
    GridNode source,
    BoardGeometry geometry,
  ) {
    final targets = <GridNode>[];
    for (final edge in geometry.edges) {
      if (!widget.state.occupiedEdges.contains(edge.id)) {
        if (edge.node1 == source) {
          targets.add(edge.node2);
        } else if (edge.node2 == source) {
          targets.add(edge.node1);
        }
      }
    }
    return targets;
  }

  void _handleTap(Offset localPosition, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(widget.state.boardSize);
    final nodePositions = _computeNodePositions(size, geometry);
    final clickedNode = _findNearestNode(localPosition, nodePositions);

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

  void _onPanDown(DragDownDetails details, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(widget.state.boardSize);
    final nodePositions = _computeNodePositions(size, geometry);
    final nearest = _findNearestNode(details.localPosition, nodePositions);

    if (nearest != null) {
      _dragStartNode = nearest;
      _dragPosition = details.localPosition;
      _hoveredSnapNode = null;
      _isDragging = false;
    }
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(widget.state.boardSize);
    final nodePositions = _computeNodePositions(size, geometry);

    // If _dragStartNode wasn't set in onPanDown, try from details
    _dragStartNode ??= _findNearestNode(details.localPosition, nodePositions);

    if (_dragStartNode != null) {
      setState(() {
        _dragPosition = details.localPosition;
        _hoveredSnapNode = null;
        _isDragging = false;
        _selectedNode ??= _dragStartNode;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragStartNode == null) return;

    final geometry = BoardGeometry(widget.state.boardSize);
    final nodePositions = _computeNodePositions(size, geometry);
    final startPos = nodePositions[_dragStartNode!];
    if (startPos == null) return;

    final distanceDragged = (details.localPosition - startPos).distance;

    final validTargets = _getValidAdjacentTargets(_dragStartNode!, geometry);
    GridNode? snapTarget;
    double minTargetDist = 42.0;

    for (final target in validTargets) {
      final targetPos = nodePositions[target];
      if (targetPos != null) {
        final d = (details.localPosition - targetPos).distance;
        if (d <= minTargetDist) {
          minTargetDist = d;
          snapTarget = target;
        }
      }
    }

    setState(() {
      _isDragging = distanceDragged > 8.0;
      _dragPosition = details.localPosition;
      _hoveredSnapNode = snapTarget;
    });
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    if (_dragStartNode == null) return;

    final start = _dragStartNode!;
    GridNode? snapped = _hoveredSnapNode;

    if (snapped == null && _dragPosition != null) {
      final geometry = BoardGeometry(widget.state.boardSize);
      final nodePositions = _computeNodePositions(size, geometry);
      final validTargets = _getValidAdjacentTargets(start, geometry);
      double minD = 44.0;
      for (final t in validTargets) {
        final tp = nodePositions[t];
        if (tp != null) {
          final d = (_dragPosition! - tp).distance;
          if (d <= minD) {
            minD = d;
            snapped = t;
          }
        }
      }
    }

    final wasDragging = _isDragging;

    setState(() {
      _dragStartNode = null;
      _dragPosition = null;
      _hoveredSnapNode = null;
      _isDragging = false;
    });

    if (wasDragging && snapped != null) {
      setState(() {
        _selectedNode = null;
      });
      widget.onMoveSubmitted(start, snapped);
    } else if (!wasDragging) {
      if (_selectedNode == start && snapped != null) {
        setState(() {
          _selectedNode = null;
        });
        widget.onMoveSubmitted(start, snapped);
      }
    } else {
      setState(() {
        _selectedNode = null;
      });
    }
  }

  void _onPanCancel() {
    setState(() {
      _dragStartNode = null;
      _dragPosition = null;
      _hoveredSnapNode = null;
      _isDragging = false;
    });
  }

  Map<GridNode, Offset> _computeNodePositions(
    Size size,
    BoardGeometry geometry,
  ) {
    final n = geometry.size;
    const padding = 40.0;
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
              onPanDown: (details) => _onPanDown(details, boardSize),
              onPanStart: (details) => _onPanStart(details, boardSize),
              onPanUpdate: (details) => _onPanUpdate(details, boardSize),
              onPanEnd: (details) => _onPanEnd(details, boardSize),
              onPanCancel: _onPanCancel,
              child: CustomPaint(
                size: boardSize,
                painter: _BoardPainter(
                  state: widget.state,
                  selectedNode: _selectedNode,
                  dragStartNode: _dragStartNode,
                  dragPosition: _dragPosition,
                  hoveredSnapNode: _hoveredSnapNode,
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
  final GridNode? dragStartNode;
  final Offset? dragPosition;
  final GridNode? hoveredSnapNode;
  final double pulseValue;
  final Map<GridNode, Offset> Function(Size size, BoardGeometry geometry)
  computePositions;

  _BoardPainter({
    required this.state,
    required this.selectedNode,
    required this.dragStartNode,
    required this.dragPosition,
    required this.hoveredSnapNode,
    required this.pulseValue,
    required this.computePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardGeometry(state.boardSize);
    final positions = computePositions(size, geometry);

    final activeColor = state.activePlayerId == state.player1Id
        ? AppColors.player1
        : AppColors.player2;

    // 1. Draw physical board tray bevel & surface
    _drawBoardTray(canvas, size);

    // 2. Draw Y-groove sockets in every triangular cell (from reference image)
    _drawYGrooves(canvas, geometry, positions);

    // 3. Draw claimed triangles with 3D Arrow / Shield tokens
    _drawClaimedTrianglesAndTokens(canvas, geometry, positions);

    // 4. Draw subtle grid guideline channels
    _drawGuideChannels(canvas, geometry, positions);

    // 5. Draw placed silicone rubber bands (occupied edges)
    _drawPlacedRubberBands(canvas, geometry, positions);

    // 6. Draw candidate targets / guide beacons
    final currentFocusNode = dragStartNode ?? selectedNode;
    if (currentFocusNode != null) {
      _drawCandidateBeacons(
        canvas,
        geometry,
        positions,
        currentFocusNode,
        activeColor,
      );
    }

    // 7. Draw active dragging rubber band (elastic stretch animation)
    if (dragStartNode != null && dragPosition != null) {
      _drawDraggingRubberBand(
        canvas,
        positions,
        dragStartNode!,
        dragPosition!,
        hoveredSnapNode,
        activeColor,
      );
    }

    // 8. Draw 3D tactile pegs
    _drawPegs(
      canvas,
      positions,
      currentFocusNode,
      hoveredSnapNode,
      activeColor,
    );
  }

  void _drawBoardTray(Canvas canvas, Size size) {
    const pad = 10.0;
    final boardRect = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );
    final rrect = RRect.fromRectAndRadius(boardRect, const Radius.circular(24));

    // Outer tray bevel drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(rrect.shift(const Offset(0, 4)), shadowPaint);

    // Dark molded board surface gradient
    final trayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF161B24), Color(0xFF0F1218), Color(0xFF0B0D12)],
    );
    final trayPaint = Paint()
      ..shader = trayGradient.createShader(boardRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, trayPaint);

    // Perimeter tactile rim stroke
    final rimPaint = Paint()
      ..color = const Color(0xFF283142)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, rimPaint);
  }

  void _drawYGrooves(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
  ) {
    final groovePaint = Paint()
      ..color = const Color(0xFF07090D)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final grooveShine = Paint()
      ..color = const Color(0xFF242C3B).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final centerPinPaint = Paint()
      ..color = const Color(0xFF07090D)
      ..style = PaintingStyle.fill;

    for (final tri in geometry.triangles) {
      final p0 = positions[tri.vertices[0]];
      final p1 = positions[tri.vertices[1]];
      final p2 = positions[tri.vertices[2]];
      if (p0 == null || p1 == null || p2 == null) continue;

      final centroid = Offset(
        (p0.dx + p1.dx + p2.dx) / 3,
        (p0.dy + p1.dy + p2.dy) / 3,
      );

      // Three branch endpoints radiating from centroid toward the 3 vertices
      const armFactor = 0.42;
      final arm0 = Offset.lerp(centroid, p0, armFactor)!;
      final arm1 = Offset.lerp(centroid, p1, armFactor)!;
      final arm2 = Offset.lerp(centroid, p2, armFactor)!;

      // Draw dark recessed grooves
      canvas.drawLine(centroid, arm0, groovePaint);
      canvas.drawLine(centroid, arm1, groovePaint);
      canvas.drawLine(centroid, arm2, groovePaint);

      // Subtle bottom-edge rim highlight
      canvas.drawLine(
        centroid + const Offset(0, 1),
        arm0 + const Offset(0, 1),
        grooveShine,
      );
      canvas.drawLine(
        centroid + const Offset(0, 1),
        arm1 + const Offset(0, 1),
        grooveShine,
      );
      canvas.drawLine(
        centroid + const Offset(0, 1),
        arm2 + const Offset(0, 1),
        grooveShine,
      );

      // Center socket pin hole
      canvas.drawCircle(centroid, 3.2, centerPinPaint);
    }
  }

  void _drawClaimedTrianglesAndTokens(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
  ) {
    for (final entry in state.claimedTriangles.entries) {
      final triId = entry.key;
      final ownerId = entry.value;
      final tri = geometry.triangleMap[triId];
      if (tri == null) continue;

      final p0 = positions[tri.vertices[0]]!;
      final p1 = positions[tri.vertices[1]]!;
      final p2 = positions[tri.vertices[2]]!;

      final isP1 = ownerId == state.player1Id;
      final baseColor = isP1 ? AppColors.player1 : AppColors.player2;

      // 1. Subtle territory fill with colored border
      final triPath = Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      final fillPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawPath(triPath, fillPaint);

      final borderPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(triPath, borderPaint);

      // 2. 3D Molded plastic Arrow/Shield token inserted into the socket
      final centroid = Offset(
        (p0.dx + p1.dx + p2.dx) / 3,
        (p0.dy + p1.dy + p2.dy) / 3,
      );

      _draw3DToken(canvas, centroid, tri.orientation, baseColor);
    }
  }

  void _draw3DToken(
    Canvas canvas,
    Offset center,
    TriangleOrientation orientation,
    Color baseColor,
  ) {
    const s = 14.0; // Token scale
    final isUp = orientation == TriangleOrientation.upright;

    // Token geometry: 3D arrow head with spine and wings
    final apex = isUp
        ? center + const Offset(0, -s * 1.05)
        : center + const Offset(0, s * 1.05);
    final leftWing = isUp
        ? center + const Offset(-s * 0.9, s * 0.75)
        : center + const Offset(-s * 0.9, -s * 0.75);
    final rightWing = isUp
        ? center + const Offset(s * 0.9, s * 0.75)
        : center + const Offset(s * 0.9, -s * 0.75);
    final notch = isUp
        ? center + const Offset(0, s * 0.35)
        : center + const Offset(0, -s * 0.35);

    // Drop shadow
    const shadowOffset = Offset(1.5, 3.0);
    final shadowPath = Path()
      ..moveTo(apex.dx + shadowOffset.dx, apex.dy + shadowOffset.dy)
      ..lineTo(rightWing.dx + shadowOffset.dx, rightWing.dy + shadowOffset.dy)
      ..lineTo(notch.dx + shadowOffset.dx, notch.dy + shadowOffset.dy)
      ..lineTo(leftWing.dx + shadowOffset.dx, leftWing.dy + shadowOffset.dy)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Left facet (deeper tone with bevel)
    final leftFacet = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(notch.dx, notch.dy)
      ..close();

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: 0.9),
          Color.lerp(baseColor, Colors.black, 0.35)!,
        ],
      ).createShader(Rect.fromPoints(apex, leftWing))
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftFacet, leftPaint);

    // Right facet (bright specular shine)
    final rightFacet = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(rightWing.dx, rightWing.dy)
      ..lineTo(notch.dx, notch.dy)
      ..close();

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.lerp(baseColor, Colors.white, 0.45)!,
          baseColor,
        ],
      ).createShader(Rect.fromPoints(apex, rightWing))
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightFacet, rightPaint);

    // Spine highlight ridge
    final spinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(apex, notch, spinePaint);

    // Center circular jewel / rivet
    canvas.drawCircle(
      center,
      3.2,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      center,
      1.6,
      Paint()..color = baseColor,
    );
  }

  void _drawGuideChannels(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
  ) {
    final guidePaint = Paint()
      ..color = const Color(0xFF1E2634)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        final p1 = positions[edge.node1];
        final p2 = positions[edge.node2];
        if (p1 != null && p2 != null) {
          canvas.drawLine(p1, p2, guidePaint);
        }
      }
    }
  }

  void _drawPlacedRubberBands(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
  ) {
    final lastMoveEdgeId = state.moveHistory.isNotEmpty
        ? state.moveHistory.last.edgeId
        : null;

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) continue;

      final p1 = positions[edge.node1];
      final p2 = positions[edge.node2];
      if (p1 == null || p2 == null) continue;

      final isLastMove = edge.id == lastMoveEdgeId;

      Color bandColor = AppColors.pegNode;
      for (final m in state.moveHistory) {
        if (m.edgeId == edge.id) {
          bandColor = m.playerId == state.player1Id
              ? AppColors.player1
              : AppColors.player2;
          break;
        }
      }

      // 1. Drop shadow onto board plate
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawLine(
        p1 + const Offset(1.5, 2.5),
        p2 + const Offset(1.5, 2.5),
        shadowPaint,
      );

      // 2. Active / Last move glowing aura
      if (isLastMove) {
        final glowPaint = Paint()
          ..color = bandColor.withValues(alpha: 0.6 + 0.3 * pulseValue)
          ..strokeWidth = 10.0 + 3.0 * pulseValue
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, glowPaint);
      } else {
        final ambientGlow = Paint()
          ..color = bandColor.withValues(alpha: 0.22)
          ..strokeWidth = 7.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, ambientGlow);
      }

      // 3. Main silicone rubber band body
      final bodyPaint = Paint()
        ..color = bandColor
        ..strokeWidth = 5.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, bodyPaint);

      // 4. Specular core highlight line (tubular rubber elasticity)
      final coreHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, coreHighlight);

      // 5. Peg collars (band wrapping around pegs)
      canvas.drawCircle(
        p1,
        8.0,
        Paint()
          ..color = bandColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      canvas.drawCircle(
        p2,
        8.0,
        Paint()
          ..color = bandColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  void _drawCandidateBeacons(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
    GridNode focusNode,
    Color activeColor,
  ) {
    final focusPos = positions[focusNode];
    if (focusPos == null) return;

    final candidatePaint = Paint()
      ..color = activeColor.withValues(alpha: 0.4 + 0.3 * pulseValue)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        if (edge.node1 == focusNode || edge.node2 == focusNode) {
          final otherNode = edge.node1 == focusNode ? edge.node2 : edge.node1;
          final otherPos = positions[otherNode];
          if (otherPos != null) {
            // Subtle trajectory ray
            canvas.drawLine(focusPos, otherPos, candidatePaint);

            // Pulsing target beacon halo on the neighbor peg
            final targetBeacon = Paint()
              ..color = activeColor.withValues(alpha: 0.45 * pulseValue)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0;
            canvas.drawCircle(otherPos, 14.0 + 4.0 * pulseValue, targetBeacon);
          }
        }
      }
    }
  }

  void _drawDraggingRubberBand(
    Canvas canvas,
    Map<GridNode, Offset> positions,
    GridNode startNode,
    Offset currentDragPos,
    GridNode? snapNode,
    Color activeColor,
  ) {
    final startPos = positions[startNode];
    if (startPos == null) return;

    final targetPos = snapNode != null ? positions[snapNode]! : currentDragPos;
    final dist = (targetPos - startPos).distance;

    // Dynamic elastic tension thickness: narrows slightly when stretched long
    final tensionWidth = (5.5 - (dist / 320.0).clamp(0.0, 1.0) * 1.6).clamp(
      3.6,
      5.5,
    );

    // 1. Drop shadow under stretched band
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..strokeWidth = tensionWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
      startPos + const Offset(1.5, 2.5),
      targetPos + const Offset(1.5, 2.5),
      shadowPaint,
    );

    // 2. Electric neon glow
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: snapNode != null ? 0.75 : 0.45)
      ..strokeWidth = tensionWidth + 6.0 + 2.0 * pulseValue
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, glowPaint);

    // 3. Stretched elastic band body
    final bodyPaint = Paint()
      ..color = activeColor
      ..strokeWidth = tensionWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, bodyPaint);

    // 4. White core highlight line
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = (tensionWidth * 0.35).clamp(1.2, 1.8)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, corePaint);

    // 5. If snapped, draw energetic lock beacon around snap peg
    if (snapNode != null) {
      final snapAura = Paint()
        ..color = activeColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(targetPos, 16.0 + 2.0 * pulseValue, snapAura);

      final snapCenter = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(targetPos, 4.0, snapCenter);
    }
  }

  void _drawPegs(
    Canvas canvas,
    Map<GridNode, Offset> positions,
    GridNode? focusNode,
    GridNode? snapNode,
    Color activeColor,
  ) {
    const pegRadius = 8.5;

    for (final entry in positions.entries) {
      final node = entry.key;
      final pos = entry.value;

      final isFocused = focusNode == node;
      final isSnapped = snapNode == node;

      // 1. Base drop shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        pos + const Offset(1.5, 2.8),
        pegRadius + 0.5,
        shadowPaint,
      );

      // 2. Focus / Active glow aura
      if (isFocused) {
        final auraPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.45 + 0.35 * pulseValue)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 16.0 + 2.0 * pulseValue, auraPaint);
      } else if (isSnapped) {
        final snapGlow = Paint()
          ..color = activeColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 17.0 + 2.0 * pulseValue, snapGlow);
      }

      // 3. Peg cylinder body (dark metallic graphite gradient)
      final pegGradient = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.9,
        colors: const [
          Color(0xFF4C586E),
          Color(0xFF2B3342),
          Color(0xFF161A22),
        ],
      );
      final pegPaint = Paint()
        ..shader = pegGradient.createShader(
          Rect.fromCircle(center: pos, radius: pegRadius),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, pegRadius, pegPaint);

      // 4. Peg outer rim stroke
      final rimColor = isFocused || isSnapped
          ? activeColor
          : const Color(0xFF64748B).withValues(alpha: 0.7);
      final rimStroke = Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isFocused || isSnapped ? 2.5 : 1.2;
      canvas.drawCircle(pos, pegRadius, rimStroke);

      // 5. Specular highlight crescent / glint at top-left
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos + const Offset(-2.5, -2.5), 1.8, glintPaint);

      // Inner peg core hole/recess
      canvas.drawCircle(
        pos,
        2.2,
        Paint()..color = const Color(0xFF0F131A),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.dragStartNode != dragStartNode ||
        oldDelegate.dragPosition != dragPosition ||
        oldDelegate.hoveredSnapNode != hoveredSnapNode ||
        oldDelegate.pulseValue != pulseValue;
  }
}
