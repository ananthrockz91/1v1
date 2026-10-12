import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import '../models/player_session.dart';
import '../providers/match_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/player_avatar.dart';
import '../widgets/triangle_tactics_board.dart';
import '../widgets/game_rules_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static const int _turnTimeLimit = 30; // 30 seconds per turn
  Timer? _turnTimer;
  int _secondsRemaining = _turnTimeLimit;
  int _lastObservedVersion = -1;
  String? _lastActivePlayerId;
  bool _resultsDialogShown = false;
  String? _timeoutReason;

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _syncTurnTimer(TriangleTacticsState gState, bool isMatchActive) {
    if (!isMatchActive || gState.isTerminal) {
      if (_turnTimer != null) {
        _turnTimer?.cancel();
        _turnTimer = null;
      }
      return;
    }

    if (_lastObservedVersion != gState.stateVersion ||
        _lastActivePlayerId != gState.activePlayerId) {
      _lastObservedVersion = gState.stateVersion;
      _lastActivePlayerId = gState.activePlayerId;
      _secondsRemaining = _turnTimeLimit;
      _turnTimer?.cancel();
      _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            timer.cancel();
            _onTurnTimeout();
          }
        });
      });
    }
  }

  void _onTurnTimeout() {
    final matchState = ref.read(matchProvider);
    final gState = matchState.gameState;
    if (gState == null || gState.isTerminal) return;

    final isLocal = matchState.isLocal;
    final currentUserId = PlayerSession.currentId;
    final activePlayer = gState.activePlayerId;

    if (isLocal) {
      final winner = activePlayer == 'Player 1'
          ? (matchState.isAiMatch ? 'Tactical Bot (AI)' : 'Player 2')
          : 'Player 1';
      setState(() {
        _timeoutReason =
            'Time\'s up! $activePlayer ran out of time. $winner wins!';
      });
      ref.read(matchProvider.notifier).resign(timedOutPlayerId: activePlayer);
      return;
    }

    final match = matchState.match;
    if (match == null || match.status != 'in_progress') return;

    final isMyTurn = (activePlayer == currentUserId);
    if (isMyTurn) {
      setState(() {
        _timeoutReason =
            'Time\'s up! You ran out of time on your turn. Defeat.';
      });
      ref.read(matchProvider.notifier).resign(timedOutPlayerId: currentUserId);
    } else {
      setState(() {
        _timeoutReason =
            'Time\'s up! Opponent ran out of time. Victory awarded to you!';
      });
      ref.read(matchProvider.notifier).resign(timedOutPlayerId: activePlayer);
    }
  }

  void _showResultsDialog(BuildContext context, MatchUiState matchState) {
    if (_resultsDialogShown) return;
    _resultsDialogShown = true;
    _turnTimer?.cancel();

    final gState = matchState.gameState;
    if (gState == null) return;

    final isWinner = matchState.isLocal
        ? (gState.winnerId == 'Player 1')
        : (gState.winnerId == PlayerSession.currentId);
    final isDraw = gState.isDraw;

    final subtitle =
        _timeoutReason ??
        (isDraw
            ? 'Even tactical battle!'
            : (isWinner
                  ? 'You dominated the board and captured more territory!'
                  : 'Your opponent claimed more territory this match.'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Center(
          child: Text(
            isDraw ? 'MATCH DRAW' : (isWinner ? '🏆 VICTORY!' : 'DEFEAT'),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDraw
                  ? AppColors.warning
                  : (isWinner ? AppColors.player1 : AppColors.player2),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            // Scores Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      PlayerAvatar(
                        avatarSeed: matchState.player1Avatar,
                        displayName: matchState.player1Name,
                        size: 38,
                        borderColor: AppColors.player1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        matchState.player1Name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.player1,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gState.player1Score}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '—',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 24),
                  ),
                  Column(
                    children: [
                      PlayerAvatar(
                        avatarSeed: matchState.player2Avatar,
                        displayName: matchState.player2Name,
                        size: 38,
                        borderColor: AppColors.player2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        matchState.player2Name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.player2,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gState.player2Score}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(matchProvider.notifier).clearMatch();
              Navigator.pop(context);
            },
            child: const Text(
              'Return to Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResignation() {
    final matchState = ref.read(matchProvider);
    final isLocal = matchState.isLocal;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Resign & Leave?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Leaving this game will forfeit the match. Your opponent will immediately be declared the winner.\n\nAre you sure you want to resign?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Stay in Game',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              _turnTimer?.cancel();
              if (!isLocal) {
                await ref.read(matchProvider.notifier).resign();
              } else {
                ref.read(matchProvider.notifier).clearMatch();
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Resign & Exit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final currentUserId = PlayerSession.currentId;

    final gState = matchState.gameState;
    final match = matchState.match;
    final isLocal = matchState.isLocal;

    if (gState != null && gState.isTerminal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultsDialog(context, matchState);
      });
    }

    if (gState == null || (!isLocal && match == null)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.player1),
        ),
      );
    }

    final isMatchActive = isLocal || match?.status == 'in_progress';
    final isMyTurn = isLocal ? true : (gState.activePlayerId == currentUserId);
    final isP1Me = isLocal ? true : (match?.player1Id == currentUserId);
    final p1Id = isLocal ? 'Player 1' : match?.player1Id;
    final p2Id = isLocal ? 'Player 2' : match?.player2Id;

    final isP1Active = isLocal
        ? gState.activePlayerId == 'Player 1'
        : gState.activePlayerId == match?.player1Id;
    final isP2Active = isLocal
        ? gState.activePlayerId == 'Player 2'
        : gState.activePlayerId == match?.player2Id;
    final activePlayerColor = isP2Active
        ? AppColors.player2
        : AppColors.player1;
    final activePlayerSurface = isP2Active
        ? AppColors.player2Surface
        : AppColors.player1Surface;

    // Synchronize the turn timer
    _syncTurnTimer(gState, isMatchActive);

    ref.listen<MatchUiState>(matchProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return PopScope(
      canPop: gState.isTerminal,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmResignation();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Leave Match',
            onPressed: () {
              if (gState.isTerminal) {
                ref.read(matchProvider.notifier).clearMatch();
                Navigator.pop(context);
              } else {
                _confirmResignation();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLocal ? 'Triangle Tactics (Pass & Play)' : 'Triangle Tactics',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isLocal
                    ? 'Local 2-Player Match'
                    : (match?.roomCode != null
                          ? 'Room: ${match!.roomCode}'
                          : 'Public Online Match'),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                color: AppColors.player1,
              ),
              tooltip: 'Game Rules & Guide',
              onPressed: () => GameRulesDialog.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: AppColors.error),
              tooltip: 'Resign Match',
              onPressed: gState.isTerminal ? null : _confirmResignation,
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
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Player 1 Card (Teal)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gState.activePlayerId == p1Id
                                  ? AppColors.player1Surface
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gState.activePlayerId == p1Id
                                    ? AppColors.player1
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                PlayerAvatar(
                                  avatarSeed: matchState.player1Avatar,
                                  displayName: matchState.player1Name,
                                  size: 30,
                                  borderColor: AppColors.player1,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isP1Me
                                            ? '${matchState.player1Name} (You)'
                                            : matchState.player1Name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'Triangles',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${gState.player1Score}',
                                  style: const TextStyle(
                                    color: AppColors.player1,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: isMatchActive && !gState.isTerminal
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: CircularProgressIndicator(
                                            value:
                                                (_secondsRemaining /
                                                        _turnTimeLimit)
                                                    .clamp(0.0, 1.0),
                                            strokeWidth: 3.2,
                                            backgroundColor:
                                                AppColors.surfaceBorder,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _secondsRemaining <= 10
                                                      ? AppColors.error
                                                      : activePlayerColor,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          '$_secondsRemaining',
                                          style: TextStyle(
                                            color: _secondsRemaining <= 10
                                                ? AppColors.error
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'TIMER',
                                      style: TextStyle(
                                        color: _secondsRemaining <= 10
                                            ? AppColors.error
                                            : AppColors.textMuted,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'VS',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        // Player 2 Card (Amber)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gState.activePlayerId == p2Id
                                  ? AppColors.player2Surface
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gState.activePlayerId == p2Id
                                    ? AppColors.player2
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                PlayerAvatar(
                                  avatarSeed: matchState.player2Avatar,
                                  displayName: matchState.player2Name,
                                  size: 30,
                                  borderColor: AppColors.player2,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        matchState.isAiMatch
                                            ? 'Tactical Bot (AI)'
                                            : (isLocal
                                                  ? 'Player 2'
                                                  : (match?.player2Id == null
                                                        ? 'Waiting...'
                                                        : (!isP1Me
                                                              ? '${matchState.player2Name} (You)'
                                                              : matchState
                                                                    .player2Name))),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'Triangles',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${gState.player2Score}',
                                  style: const TextStyle(
                                    color: AppColors.player2,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Turn Indicator Subheader
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: !isMatchActive
                          ? AppColors.surfaceElevated
                          : (isMyTurn
                                ? activePlayerSurface
                                : (matchState.isAiMatch
                                      ? AppColors.player2Surface.withValues(
                                          alpha: 0.35,
                                        )
                                      : AppColors.surfaceElevated)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !isMatchActive
                                ? Icons.hourglass_top
                                : (_secondsRemaining <= 10
                                      ? Icons.timer_outlined
                                      : (matchState.isAiMatch && !isMyTurn
                                            ? Icons.smart_toy
                                            : (isMyTurn
                                                  ? Icons.touch_app
                                                  : Icons.hourglass_top))),
                            size: 16,
                            color: !isMatchActive
                                ? AppColors.player2
                                : (_secondsRemaining <= 10
                                      ? AppColors.error
                                      : (isMyTurn
                                            ? activePlayerColor
                                            : (matchState.isAiMatch
                                                  ? AppColors.player2
                                                  : AppColors.textMuted))),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              !isMatchActive
                                  ? 'WAITING FOR OPPONENT TO JOIN...'
                                  : (matchState.isAiMatch
                                        ? (isMyTurn
                                              ? 'YOUR TURN (${_secondsRemaining}s) — Connect 4 pegs in a straight line!'
                                              : '🤖 TACTICAL BOT THINKING... (${_secondsRemaining}s)')
                                        : (isLocal
                                              ? (isP1Active
                                                    ? 'PLAYER 1 (${_secondsRemaining}s) — Stretch rubber band across 4 pegs'
                                                    : 'PLAYER 2 (${_secondsRemaining}s) — Stretch rubber band across 4 pegs')
                                              : (isMyTurn
                                                    ? 'YOUR TURN (${isP1Me ? "Teal" : "Amber"}, ${_secondsRemaining}s) — Stretch rubber band across 4 pegs'
                                                    : 'OPPONENT\'S TURN (${_secondsRemaining}s) — Waiting for move...'))),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isMatchActive
                                    ? AppColors.player2
                                    : (_secondsRemaining <= 10
                                          ? AppColors.error
                                          : (isMyTurn
                                                ? activePlayerColor
                                                : (matchState.isAiMatch
                                                      ? AppColors.player2
                                                      : AppColors.textMuted))),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Interactive Board Canvas
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
                              state: gState,
                              currentUserId: isLocal
                                  ? gState.activePlayerId
                                  : currentUserId,
                              isInteractive:
                                  isMatchActive &&
                                  isMyTurn &&
                                  !gState.isTerminal,
                              onMoveSubmitted: (n1, n2) {
                                ref
                                    .read(matchProvider.notifier)
                                    .submitMove(n1, n2);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Strategic Instructions Footer
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Text(
                      '🔷 Connect 4 pegs in a straight line with a rubber band • Form triangles to claim 3D tokens • 1 move per turn',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
