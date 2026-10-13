import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_core/game_core.dart';
import '../theme/app_colors.dart';

class ConnectFourBoard extends StatefulWidget {
  final ConnectFourState state;
  final String currentUserId;
  final ValueChanged<int> onColumnSelected;
  final bool isInteractive;

  const ConnectFourBoard({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.onColumnSelected,
    this.isInteractive = true,
  });

  @override
  State<ConnectFourBoard> createState() => _ConnectFourBoardState();
}

class _ConnectFourBoardState extends State<ConnectFourBoard>
    with TickerProviderStateMixin {
  int? _hoveredColumn;
  late AnimationController _pulseController;
  late AnimationController _dropController;
  int? _lastDroppedCol;
  int? _lastDroppedRow;
  String? _lastDroppedPlayer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(ConnectFourBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.moveHistory.length > oldWidget.state.moveHistory.length) {
      final lastCol = widget.state.moveHistory.last;
      // Find row where piece landed
      int? landedRow;
      for (int r = 0; r < ConnectFourState.rows; r++) {
        if (widget.state.grid[r][lastCol] != null) {
          landedRow = r;
          break;
        }
      }

      if (landedRow != null) {
        final row = landedRow;
        setState(() {
          _lastDroppedCol = lastCol;
          _lastDroppedRow = row;
          _lastDroppedPlayer = widget.state.grid[row][lastCol];
        });
        _dropController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _onColumnTap(int col) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;
    if (widget.state.isColumnFull(col)) return;

    widget.onColumnSelected(col);
  }

  @override
  Widget build(BuildContext context) {
    final isMyTurn =
        widget.isInteractive &&
        !widget.state.isTerminal &&
        widget.state.activePlayerId == widget.currentUserId;

    final myColor = widget.currentUserId == widget.state.player1Id
        ? AppColors.player1
        : AppColors.player2;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _dropController]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Keep 7:6 aspect ratio with padding
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            const cols = ConnectFourState.cols;
            const rows = ConnectFourState.rows;

            // Reserve top space for hover preview disc
            final availableHeight = maxHeight - 60;
            final cellSizeByWidth = maxWidth / cols;
            final cellSizeByHeight = availableHeight / rows;
            final cellSize = min(
              cellSizeByWidth,
              cellSizeByHeight,
            ).clamp(32.0, 72.0);

            final boardWidth = cellSize * cols;
            final boardHeight = cellSize * rows;

            return Center(
              child: SizedBox(
                width: boardWidth,
                height: boardHeight + 60,
                child: Column(
                  children: [
                    // Column selector / preview disc bar
                    SizedBox(
                      height: 52,
                      width: boardWidth,
                      child: Row(
                        children: List.generate(cols, (c) {
                          final isHovered = _hoveredColumn == c;
                          final isFull = widget.state.isColumnFull(c);
                          final canDrop = isMyTurn && !isFull;

                          return Expanded(
                            child: MouseRegion(
                              cursor: canDrop
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                              onEnter: (_) {
                                if (canDrop) {
                                  setState(() => _hoveredColumn = c);
                                }
                              },
                              onExit: (_) {
                                if (_hoveredColumn == c) {
                                  setState(() => _hoveredColumn = null);
                                }
                              },
                              child: GestureDetector(
                                onTap: () => _onColumnTap(c),
                                behavior: HitTestBehavior.opaque,
                                child: Center(
                                  child: isHovered && canDrop
                                      ? Container(
                                          width: cellSize * 0.72,
                                          height: cellSize * 0.72,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: myColor.withValues(
                                              alpha:
                                                  0.8 +
                                                  0.2 * _pulseController.value,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: myColor.withValues(
                                                  alpha: 0.6,
                                                ),
                                                blurRadius: 16,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.arrow_downward_rounded,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        )
                                      : (canDrop
                                            ? Opacity(
                                                opacity:
                                                    0.25 +
                                                    0.25 *
                                                        _pulseController.value,
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: myColor,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink()),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Main 7x6 Interactive Board
                    Expanded(
                      child: GestureDetector(
                        onTapUp: (details) {
                          final col = (details.localPosition.dx / cellSize)
                              .floor();
                          if (col >= 0 && col < cols) {
                            _onColumnTap(col);
                          }
                        },
                        child: CustomPaint(
                          size: Size(boardWidth, boardHeight),
                          painter: _ConnectFourPainter(
                            state: widget.state,
                            cellSize: cellSize,
                            hoveredCol: _hoveredColumn,
                            pulseValue: _pulseController.value,
                            dropProgress: _dropController.value,
                            animatingCol: _lastDroppedCol,
                            animatingRow: _lastDroppedRow,
                            animatingPlayer: _lastDroppedPlayer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ConnectFourPainter extends CustomPainter {
  final ConnectFourState state;
  final double cellSize;
  final int? hoveredCol;
  final double pulseValue;
  final double dropProgress;
  final int? animatingCol;
  final int? animatingRow;
  final String? animatingPlayer;

  _ConnectFourPainter({
    required this.state,
    required this.cellSize,
    required this.hoveredCol,
    required this.pulseValue,
    required this.dropProgress,
    this.animatingCol,
    this.animatingRow,
    this.animatingPlayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cols = ConnectFourState.cols;
    const rows = ConnectFourState.rows;
    final radius = (cellSize * 0.38);

    // 1. Draw outer chassis shadow and titanium frame
    final boardRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(boardRect, const Radius.circular(20));

    // Outer glow / shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(rrect.shift(const Offset(0, 8)), shadowPaint);

    // Chassis background fill
    final chassisGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFF1A2230),
        Color(0xFF101520),
        Color(0xFF090C12),
      ],
    );
    final chassisPaint = Paint()
      ..shader = chassisGradient.createShader(boardRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, chassisPaint);

    // Chassis border
    final borderPaint = Paint()
      ..color = const Color(0xFF2B374A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);

    // 2. Highlight hovered column channel
    if (hoveredCol != null && hoveredCol! >= 0 && hoveredCol! < cols) {
      final colRect = Rect.fromLTWH(
        hoveredCol! * cellSize,
        0,
        cellSize,
        size.height,
      );
      final hoverGlow = Paint()
        ..color = AppColors.player1.withValues(alpha: 0.06 + 0.04 * pulseValue)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(colRect, const Radius.circular(12)),
        hoverGlow,
      );
    }

    // 3. Draw each slot and placed discs
    final winningSet = <String>{};
    for (final coord in state.winningCoords) {
      winningSet.add('${coord[0]}_${coord[1]}');
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final center = Offset(
          c * cellSize + cellSize / 2,
          r * cellSize + cellSize / 2,
        );

        final occupant = state.grid[r][c];
        final isAnimating =
            (c == animatingCol && r == animatingRow && dropProgress < 1.0);

        // Dark recessed socket hole
        final socketBg = Paint()
          ..color = const Color(0xFF06080C)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, socketBg);

        final socketRim = Paint()
          ..color = const Color(0xFF1E2638)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, radius, socketRim);

        // Draw disc if occupied and not currently dropping from top
        if (occupant != null && !isAnimating) {
          final isWinningDisc = winningSet.contains('${r}_$c');
          _drawDisc(
            canvas: canvas,
            center: center,
            radius: radius,
            playerId: occupant,
            isWinning: isWinningDisc,
          );
        }
      }
    }

    // 4. Draw currently dropping animated disc with bounce interpolation
    if (animatingCol != null &&
        animatingRow != null &&
        animatingPlayer != null &&
        dropProgress < 1.0) {
      final targetY = animatingRow! * cellSize + cellSize / 2;
      final startY = -cellSize;
      // Bounce curve
      final bounceFactor = Curves.bounceOut.transform(dropProgress);
      final currentY = startY + (targetY - startY) * bounceFactor;
      final currentCenter = Offset(
        animatingCol! * cellSize + cellSize / 2,
        currentY,
      );

      _drawDisc(
        canvas: canvas,
        center: currentCenter,
        radius: radius,
        playerId: animatingPlayer!,
        isWinning: false,
      );
    }

    // 5. Draw neon laser victory line across 4 winning discs
    if (state.isTerminal && state.winningCoords.length >= 4) {
      _drawVictoryLaser(canvas, winningSet, radius);
    }
  }

  void _drawDisc({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required String playerId,
    required bool isWinning,
  }) {
    final isP1 = playerId == state.player1Id;
    final primaryColor = isP1 ? AppColors.player1 : AppColors.player2;
    final darkColor = isP1 ? const Color(0xFF007788) : const Color(0xFF994400);

    // Glowing halo for discs
    final glowPaint = Paint()
      ..color = primaryColor.withValues(
        alpha: isWinning ? (0.5 + 0.3 * pulseValue) : 0.2,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isWinning ? 14 : 6);
    canvas.drawCircle(center, radius + (isWinning ? 4 : 1), glowPaint);

    // Radial 3D Sphere gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 0.9,
      colors: [
        Colors.white,
        primaryColor,
        darkColor,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final discPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 1.5, discPaint);

    // Specular glossy rim
    final rimPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius - 1.5, rimPaint);

    // Winning disc golden pulse ring
    if (isWinning) {
      final winRing = Paint()
        ..color = Colors.amberAccent.withValues(alpha: 0.8 + 0.2 * pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius + 2 + (pulseValue * 2), winRing);
    }
  }

  void _drawVictoryLaser(Canvas canvas, Set<String> winningSet, double radius) {
    if (state.winningCoords.isEmpty) return;

    // Ensure sorted along connection line
    final sorted = List<List<int>>.from(state.winningCoords)
      ..sort((a, b) {
        final colComp = a[1].compareTo(b[1]);
        if (colComp != 0) return colComp;
        return a[0].compareTo(b[0]);
      });

    final first = sorted.first;
    final last = sorted.last;

    final pStart = Offset(
      first[1] * cellSize + cellSize / 2,
      first[0] * cellSize + cellSize / 2,
    );
    final pEnd = Offset(
      last[1] * cellSize + cellSize / 2,
      last[0] * cellSize + cellSize / 2,
    );

    // 1. Ultra-wide neon background glow beam
    final wideGlow = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.4 + 0.3 * pulseValue)
      ..strokeWidth = 20.0 + (pulseValue * 6.0)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawLine(pStart, pEnd, wideGlow);

    // 2. Focused vibrant laser beam
    final laserGlow = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.85 + 0.15 * pulseValue)
      ..strokeWidth = 9.0 + (pulseValue * 2.5)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(pStart, pEnd, laserGlow);

    // 3. Inner brilliant white hot core
    final laserCore = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pStart, pEnd, laserCore);

    // 4. Draw highlighted target beacons on each of the 4 connected dots
    final beaconRingPaint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.85 + 0.15 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    final beaconFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sorted.length; i++) {
      final dotCenter = Offset(
        sorted[i][1] * cellSize + cellSize / 2,
        sorted[i][0] * cellSize + cellSize / 2,
      );

      // Outer pulse shockwave ring
      canvas.drawCircle(
        dotCenter,
        radius + 3.0 + (pulseValue * 4.0),
        beaconRingPaint,
      );

      // Center bright white star node
      canvas.drawCircle(dotCenter, 6.0, beaconFillPaint);

      // Inner amber spark
      final spark = Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, 3.2, spark);
    }
  }

  @override
  bool shouldRepaint(_ConnectFourPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.hoveredCol != hoveredCol ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.dropProgress != dropProgress ||
        oldDelegate.animatingCol != animatingCol ||
        oldDelegate.animatingRow != animatingRow;
  }
}
