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
    with TickerProviderStateMixin {
  GridNode? _selectedNode;
  GridNode? _dragStartNode;
  Offset? _dragPosition;
  GridNode? _hoveredSnapNode;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late AnimationController _conquerController;
  Set<String> _previousClaimedTriangleIds = {};
  Set<String> _newlyClaimedTriangleIds = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _conquerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _previousClaimedTriangleIds = widget.state.claimedTriangles.keys.toSet();
  }

  @override
  void didUpdateWidget(TriangleTacticsBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldClaimed = oldWidget.state.claimedTriangles.keys.toSet();
    final currentClaimed = widget.state.claimedTriangles.keys.toSet();

    if (currentClaimed.length < oldClaimed.length) {
      _previousClaimedTriangleIds = currentClaimed;
      _newlyClaimedTriangleIds.clear();
    } else {
      final newlyClaimed = currentClaimed.difference(
        _previousClaimedTriangleIds,
      );
      if (newlyClaimed.isNotEmpty) {
        _newlyClaimedTriangleIds = newlyClaimed;
        _previousClaimedTriangleIds = currentClaimed;
        _conquerController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _conquerController.dispose();
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

  List<GridNode> _getValidTargets(
    GridNode source,
    BoardGeometry geometry,
  ) {
    final targets = <GridNode>[];
    if (widget.state.boardShape == BoardShape.hexagon) {
      for (final band in geometry.bands) {
        if (!widget.state.occupiedBands.contains(band.id)) {
          if (band.start == source) {
            targets.add(band.end);
          } else if (band.end == source) {
            targets.add(band.start);
          }
        }
      }
    } else {
      for (final edge in geometry.edges) {
        if (!widget.state.occupiedEdges.contains(edge.id)) {
          if (edge.node1 == source) {
            targets.add(edge.node2);
          } else if (edge.node2 == source) {
            targets.add(edge.node1);
          }
        }
      }
    }
    return targets;
  }

  void _handleTap(Offset localPosition, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(
      widget.state.boardSize,
      shape: widget.state.boardShape,
    );
    final nodePositions = _computeNodePositions(size, geometry);
    final clickedNode = _findNearestNode(localPosition, nodePositions);

    if (clickedNode == null) return;

    if (_selectedNode == null) {
      final validTargets = _getValidTargets(clickedNode, geometry);
      if (validTargets.isNotEmpty) {
        setState(() {
          _selectedNode = clickedNode;
        });
      }
    } else {
      if (_selectedNode == clickedNode) {
        setState(() {
          _selectedNode = null;
        });
      } else {
        final validTargets = _getValidTargets(_selectedNode!, geometry);
        if (validTargets.contains(clickedNode)) {
          final first = _selectedNode!;
          setState(() {
            _selectedNode = null;
          });
          widget.onMoveSubmitted(first, clickedNode);
        } else {
          // Check if clickedNode has valid targets and switch selection
          final newTargets = _getValidTargets(clickedNode, geometry);
          if (newTargets.isNotEmpty) {
            setState(() {
              _selectedNode = clickedNode;
            });
          } else {
            setState(() {
              _selectedNode = null;
            });
          }
        }
      }
    }
  }

  void _onPanDown(DragDownDetails details, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(
      widget.state.boardSize,
      shape: widget.state.boardShape,
    );
    final nodePositions = _computeNodePositions(size, geometry);
    final nearest = _findNearestNode(details.localPosition, nodePositions);

    if (nearest != null) {
      final targets = _getValidTargets(nearest, geometry);
      if (targets.isNotEmpty) {
        _dragStartNode = nearest;
        _dragPosition = details.localPosition;
        _hoveredSnapNode = null;
        _isDragging = false;
      }
    }
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;

    final geometry = BoardGeometry(
      widget.state.boardSize,
      shape: widget.state.boardShape,
    );
    final nodePositions = _computeNodePositions(size, geometry);

    _dragStartNode ??= _findNearestNode(details.localPosition, nodePositions);

    if (_dragStartNode != null) {
      final targets = _getValidTargets(_dragStartNode!, geometry);
      if (targets.isNotEmpty) {
        setState(() {
          _dragPosition = details.localPosition;
          _hoveredSnapNode = null;
          _isDragging = false;
          _selectedNode ??= _dragStartNode;
        });
      } else {
        _dragStartNode = null;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragStartNode == null) return;

    final geometry = BoardGeometry(
      widget.state.boardSize,
      shape: widget.state.boardShape,
    );
    final nodePositions = _computeNodePositions(size, geometry);
    final startPos = nodePositions[_dragStartNode!];
    if (startPos == null) return;

    final distanceDragged = (details.localPosition - startPos).distance;

    final validTargets = _getValidTargets(_dragStartNode!, geometry);
    GridNode? snapTarget;
    double minTargetDist = 48.0;

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
      final geometry = BoardGeometry(
        widget.state.boardSize,
        shape: widget.state.boardShape,
      );
      final nodePositions = _computeNodePositions(size, geometry);
      final validTargets = _getValidTargets(start, geometry);
      double minD = 52.0;
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
    final positions = <GridNode, Offset>{};
    final center = Offset(size.width / 2, size.height / 2);

    if (geometry.shape == BoardShape.hexagon) {
      final minDimension = min(size.width, size.height);
      const padding = 28.0;
      final availableSize = minDimension - padding * 2;
      // In normalized coordinates, width span is 6.0 and height span is ~5.196
      final spacing = availableSize / 6.4;

      for (final node in geometry.nodes) {
        final pt = geometry.nodePositions[node.id];
        if (pt != null) {
          positions[node] = center + Offset(pt.x * spacing, pt.y * spacing);
        }
      }
      return positions;
    }

    // Triangular layout fallback
    final n = geometry.size;
    const padding = 40.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    final spacingX = availableWidth / n;
    final rowHeight = spacingX * (sqrt(3) / 2);
    final totalGridHeight = n * rowHeight;
    final offsetY = (availableHeight - totalGridHeight) / 2 + padding;

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
      animation: Listenable.merge([_pulseController, _conquerController]),
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
                  newlyClaimedTriangleIds: _newlyClaimedTriangleIds,
                  conquerAnimationProgress: _conquerController.isAnimating
                      ? _conquerController.value
                      : 1.0,
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
  final Set<String> newlyClaimedTriangleIds;
  final double conquerAnimationProgress;
  final Map<GridNode, Offset> Function(Size size, BoardGeometry geometry)
  computePositions;

  _BoardPainter({
    required this.state,
    required this.selectedNode,
    required this.dragStartNode,
    required this.dragPosition,
    required this.hoveredSnapNode,
    required this.pulseValue,
    this.newlyClaimedTriangleIds = const {},
    this.conquerAnimationProgress = 1.0,
    required this.computePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = BoardGeometry(state.boardSize, shape: state.boardShape);
    final positions = computePositions(size, geometry);

    final activeColor = state.activePlayerId == state.player1Id
        ? AppColors.player1
        : AppColors.player2;

    // 1. Draw physical hexagonal board tray & surface
    _drawBoardTray(canvas, size, geometry);

    // 2. Draw Y-groove sockets in every triangular cell
    _drawYGrooves(canvas, geometry, positions);

    // 3. Draw claimed triangles with 3D colored tokens
    _drawClaimedTrianglesAndTokens(canvas, geometry, positions);

    // 4. Draw subtle lattice guideline channels
    _drawGuideChannels(canvas, geometry, positions);

    // 5. Draw placed silicone rubber bands (spanning 4 pegs in a straight line)
    _drawPlacedRubberBands(canvas, geometry, positions);

    // 6. Draw candidate 4-peg straight line beacons when a peg is selected
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

    // 7. Tactical Threat Radar (Preview capture vs danger threat)
    if (currentFocusNode != null && hoveredSnapNode != null) {
      _drawThreatRadar(
        canvas,
        geometry,
        positions,
        currentFocusNode,
        hoveredSnapNode!,
        activeColor,
      );
    }

    // 8. Draw active dragging rubber band (elastic stretch animation)
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

    // 9. Draw 3D tactile cylindrical pegs
    _drawPegs(
      canvas,
      positions,
      currentFocusNode,
      hoveredSnapNode,
      activeColor,
    );
  }

  Path _getHexagonPath(Offset center, double radius, double cornerRadius) {
    // 6 vertices of regular flat-top/flat-bottom hexagon:
    // Angles: -150, -30, 30, 90, 150, 210 (or -90 flat? In Image 2, top is horizontal flat edge!)
    // Top-left: (-R/2, -R*sqrt(3)/2)
    // Top-right: (R/2, -R*sqrt(3)/2)
    // Far-right: (R, 0)
    // Bottom-right: (R/2, R*sqrt(3)/2)
    // Bottom-left: (-R/2, R*sqrt(3)/2)
    // Far-left: (-R, 0)
    final h = sqrt(3) / 2 * radius;
    final halfR = radius / 2;

    final vertices = [
      center + Offset(-halfR, -h), // 0: Top-left
      center + Offset(halfR, -h), // 1: Top-right
      center + Offset(radius, 0), // 2: Right
      center + Offset(halfR, h), // 3: Bottom-right
      center + Offset(-halfR, h), // 4: Bottom-left
      center + Offset(-radius, 0), // 5: Left
    ];

    final path = Path();
    for (int i = 0; i < vertices.length; i++) {
      final prev = vertices[(i - 1 + vertices.length) % vertices.length];
      final curr = vertices[i];
      final next = vertices[(i + 1) % vertices.length];

      final vPrev = (prev - curr);
      final vPrevNorm = vPrev / vPrev.distance;
      final start = curr + vPrevNorm * cornerRadius;

      final vNext = (next - curr);
      final vNextNorm = vNext / vNext.distance;
      final end = curr + vNextNorm * cornerRadius;

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, end.dx, end.dy);
    }
    path.close();
    return path;
  }

  void _drawBoardTray(Canvas canvas, Size size, BoardGeometry geometry) {
    final center = Offset(size.width / 2, size.height / 2);

    if (geometry.shape == BoardShape.hexagon) {
      final minDimension = min(size.width, size.height);
      final radius = (minDimension / 2) - 8.0;

      final hexPath = _getHexagonPath(center, radius, 22.0);

      // 1. Outer tray drop shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawPath(hexPath.shift(const Offset(0, 6)), shadowPaint);

      // 2. Dark matte molded hexagonal board plate
      final trayGradient = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.1,
        colors: const [
          Color(0xFF1B222E),
          Color(0xFF111620),
          Color(0xFF0A0C10),
        ],
      );
      final trayPaint = Paint()
        ..shader = trayGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(hexPath, trayPaint);

      // 3. Hexagonal molded outer rim
      final outerRimPaint = Paint()
        ..color = const Color(0xFF2E384A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawPath(hexPath, outerRimPaint);

      // 4. Inner recessed perimeter track
      final innerPath = _getHexagonPath(center, radius - 10.0, 18.0);
      final innerTrackPaint = Paint()
        ..color = const Color(0xFF05070A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawPath(innerPath, innerTrackPaint);

      return;
    }

    // Triangular tray fallback
    const pad = 10.0;
    final boardRect = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );
    final rrect = RRect.fromRectAndRadius(boardRect, const Radius.circular(24));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(rrect.shift(const Offset(0, 4)), shadowPaint);

    final trayGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF161B24), Color(0xFF0F1218), Color(0xFF0B0D12)],
    );
    final trayPaint = Paint()
      ..shader = trayGradient.createShader(boardRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, trayPaint);

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

      // Draw dark recessed Y-grooves
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

      // Central socket pin hole
      canvas.drawCircle(centroid, 3.2, centerPinPaint);
    }
  }

  void _drawThreatRadar(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
    GridNode startNode,
    GridNode targetNode,
    Color activeColor,
  ) {
    final List<BoardEdge> potentialEdges = [];
    if (geometry.shape == BoardShape.hexagon) {
      final band = geometry.findBandByEndpoints(startNode, targetNode);
      if (band == null || state.occupiedBands.contains(band.id)) return;
      potentialEdges.addAll(band.edges);
    } else {
      final edge = BoardEdge(startNode, targetNode);
      if (!edge.isAdjacent || state.occupiedEdges.contains(edge.id)) return;
      potentialEdges.add(edge);
    }

    final simulatedEdges = Set<String>.from(state.occupiedEdges)
      ..addAll(potentialEdges.map((e) => e.id));

    for (final edge in potentialEdges) {
      final adjTriangles = geometry.edgeToTriangles[edge.id] ?? [];

      for (final tri in adjTriangles) {
        if (state.claimedTriangles.containsKey(tri.id)) continue;

        int occupiedCount = 0;
        for (final eId in tri.edgeIds) {
          if (state.occupiedEdges.contains(eId)) {
            occupiedCount++;
          }
        }

        final p0 = positions[tri.vertices[0]]!;
        final p1 = positions[tri.vertices[1]]!;
        final p2 = positions[tri.vertices[2]]!;
        final path = Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();

        if (tri.isCompleted(simulatedEdges)) {
          // ⚡ VICTORY CAPTURE MOVE: Completes this triangle!
          final captureFill = Paint()
            ..color = activeColor.withValues(alpha: 0.4 + 0.25 * pulseValue)
            ..style = PaintingStyle.fill;
          canvas.drawPath(path, captureFill);

          final captureStroke = Paint()
            ..color = activeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;
          canvas.drawPath(path, captureStroke);
        } else if (occupiedCount == 1) {
          // ⚠️ THREAT WARNING: Leaves triangle with 2 edges (gives free triangle to opponent!)
          final warningStroke = Paint()
            ..color = const Color(
              0xFFFF9800,
            ).withValues(alpha: 0.6 + 0.35 * pulseValue)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2;
          canvas.drawPath(path, warningStroke);
        }
      }
    }
  }

  void _drawClaimedTrianglesAndTokens(
    Canvas canvas,
    BoardGeometry geometry,
    Map<GridNode, Offset> positions,
  ) {
    const tokenScale = 12.0;
    final isConquering = conquerAnimationProgress < 1.0;

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

      final isNewlyClaimed =
          newlyClaimedTriangleIds.contains(triId) && isConquering;

      // Dynamic animation variables
      double currentScale = 1.0;
      double currentDropY = 0.0;
      double currentFillAlpha = 0.22;
      double currentBorderWidth = 1.6;

      if (isNewlyClaimed) {
        final t = conquerAnimationProgress;
        // Ease out back gives an elastic bounce landing
        currentScale = Curves.easeOutBack.transform(t).clamp(0.0, 1.4);
        currentDropY = (1.0 - Curves.easeOutCubic.transform(t)) * -26.0;
        // Flash territory fill when conquered
        currentFillAlpha = 0.22 + (1.0 - t) * 0.45;
        currentBorderWidth = 1.6 + (1.0 - t) * 2.5;
      }

      // 1. Territory fill with colored border
      final triPath = Path()
        ..moveTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      final fillPaint = Paint()
        ..color = baseColor.withValues(alpha: currentFillAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawPath(triPath, fillPaint);

      final borderPaint = Paint()
        ..color = baseColor.withValues(alpha: isNewlyClaimed ? 0.95 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentBorderWidth;
      canvas.drawPath(triPath, borderPaint);

      final centroid = Offset(
        (p0.dx + p1.dx + p2.dx) / 3,
        (p0.dy + p1.dy + p2.dy) / 3,
      );

      // If newly claimed, draw shockwave ripple radiating outward from centroid
      if (isNewlyClaimed) {
        final t = conquerAnimationProgress;
        // Shockwave ripple starts slightly as token drops
        final rippleT = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
        if (rippleT > 0.0) {
          final rippleRadius = 6.0 + rippleT * 32.0;
          final rippleAlpha = (1.0 - rippleT) * 0.75;
          final ripplePaint = Paint()
            ..color = baseColor.withValues(alpha: rippleAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = (2.4 * (1.0 - rippleT)).clamp(0.8, 2.4);
          canvas.drawCircle(centroid, rippleRadius, ripplePaint);
        }

        // Soft radial impact glow
        final glowAlpha = ((1.0 - t) * 0.55).clamp(0.0, 1.0);
        if (glowAlpha > 0.0) {
          final glowPaint = Paint()
            ..color = baseColor.withValues(alpha: glowAlpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
          canvas.drawCircle(centroid, 16.0 * currentScale, glowPaint);
        }
      }

      // 2. 3D Molded plastic triangular token inside the Y-groove
      if (currentScale > 0.01) {
        _draw3DToken(
          canvas,
          centroid + Offset(0, currentDropY),
          tri.orientation,
          baseColor,
          tokenScale: tokenScale * currentScale,
        );
      }
    }
  }

  void _draw3DToken(
    Canvas canvas,
    Offset center,
    TriangleOrientation orientation,
    Color baseColor, {
    double tokenScale = 12.0,
  }) {
    final s = tokenScale;
    final isUp = orientation == TriangleOrientation.upright;

    final apex = isUp
        ? center + Offset(0, -s * 1.05)
        : center + Offset(0, s * 1.05);
    final leftWing = isUp
        ? center + Offset(-s * 0.9, s * 0.75)
        : center + Offset(-s * 0.9, -s * 0.75);
    final rightWing = isUp
        ? center + Offset(s * 0.9, s * 0.75)
        : center + Offset(s * 0.9, -s * 0.75);
    final notch = isUp
        ? center + Offset(0, s * 0.35)
        : center + Offset(0, -s * 0.35);

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
      ..strokeWidth = 1.4
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
    if (geometry.shape == BoardShape.hexagon) {
      // Draw 4-peg straight line rubber bands (matching real Triggle game in photo)
      final lastBandId = state.moveHistory.isNotEmpty
          ? state.moveHistory.last.edgeId
          : null;

      for (final band in geometry.bands) {
        if (!state.occupiedBands.contains(band.id)) continue;

        final p0 = positions[band.start];
        final p3 = positions[band.end];
        if (p0 == null || p3 == null) continue;

        final isLastMove = band.id == lastBandId;

        // Determine player color for subtle accent
        Color playerAccent = AppColors.player1;
        for (final m in state.moveHistory) {
          if (m.edgeId == band.id) {
            playerAccent = m.playerId == state.player1Id
                ? AppColors.player1
                : AppColors.player2;
            break;
          }
        }

        final v = p3 - p0;
        final len = v.distance;
        if (len < 1.0) continue;
        final u = v / len;
        final normal = Offset(-u.dy, u.dx);
        const bandHalfWidth = 3.6;

        // 1. Drop shadow of rubber band onto black board
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawLine(
          p0 + const Offset(1.5, 3.0),
          p3 + const Offset(1.5, 3.0),
          shadowPaint,
        );

        // 2. Ambient glow (and intense pulsating aura if last move)
        final auraAlpha = isLastMove ? (0.55 + 0.35 * pulseValue) : 0.22;
        final auraWidth = isLastMove ? (12.0 + 4.0 * pulseValue) : 7.0;
        final auraPaint = Paint()
          ..color = playerAccent.withValues(alpha: auraAlpha)
          ..strokeWidth = auraWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p0, p3, auraPaint);

        // 3. Translucent colored silicone webbing body between dual strands
        final webbingPaint = Paint()
          ..color = playerAccent.withValues(alpha: 0.35)
          ..strokeWidth = bandHalfWidth * 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p0, p3, webbingPaint);

        // 4. Vibrant player-colored elastic tension strands (upper & lower cords)
        final strandPaint = Paint()
          ..color = playerAccent
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          p0 + normal * bandHalfWidth,
          p3 + normal * bandHalfWidth,
          strandPaint,
        );
        canvas.drawLine(
          p0 - normal * bandHalfWidth,
          p3 - normal * bandHalfWidth,
          strandPaint,
        );

        // 5. Player-colored elastic collar loops wrapping around start & end pegs
        final capPaint = Paint()
          ..color = playerAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8;
        canvas.drawCircle(p0, 8.0, capPaint);
        canvas.drawCircle(p3, 8.0, capPaint);

        // 6. Specular gloss highlight glint down the center for realistic sheen
        final specularPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p0, p3, specularPaint);
      }
      return;
    }

    // Triangular single-edge rubber band fallback
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

      if (isLastMove) {
        final glowPaint = Paint()
          ..color = bandColor.withValues(alpha: 0.6 + 0.3 * pulseValue)
          ..strokeWidth = 10.0 + 3.0 * pulseValue
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, glowPaint);
      }

      final bodyPaint = Paint()
        ..color = bandColor
        ..strokeWidth = 5.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, bodyPaint);

      final coreHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, coreHighlight);
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
      ..color = activeColor.withValues(alpha: 0.45 + 0.3 * pulseValue)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (geometry.shape == BoardShape.hexagon) {
      for (final band in geometry.bands) {
        if (!state.occupiedBands.contains(band.id)) {
          if (band.start == focusNode || band.end == focusNode) {
            final targetNode = band.start == focusNode ? band.end : band.start;
            final targetPos = positions[targetNode];
            if (targetPos != null) {
              // 4-peg straight trajectory guide line
              canvas.drawLine(focusPos, targetPos, candidatePaint);

              // Pulsing beacon on the 4th target peg
              final targetBeacon = Paint()
                ..color = activeColor.withValues(alpha: 0.55 * pulseValue)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.4;
              canvas.drawCircle(
                targetPos,
                15.0 + 4.0 * pulseValue,
                targetBeacon,
              );

              // Draw subtle intermediate peg rings (pegs 2 & 3 in the line)
              for (final midNode in band.nodes) {
                if (midNode != focusNode && midNode != targetNode) {
                  final midPos = positions[midNode];
                  if (midPos != null) {
                    canvas.drawCircle(
                      midPos,
                      10.0,
                      Paint()
                        ..color = activeColor.withValues(alpha: 0.25)
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.2,
                    );
                  }
                }
              }
            }
          }
        }
      }
      return;
    }

    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        if (edge.node1 == focusNode || edge.node2 == focusNode) {
          final otherNode = edge.node1 == focusNode ? edge.node2 : edge.node1;
          final otherPos = positions[otherNode];
          if (otherPos != null) {
            canvas.drawLine(focusPos, otherPos, candidatePaint);
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

    final tensionWidth = (5.5 - (dist / 320.0).clamp(0.0, 1.0) * 1.6).clamp(
      3.6,
      5.5,
    );

    // 1. Drop shadow under stretched band
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..strokeWidth = tensionWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
      startPos + const Offset(1.5, 2.5),
      targetPos + const Offset(1.5, 2.5),
      shadowPaint,
    );

    // 2. Glow
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: snapNode != null ? 0.8 : 0.45)
      ..strokeWidth = tensionWidth + 6.0 + 2.0 * pulseValue
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, glowPaint);

    // 3. Stretched elastic band body in player's bold color
    final bodyPaint = Paint()
      ..color = activeColor
      ..strokeWidth = tensionWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, bodyPaint);

    // 4. Specular gloss highlight glint down the center
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = (tensionWidth * 0.35).clamp(1.2, 2.0)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(startPos, targetPos, corePaint);

    // 5. If snapped to valid 4-peg endpoint, draw energetic lock beacon
    if (snapNode != null) {
      final snapAura = Paint()
        ..color = activeColor.withValues(alpha: 0.85)
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
    const pegRadius = 7.8;
    final isConquering = conquerAnimationProgress < 1.0;

    // Collect corner pegs of newly conquered triangles
    final conqueredPegs = <GridNode>{};
    if (isConquering && newlyClaimedTriangleIds.isNotEmpty) {
      final geometry = BoardGeometry(state.boardSize, shape: state.boardShape);
      for (final id in newlyClaimedTriangleIds) {
        final tri = geometry.triangleMap[id];
        if (tri != null) {
          conqueredPegs.addAll(tri.vertices);
        }
      }
    }

    for (final entry in positions.entries) {
      final node = entry.key;
      final pos = entry.value;

      final isFocused = focusNode == node;
      final isSnapped = snapNode == node;
      final isConqueredPeg = conqueredPegs.contains(node);

      // 1. Base drop shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        pos + const Offset(1.5, 2.8),
        pegRadius + 0.5,
        shadowPaint,
      );

      // 2. Focus / Active glow aura / Conquer celebratory ring
      if (isConqueredPeg) {
        final t = conquerAnimationProgress;
        final ringExpand = sin(t * pi);
        final victoryAura = Paint()
          ..color = activeColor.withValues(alpha: (1.0 - t) * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(pos, pegRadius + 4.0 + 8.0 * ringExpand, victoryAura);

        final victoryFill = Paint()
          ..color = activeColor.withValues(alpha: (1.0 - t) * 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, pegRadius + 2.0, victoryFill);
      } else if (isFocused) {
        final auraPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.45 + 0.35 * pulseValue)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 16.0 + 2.0 * pulseValue, auraPaint);
      } else if (isSnapped) {
        final snapGlow = Paint()
          ..color = activeColor.withValues(alpha: 0.75)
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
      final rimColor = isConqueredPeg
          ? activeColor
          : (isFocused || isSnapped
                ? activeColor
                : const Color(0xFF64748B).withValues(alpha: 0.7));
      final rimStroke = Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isConqueredPeg || isFocused || isSnapped ? 2.5 : 1.2;
      canvas.drawCircle(pos, pegRadius, rimStroke);

      // 5. Specular highlight crescent / glint at top-left
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos + const Offset(-2.2, -2.2), 1.6, glintPaint);

      // Inner peg core hole/recess
      canvas.drawCircle(
        pos,
        2.0,
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
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.conquerAnimationProgress != conquerAnimationProgress ||
        oldDelegate.newlyClaimedTriangleIds != newlyClaimedTriangleIds;
  }
}
