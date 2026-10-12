import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_core/game_core.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../widgets/player_avatar.dart';
import '../widgets/triangle_tactics_board.dart';

class MatchReplayScreen extends StatefulWidget {
  final TriangleTacticsState finalState;
  final String player1Name;
  final String player2Name;
  final String player1Avatar;
  final String player2Avatar;

  const MatchReplayScreen({
    super.key,
    required this.finalState,
    required this.player1Name,
    required this.player2Name,
    required this.player1Avatar,
    required this.player2Avatar,
  });

  @override
  State<MatchReplayScreen> createState() => _MatchReplayScreenState();
}

class _MatchReplayScreenState extends State<MatchReplayScreen> {
  late final List<TriangleTacticsState> _states;
  int _currentStep = 0;
  Timer? _playbackTimer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _computeStates();
    // Default to the end so the user sees the final result, but can scrub back
    _currentStep = _states.length - 1;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _computeStates() {
    final history = widget.finalState.moveHistory;
    final engine = TriangleTacticsEngine();

    final startingPlayerId = history.isNotEmpty
        ? history.first.playerId
        : widget.finalState.player1Id;

    var current = TriangleTacticsState.initial(
      player1Id: widget.finalState.player1Id,
      player2Id: widget.finalState.player2Id,
      boardSize: widget.finalState.boardSize,
      boardShape: widget.finalState.boardShape,
      startingPlayerId: startingPlayerId,
    );

    final list = <TriangleTacticsState>[current];

    for (final record in history) {
      final move = TriangleTacticsMove(
        node1: record.node1,
        node2: record.node2,
      );
      final result = engine.applyMove(current, record.playerId, move);
      if (result is MoveAccepted) {
        current = result.nextState;
        list.add(current);
      }
    }

    _states = list;
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (_currentStep >= _states.length - 1) {
      setState(() => _currentStep = 0);
    }
    setState(() => _isPlaying = true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 1100), (t) {
      if (_currentStep < _states.length - 1) {
        _setStep(_currentStep + 1);
      } else {
        _stopPlayback();
      }
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _setStep(int step) {
    if (step < 0 || step >= _states.length) return;
    setState(() => _currentStep = step);

    // Audio cues
    if (step > 0 && step <= widget.finalState.moveHistory.length) {
      final move = widget.finalState.moveHistory[step - 1];
      if (move.claimedTriangles.isNotEmpty) {
        SoundService.playCapture();
      } else {
        SoundService.playMove();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _states[_currentStep];
    final totalMoves = widget.finalState.moveHistory.length;
    final hasMoves = totalMoves > 0;

    MoveRecord? currentMoveRecord;
    if (_currentStep > 0 &&
        _currentStep - 1 < widget.finalState.moveHistory.length) {
      currentMoveRecord = widget.finalState.moveHistory[_currentStep - 1];
    }

    final isP1Move =
        currentMoveRecord?.playerId == widget.finalState.player1Id ||
        currentMoveRecord?.playerId == 'Player 1';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Exit Replay',
          onPressed: () {
            _stopPlayback();
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Icon(
              Icons.movie_creation_outlined,
              color: AppColors.player1,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Match Replay & Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.player1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.player1.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 14, color: AppColors.player1),
                const SizedBox(width: 6),
                Text(
                  'Deterministic Step $_currentStep / $totalMoves',
                  style: const TextStyle(
                    color: AppColors.player1,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                // Scoreboard Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Player 1 Card
                      Expanded(
                        child: Row(
                          children: [
                            PlayerAvatar(
                              avatarSeed: widget.player1Avatar,
                              displayName: widget.player1Name,
                              size: 34,
                              borderColor: AppColors.player1,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.player1Name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.player1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${currentState.player1Score} pts',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Player 2 Card
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.player2Name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.player2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${currentState.player2Score} pts',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            PlayerAvatar(
                              avatarSeed: widget.player2Avatar,
                              displayName: widget.player2Name,
                              size: 34,
                              borderColor: AppColors.player2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Move Details Subheader
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    border: const Border(
                      bottom: BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentMoveRecord != null
                            ? Icons.gesture
                            : Icons.play_arrow,
                        size: 16,
                        color: currentMoveRecord == null
                            ? AppColors.textMuted
                            : (isP1Move
                                  ? AppColors.player1
                                  : AppColors.player2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentMoveRecord == null
                              ? 'Initial Board State — No moves placed yet'
                              : '${isP1Move ? widget.player1Name : widget.player2Name} connected edge ${currentMoveRecord.edgeId}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (currentMoveRecord != null &&
                          currentMoveRecord.claimedTriangles.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isP1Move
                                        ? AppColors.player1
                                        : AppColors.player2)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: isP1Move
                                    ? AppColors.player1
                                    : AppColors.player2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${currentMoveRecord.claimedTriangles.length} ${currentMoveRecord.extraTurn ? "(Bonus Turn!)" : ""}',
                                style: TextStyle(
                                  color: isP1Move
                                      ? AppColors.player1
                                      : AppColors.player2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Board Canvas
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TriangleTacticsBoard(
                            state: currentState,
                            currentUserId: currentState.activePlayerId,
                            isInteractive: false,
                            onMoveSubmitted: (_, _) {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Timeline Scrubber & Player Controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.surfaceBorder),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timeline Slider
                      Row(
                        children: [
                          Text(
                            '0',
                            style: TextStyle(
                              color: _currentStep == 0
                                  ? AppColors.player1
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.player1,
                                inactiveTrackColor: AppColors.surfaceBorder,
                                thumbColor: AppColors.player1,
                                trackHeight: 4,
                                overlayColor: AppColors.player1.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: Slider(
                                value: _currentStep.toDouble(),
                                min: 0.0,
                                max: hasMoves ? totalMoves.toDouble() : 1.0,
                                divisions: hasMoves ? totalMoves : 1,
                                onChanged: hasMoves
                                    ? (val) {
                                        _stopPlayback();
                                        _setStep(val.round());
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          Text(
                            '$totalMoves',
                            style: TextStyle(
                              color: _currentStep == totalMoves
                                  ? AppColors.player1
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Playback Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page_rounded),
                            tooltip: 'Jump to Start',
                            color: _currentStep > 0
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            onPressed: _currentStep > 0
                                ? () {
                                    _stopPlayback();
                                    _setStep(0);
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 28,
                            ),
                            tooltip: 'Previous Step',
                            color: _currentStep > 0
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            onPressed: _currentStep > 0
                                ? () {
                                    _stopPlayback();
                                    _setStep(_currentStep - 1);
                                  }
                                : null,
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.player1,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: hasMoves ? _togglePlayback : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlaying ? 'Pause' : 'Auto-Play',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              size: 28,
                            ),
                            tooltip: 'Next Step',
                            color: _currentStep < _states.length - 1
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            onPressed: _currentStep < _states.length - 1
                                ? () {
                                    _stopPlayback();
                                    _setStep(_currentStep + 1);
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page_rounded),
                            tooltip: 'Jump to Final Result',
                            color: _currentStep < _states.length - 1
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            onPressed: _currentStep < _states.length - 1
                                ? () {
                                    _stopPlayback();
                                    _setStep(_states.length - 1);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
