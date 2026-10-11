import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_session.dart';
import '../providers/match_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/triangle_tactics_board.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _resultsDialogShown = false;

  void _showResultsDialog(BuildContext context, MatchUiState matchState) {
    if (_resultsDialogShown) return;
    _resultsDialogShown = true;

    final gState = matchState.gameState;
    if (gState == null) return;

    final isWinner = gState.winnerId == PlayerSession.currentId;
    final isDraw = gState.isDraw;

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
              isDraw
                  ? 'Even tactical battle!'
                  : (isWinner
                        ? 'You dominated the board and captured more territory!'
                        : 'Your opponent claimed more territory this match.'),
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
                      const Text(
                        'PLAYER 1',
                        style: TextStyle(
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
                      const Text(
                        'PLAYER 2',
                        style: TextStyle(
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Resign Match?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Forfeiting this match will award the victory to your opponent.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(matchProvider.notifier).resign();
            },
            child: const Text('Resign'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLocal ? 'Triangle Tactics (Pass & Play)' : 'Triangle Tactics',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              isLocal
                  ? 'Local 2-Player Match'
                  : (match?.roomCode != null
                        ? 'Room: ${match!.roomCode}'
                        : 'Public Online Match'),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: AppColors.error),
            tooltip: 'Resign',
            onPressed: gState.isTerminal ? null : _confirmResignation,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Extra turn notice banner
            if (matchState.showExtraTurnNotice)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.amber,
                child: const Center(
                  child: Text(
                    '🔥 TRIANGLE COMPLETED! EXTRA TURN AWARDED!',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

            // Scoreboard Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.player1,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isP1Me ? 'You (P1)' : 'Player 1',
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
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
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.player2,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLocal
                                      ? 'Player 2'
                                      : (match?.player2Id == null
                                            ? 'Waiting...'
                                            : (!isP1Me
                                                  ? 'You (P2)'
                                                  : 'Player 2')),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: !isMatchActive
                  ? AppColors.surfaceElevated
                  : (isMyTurn
                        ? (isLocal && gState.activePlayerId == 'Player 2'
                              ? AppColors.player2Surface
                              : AppColors.player1Surface)
                        : AppColors.surfaceElevated),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      !isMatchActive
                          ? Icons.hourglass_top
                          : (isMyTurn ? Icons.touch_app : Icons.hourglass_top),
                      size: 16,
                      color: !isMatchActive
                          ? AppColors.player2
                          : (isMyTurn
                                ? (isLocal &&
                                          gState.activePlayerId == 'Player 2'
                                      ? AppColors.player2
                                      : AppColors.player1)
                                : AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !isMatchActive
                          ? 'WAITING FOR OPPONENT TO JOIN...'
                          : (isLocal
                                ? (gState.activePlayerId == 'Player 1'
                                      ? 'PLAYER 1 (Teal) — Connect an edge'
                                      : 'PLAYER 2 (Amber) — Connect an edge')
                                : (isMyTurn
                                      ? 'YOUR TURN — Tap 2 adjacent pegs to connect an edge'
                                      : 'OPPONENT\'S TURN — Waiting for move...')),
                      style: TextStyle(
                        color: !isMatchActive
                            ? AppColors.player2
                            : (isMyTurn
                                  ? (isLocal &&
                                            gState.activePlayerId == 'Player 2'
                                        ? AppColors.player2
                                        : AppColors.player1)
                                  : AppColors.textMuted),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: TriangleTacticsBoard(
                        state: gState,
                        currentUserId: isLocal
                            ? gState.activePlayerId
                            : currentUserId,
                        isInteractive:
                            isMatchActive && isMyTurn && !gState.isTerminal,
                        onMoveSubmitted: (n1, n2) {
                          ref.read(matchProvider.notifier).submitMove(n1, n2);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Instructions Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: Text(
                'Complete any triangle to capture it (+1 point) and earn an extra turn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
