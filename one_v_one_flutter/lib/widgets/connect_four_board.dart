import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import '../theme/theme_provider.dart';

class ConnectFourBoard extends ConsumerStatefulWidget {
  final ConnectFourState state;
  final String currentUserId;
  final ValueChanged<int> onColumnSelected;
  final ValueChanged<ConnectFourMove>? onMoveSelected;
  final bool isInteractive;

  const ConnectFourBoard({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.onColumnSelected,
    this.onMoveSelected,
    this.isInteractive = true,
  });

  @override
  ConsumerState<ConnectFourBoard> createState() => _ConnectFourBoardState();
}

class _ConnectFourBoardState extends ConsumerState<ConnectFourBoard>
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
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void didUpdateWidget(ConnectFourBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.moveHistory.length > oldWidget.state.moveHistory.length) {
      final lastCol = widget.state.moveHistory.last;
      int? landedRow;
      for (int r = 0; r < widget.state.numRows; r++) {
        if (widget.state.grid[r][lastCol] != null) {
          landedRow = r;
          break;
        }
      }

      if (landedRow != null) {
        setState(() {
          _lastDroppedCol = lastCol;
          _lastDroppedRow = landedRow;
          _lastDroppedPlayer = widget.state.grid[landedRow!][lastCol];
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

    if (widget.onMoveSelected != null) {
      widget.onMoveSelected!(ConnectFourMove.drop(col));
    }
    widget.onColumnSelected(col);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);
    final isMyTurn =
        widget.isInteractive &&
        !widget.state.isTerminal &&
        widget.state.activePlayerId == widget.currentUserId;

    final isP1 = widget.currentUserId == widget.state.player1Id;
    final myColor = isP1 ? theme.player1 : theme.player2;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _dropController]),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            final cols = widget.state.numCols;
            final rows = widget.state.numRows;

            // Reserve top drop indicator height (44px) + spacing (6px)
            final availableHeight = maxHeight - 50;
            final cellSizeByWidth = maxWidth / cols;
            final cellSizeByHeight = availableHeight / rows;
            final cellSize = min(
              cellSizeByWidth,
              cellSizeByHeight,
            ).clamp(28.0, 68.0);

            final boardWidth = cellSize * cols;
            final boardHeight = cellSize * rows;

            return Center(
              child: SizedBox(
                width: boardWidth,
                height: boardHeight + 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drop / preview indicator bar
                    SizedBox(
                      height: 44,
                      width: boardWidth,
                      child: Row(
                        children: List.generate(cols, (c) {
                          final isHovered = _hoveredColumn == c;
                          final canAct =
                              isMyTurn && !widget.state.isColumnFull(c);

                          return Expanded(
                            child: MouseRegion(
                              cursor: canAct
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                              onEnter: (_) {
                                if (canAct) {
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
                                  child: isHovered && canAct
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
                                            size: 16,
                                            color: Colors.black,
                                          ),
                                        )
                                      : (canAct
                                            ? Opacity(
                                                opacity:
                                                    0.25 +
                                                    0.25 *
                                                        _pulseController.value,
                                                child: Container(
                                                  width: 7,
                                                  height: 7,
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
                    const SizedBox(height: 6),

                    // Main Interactive Board
                    SizedBox(
                      width: boardWidth,
                      height: boardHeight,
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
                            theme: theme,
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
  final AppThemeData theme;
  final double cellSize;
  final int? hoveredCol;
  final double pulseValue;
  final double dropProgress;
  final int? animatingCol;
  final int? animatingRow;
  final String? animatingPlayer;

  _ConnectFourPainter({
    required this.state,
    required this.theme,
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
    final cols = state.numCols;
    final rows = state.numRows;
    final radius = (cellSize * 0.38);

    // 1. Draw outer chassis shadow and titanium frame
    final boardRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(boardRect, const Radius.circular(18));

    // Outer glow / shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(rrect.shift(const Offset(0, 8)), shadowPaint);

    // Chassis background fill
    final chassisGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: theme.isMonochrome
          ? const [
              Color(0xFF141414),
              Color(0xFF0D0D0D),
              Color(0xFF050505),
            ]
          : const [
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
      ..color = theme.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
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
        ..color = theme.accent.withValues(alpha: 0.08 + 0.05 * pulseValue)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(colRect, const Radius.circular(10)),
        hoverGlow,
      );
    }

    // 3. Draw each slot, obstacles, and placed discs
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

        final isObstacle = state.isObstacle(r, c);
        final occupant = state.grid[r][c];
        final isAnimating =
            (c == animatingCol && r == animatingRow && dropProgress < 1.0);

        if (isObstacle) {
          // Draw hazard obstacle peg
          _drawObstaclePeg(canvas, center, radius);
          continue;
        }

        // Dark recessed socket hole
        final socketBg = Paint()
          ..color = theme.isMonochrome
              ? const Color(0xFF080808)
              : const Color(0xFF06080C)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, socketBg);

        final socketRim = Paint()
          ..color = theme.isMonochrome
              ? const Color(0xFF1F1F23)
              : const Color(0xFF1E2638)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
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

    // 5. Draw neon laser victory line across winning discs
    if (state.isTerminal && state.winningCoords.length >= state.targetStreak) {
      _drawVictoryLaser(canvas, radius);
    }
  }

  void _drawObstaclePeg(Canvas canvas, Offset center, double radius) {
    // Industrial steel barrier peg
    final obsBg = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF3F3F46), Color(0xFF18181B)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.0, obsBg);

    // Hazard rim
    final obsRim = Paint()
      ..color = const Color(0xFFF97316).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1.0, obsRim);

    // Center metallic hazard crosshair
    final crosshairPaint = Paint()
      ..color = const Color(0xFFFB923C)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      center - const Offset(5, 0),
      center + const Offset(5, 0),
      crosshairPaint,
    );
    canvas.drawLine(
      center - const Offset(0, 5),
      center + const Offset(0, 5),
      crosshairPaint,
    );
  }

  void _drawDisc({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required String playerId,
    required bool isWinning,
  }) {
    final isP1 = playerId == state.player1Id;
    final primaryColor = isP1 ? theme.player1 : theme.player2;
    final darkColor = isP1 ? theme.player1Dark : theme.player2Dark;

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

    // Winning disc pulse ring
    if (isWinning) {
      final winRing = Paint()
        ..color = theme.accentSecondary.withValues(
          alpha: 0.8 + 0.2 * pulseValue,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius + 2 + (pulseValue * 2), winRing);
    }
  }

  void _drawVictoryLaser(Canvas canvas, double radius) {
    if (state.winningCoords.isEmpty) return;

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

    // 1. Neon background glow beam
    final wideGlow = Paint()
      ..color = theme.accent.withValues(alpha: 0.4 + 0.3 * pulseValue)
      ..strokeWidth = 20.0 + (pulseValue * 6.0)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawLine(pStart, pEnd, wideGlow);

    // 2. Focused vibrant laser beam
    final laserGlow = Paint()
      ..color = theme.accent.withValues(alpha: 0.85 + 0.15 * pulseValue)
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

    // 4. Draw highlighted target beacons on connected dots
    final beaconRingPaint = Paint()
      ..color = theme.accentSecondary.withValues(
        alpha: 0.85 + 0.15 * pulseValue,
      )
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

      canvas.drawCircle(
        dotCenter,
        radius + 3.0 + (pulseValue * 4.0),
        beaconRingPaint,
      );
      canvas.drawCircle(dotCenter, 6.0, beaconFillPaint);

      final spark = Paint()
        ..color = theme.accentSecondary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, 3.2, spark);
    }
  }

  @override
  bool shouldRepaint(_ConnectFourPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.theme != theme ||
        oldDelegate.hoveredCol != hoveredCol ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.dropProgress != dropProgress ||
        oldDelegate.animatingCol != animatingCol ||
        oldDelegate.animatingRow != animatingRow;
  }
}
