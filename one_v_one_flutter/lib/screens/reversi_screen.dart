import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/reversi_board.dart';
import '../widgets/reversi_rules_dialog.dart';

enum ReversiScreenMode {
  vsAi,
  passAndPlay,
}

class ReversiScreen extends ConsumerStatefulWidget {
  final ReversiScreenMode initialMode;
  final int aiDepth;

  const ReversiScreen({
    super.key,
    this.initialMode = ReversiScreenMode.vsAi,
    this.aiDepth = 3,
  });

  @override
  ConsumerState<ReversiScreen> createState() => _ReversiScreenState();
}

class _ReversiScreenState extends ConsumerState<ReversiScreen> {
  late ReversiEngine _engine;
  late ReversiState _state;
  late ReversiScreenMode _mode;
  late int _aiDepth;

  static const String _p1Id = 'Player 1';
  static const String _p2AiId = 'Tactical Bot';
  static const String _p2HumanId = 'Player 2';

  bool _isAiThinking = false;
  Timer? _turnTimer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _engine = ReversiEngine();
    _mode = widget.initialMode;
    _aiDepth = widget.aiDepth;
    _startNewGame();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _turnTimer?.cancel();
    final p2 = _mode == ReversiScreenMode.vsAi ? _p2AiId : _p2HumanId;
    setState(() {
      _state = ReversiState.initial(
        player1Id: _p1Id,
        player2Id: p2,
      );
      _isAiThinking = false;
      _secondsLeft = 30;
    });
    _startTimer();
  }

  void _startTimer() {
    _turnTimer?.cancel();
    _secondsLeft = 30;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_state.isTerminal) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          if (_secondsLeft <= 5) {
            SoundService.playTick();
          }
        } else {
          // Timeout: player with fewer disks or current active forfeits
          final opponent = _state.activePlayerId == _state.player1Id
              ? _state.player2Id
              : _state.player1Id;
          _state = _state.copyWith(
            isTerminal: true,
            winnerId: opponent,
          );
          timer.cancel();
        }
      });
    });
  }

  Set<String> _getValidMoveCoords(String playerId) {
    final moves = _engine.getValidMoves(_state, playerId);
    final set = <String>{};
    for (final m in moves) {
      if (!m.isPass) {
        set.add('${m.row},${m.col}');
      }
    }
    return set;
  }

  void _onSquareSelected(int row, int col) {
    if (_state.isTerminal || _isAiThinking) return;

    final active = _state.activePlayerId;
    if (_mode == ReversiScreenMode.vsAi && active != _p1Id) return;

    _applyMove(active, row, col);
  }

  void _applyMove(String playerId, int row, int col) {
    final move = ReversiMove(row: row, col: col);
    final result = _engine.applyMove(_state, playerId, move);

    if (result is MoveAccepted) {
      final next = result.nextState as ReversiState;
      SoundService.playMove();

      setState(() {
        _state = next;
        _secondsLeft = 30;
      });

      if (next.isTerminal) {
        _handleGameOver();
      } else if (_mode == ReversiScreenMode.vsAi &&
          next.activePlayerId == _p2AiId) {
        _scheduleAiMove();
      }
    }
  }

  void _scheduleAiMove() {
    setState(() => _isAiThinking = true);

    Timer(const Duration(milliseconds: 550), () {
      if (!mounted || _state.isTerminal) return;

      final bot = ReversiBot(engine: _engine, maxDepth: _aiDepth);
      final bestMove = bot.selectBestMove(_state);

      final result = _engine.applyMove(_state, _p2AiId, bestMove);
      if (result is MoveAccepted) {
        final next = result.nextState as ReversiState;
        SoundService.playMove();

        setState(() {
          _state = next;
          _isAiThinking = false;
          _secondsLeft = 30;
        });

        if (next.isTerminal) {
          _handleGameOver();
        } else if (next.activePlayerId == _p2AiId) {
          // Opponent passed, AI plays again
          _scheduleAiMove();
        }
      } else {
        setState(() => _isAiThinking = false);
      }
    });
  }

  void _handleGameOver() {
    _turnTimer?.cancel();
    setState(() {});
    SoundService.playVictory();
  }

  void _handlePass() {
    if (_state.isTerminal || _isAiThinking) return;
    final active = _state.activePlayerId;
    final result = _engine.applyMove(_state, active, const ReversiMove.pass());
    if (result is MoveAccepted) {
      final next = result.nextState as ReversiState;
      setState(() {
        _state = next;
        _secondsLeft = 30;
      });
      if (next.isTerminal) {
        _handleGameOver();
      } else if (_mode == ReversiScreenMode.vsAi &&
          next.activePlayerId == _p2AiId) {
        _scheduleAiMove();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);
    final activeId = _state.activePlayerId;
    final isP1Active = activeId == _state.player1Id;
    final validCoords = _getValidMoveCoords(activeId);
    final hasLegalPlacements = validCoords.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chroma Reversi Duel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: theme.textPrimary,
              ),
            ),
            Text(
              _mode == ReversiScreenMode.vsAi
                  ? 'vs Tactical Bot (Depth $_aiDepth)'
                  : 'Pass & Play (Local 1v1)',
              style: TextStyle(
                fontSize: 11,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: theme.accent),
            tooltip: 'Rules Guide',
            onPressed: () => ReversiRulesDialog.show(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.textSecondary),
            tooltip: 'Restart Match',
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                // Score & Territory Header
                _buildScoreHeader(theme),

                // Active Turn Status Bar
                _buildTurnBanner(theme, isP1Active, hasLegalPlacements),

                // 8x8 Board
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ReversiBoard(
                      state: _state,
                      currentUserId: activeId,
                      validMovesCoordinates: validCoords,
                      onSquareSelected: _onSquareSelected,
                      isInteractive: !_isAiThinking && !_state.isTerminal,
                    ),
                  ),
                ),

                // Pass / Action Controls
                _buildBottomControls(theme, hasLegalPlacements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(AppThemeData theme) {
    final total = _state.player1Score + _state.player2Score;
    final p1Pct = total == 0 ? 0.5 : _state.player1Score / total;
    final p2Pct = total == 0 ? 0.5 : _state.player2Score / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player 1 (Dark Disks / Teal)
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF042F2E)],
                      ),
                      border: Border.all(color: AppColors.teal, width: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _p1Id,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_state.player1Score} Disks (${(p1Pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Timer Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _secondsLeft <= 5
                      ? AppColors.error.withValues(alpha: 0.15)
                      : theme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _secondsLeft <= 5
                        ? AppColors.error
                        : theme.surfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: _secondsLeft <= 5 ? AppColors.error : theme.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_secondsLeft}s',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _secondsLeft <= 5
                            ? AppColors.error
                            : theme.accent,
                      ),
                    ),
                  ],
                ),
              ),

              // Player 2 (Light Disks / White)
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _mode == ReversiScreenMode.vsAi ? _p2AiId : _p2HumanId,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_state.player2Score} Disks (${(p2Pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Colors.white, Color(0xFF94A3B8)],
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Split Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: _state.player1Score,
                    child: Container(color: AppColors.teal),
                  ),
                  Expanded(
                    flex: _state.player2Score,
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnBanner(
    AppThemeData theme,
    bool isP1Active,
    bool hasLegalPlacements,
  ) {
    if (_state.isTerminal) {
      final winner = _state.winnerId;
      final isDraw = _state.isDraw;
      final won = winner == _p1Id;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDraw
              ? theme.surfaceElevated
              : (won ? AppColors.teal : AppColors.player2).withValues(
                  alpha: 0.2,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDraw
                ? theme.surfaceBorder
                : (won ? AppColors.teal : AppColors.player2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDraw ? Icons.handshake : Icons.emoji_events,
              size: 16,
              color: won ? AppColors.teal : Colors.amber,
            ),
            const SizedBox(width: 8),
            Text(
              isDraw
                  ? 'MATCH TIED (${_state.player1Score} - ${_state.player2Score})'
                  : '${winner?.toUpperCase()} VICTORIOUS (${_state.player1Score} - ${_state.player2Score})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }

    if (_isAiThinking) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.teal,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'TACTICAL AI CALCULATING FLANKS...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.tealLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isP1Active ? AppColors.teal : Colors.white).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isP1Active ? AppColors.teal : Colors.white).withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isP1Active ? AppColors.teal : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            !hasLegalPlacements
                ? 'NO LEGAL MOVES AVAILABLE — MUST PASS TURN'
                : (isP1Active
                      ? "YOUR TURN (DARK / TEAL)"
                      : "OPPONENT'S TURN (LIGHT / WHITE)"),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: !hasLegalPlacements
                  ? AppColors.player2
                  : (isP1Active ? AppColors.tealLight : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppThemeData theme, bool hasLegalPlacements) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.surfaceBorder)),
      ),
      child: Row(
        children: [
          // Mode Toggle
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.textSecondary,
              side: BorderSide(color: theme.surfaceBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              _mode == ReversiScreenMode.vsAi
                  ? Icons.smart_toy_outlined
                  : Icons.people_outline,
              size: 16,
            ),
            label: Text(
              _mode == ReversiScreenMode.vsAi ? 'vs AI' : 'Pass & Play',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () {
              setState(() {
                _mode = _mode == ReversiScreenMode.vsAi
                    ? ReversiScreenMode.passAndPlay
                    : ReversiScreenMode.vsAi;
              });
              _startNewGame();
            },
          ),
          const SizedBox(width: 12),

          // If no legal moves, Pass button is highlighted
          if (!hasLegalPlacements && !_state.isTerminal)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player2,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.fast_forward, size: 18),
                label: const Text(
                  'Pass Turn to Opponent',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _handlePass,
              ),
            )
          else
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accent,
                  side: BorderSide(color: theme.accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Rematch',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _startNewGame,
              ),
            ),
        ],
      ),
    );
  }
}
