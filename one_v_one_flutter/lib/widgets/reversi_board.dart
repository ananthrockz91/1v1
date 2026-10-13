import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_core/game_core.dart';
import '../theme/app_colors.dart';

class ReversiBoard extends StatefulWidget {
  final ReversiState state;
  final String currentUserId;
  final void Function(int row, int col) onSquareSelected;
  final bool isInteractive;
  final Set<String> validMovesCoordinates; // "r,c" format

  const ReversiBoard({
    super.key,
    required this.state,
    required this.currentUserId,
    required this.onSquareSelected,
    this.isInteractive = true,
    this.validMovesCoordinates = const {},
  });

  @override
  State<ReversiBoard> createState() => _ReversiBoardState();
}

class _ReversiBoardState extends State<ReversiBoard>
    with SingleTickerProviderStateMixin {
  int? _hoveredRow;
  int? _hoveredCol;
  late AnimationController _flipAnimationController;
  final Set<String> _animatingCells = {};

  @override
  void initState() {
    super.initState();
    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void didUpdateWidget(ReversiBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.stateVersion > oldWidget.state.stateVersion &&
        widget.state.lastFlipped.isNotEmpty) {
      _animatingCells.clear();
      for (final cell in widget.state.lastFlipped) {
        _animatingCells.add('${cell[0]},${cell[1]}');
      }
      _flipAnimationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipAnimationController.dispose();
    super.dispose();
  }

  void _onSquareTap(int row, int col) {
    if (!widget.isInteractive) return;
    if (widget.state.isTerminal) return;
    if (widget.state.activePlayerId != widget.currentUserId) return;
    if (!widget.validMovesCoordinates.contains('$row,$col')) return;

    widget.onSquareSelected(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.state.boardSize;
    final isMyTurn =
        widget.isInteractive &&
        !widget.state.isTerminal &&
        widget.state.activePlayerId == widget.currentUserId;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.teal.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth / size;

              return AnimatedBuilder(
                animation: _flipAnimationController,
                builder: (context, _) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: size * size,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: size,
                    ),
                    itemBuilder: (context, index) {
                      final r = index ~/ size;
                      final c = index % size;
                      final cellVal = widget.state.cellAt(r, c);
                      final isHovered = _hoveredRow == r && _hoveredCol == c;
                      final isValid = widget.validMovesCoordinates.contains(
                        '$r,$c',
                      );
                      final isLastPlaced =
                          widget.state.lastMove != null &&
                          widget.state.lastMove!.row == r &&
                          widget.state.lastMove!.col == c;
                      final isFlipping = _animatingCells.contains('$r,$c');

                      return MouseRegion(
                        onEnter: (_) => setState(() {
                          _hoveredRow = r;
                          _hoveredCol = c;
                        }),
                        onExit: (_) => setState(() {
                          _hoveredRow = null;
                          _hoveredCol = null;
                        }),
                        cursor: (isValid && isMyTurn)
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: () => _onSquareTap(r, c),
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: isHovered && isValid && isMyTurn
                                  ? AppColors.teal.withValues(alpha: 0.22)
                                  : const Color(0xFF0D1B2A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLastPlaced
                                    ? AppColors.teal
                                    : (isHovered && isValid && isMyTurn)
                                    ? AppColors.tealLight
                                    : const Color(0xFF1E293B),
                                width: isLastPlaced ? 2.0 : 1.0,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Center coordinate guide dots for standard Reversi (corners of center 4x4)
                                if ((r == 2 || r == 6) && (c == 2 || c == 6))
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),

                                // Valid Move Beacon
                                if (cellVal == 0 && isValid && isMyTurn)
                                  _buildValidMoveBeacon(isHovered),

                                // Disk Piece
                                if (cellVal != 0)
                                  _buildDisk(
                                    playerNum: cellVal,
                                    isLastPlaced: isLastPlaced,
                                    isFlipping: isFlipping,
                                    cellSize: cellSize,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildValidMoveBeacon(bool isHovered) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: isHovered ? 18 : 12,
      height: isHovered ? 18 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.teal.withValues(alpha: isHovered ? 0.9 : 0.45),
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildDisk({
    required int playerNum,
    required bool isLastPlaced,
    required bool isFlipping,
    required double cellSize,
  }) {
    // 3D flip animation transform
    double rotationY = 0.0;
    if (isFlipping && _flipAnimationController.isAnimating) {
      rotationY = _flipAnimationController.value * pi;
    }

    final isP1 = playerNum == 1; // P1 is Dark / Teal Cyber
    final diskSize = cellSize * 0.78;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Perspective
        ..rotateY(rotationY),
      child: Container(
        width: diskSize,
        height: diskSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isP1
                ? const [
                    Color(0xFF14B8A6),
                    Color(0xFF0F766E),
                    Color(0xFF042F2E),
                  ]
                : const [
                    Color(0xFFFFFFFF),
                    Color(0xFFE2E8F0),
                    Color(0xFF94A3B8),
                  ],
            center: const Alignment(-0.25, -0.3),
            radius: 0.85,
          ),
          border: Border.all(
            color: isP1
                ? (isLastPlaced ? Colors.white : const Color(0xFF2DD4BF))
                : (isLastPlaced ? AppColors.teal : const Color(0xFFCBD5E1)),
            width: isLastPlaced ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            if (isP1)
              BoxShadow(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: Container(
            width: diskSize * 0.4,
            height: diskSize * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isP1
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
