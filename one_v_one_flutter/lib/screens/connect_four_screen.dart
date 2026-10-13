import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/connect_four_board.dart';
import '../widgets/connect_four_rules_dialog.dart';

enum ConnectFourMode {
  vsAi,
  passAndPlay,
}

class ConnectFourScreen extends ConsumerStatefulWidget {
  final ConnectFourMode initialMode;

  const ConnectFourScreen({
    super.key,
    this.initialMode = ConnectFourMode.vsAi,
  });

  @override
  ConsumerState<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends ConsumerState<ConnectFourScreen> {
  late ConnectFourEngine _engine;
  late ConnectFourState _state;
  late ConnectFourMode _mode;

  static const String _p1Id = 'Player 1';
  static const String _p2AiId = 'Tactical Bot';
  static const String _p2HumanId = 'Player 2';

  bool _isAiThinking = false;
  bool _isGameOver = false;
  bool _showGameOverSummary = true;
  Timer? _turnTimer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _engine = ConnectFourEngine();
    _mode = widget.initialMode;
    _startNewGame();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _turnTimer?.cancel();
    final p2 = _mode == ConnectFourMode.vsAi ? _p2AiId : _p2HumanId;
    setState(() {
      _state = ConnectFourState.initial(
        player1Id: _p1Id,
        player2Id: p2,
      );
      _isAiThinking = false;
      _isGameOver = false;
      _showGameOverSummary = true;
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
          // Turn timeout: current active player forfeits
          final opponent = _state.activePlayerId == _state.player1Id
              ? _state.player2Id
              : _state.player1Id;
          _state = _state.copyWith(
            isTerminal: true,
            winnerId: opponent,
          );
          _isGameOver = true;
          _showGameOverSummary = true;
          timer.cancel();
        }
      });
    });
  }

  void _onColumnSelected(int column) {
    if (_state.isTerminal || _isAiThinking) return;

    final active = _state.activePlayerId;
    // In vsAi mode, human only plays Player 1
    if (_mode == ConnectFourMode.vsAi && active != _p1Id) return;

    _applyColumnMove(active, column);
  }

  void _applyColumnMove(String playerId, int column) {
    final result = _engine.applyMove(
      _state,
      playerId,
      ConnectFourMove(column: column),
    );
    if (result is MoveAccepted) {
      SoundService.playMove();
      final next = result.nextState as ConnectFourState;
      setState(() {
        _state = next;
        _secondsLeft = 30;
      });

      if (next.isTerminal) {
        _turnTimer?.cancel();
        if (next.winnerId != null) {
          SoundService.playVictory();
        }
        // Seamlessly update game over state while keeping board in full view
        setState(() {
          _isGameOver = true;
          _showGameOverSummary = true;
        });
        return;
      }

      // Check if it's now AI's turn
      if (_mode == ConnectFourMode.vsAi && next.activePlayerId == _p2AiId) {
        _triggerAiMove();
      }
    }
  }

  void _triggerAiMove() {
    setState(() => _isAiThinking = true);
    // Realistic AI reaction delay
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _state.isTerminal) return;

      final botCol = ConnectFourBot.selectBestColumn(
        state: _state,
        botPlayerId: _p2AiId,
      );

      setState(() => _isAiThinking = false);
      _applyColumnMove(_p2AiId, botCol);
    });
  }

  void _confirmExit() {
    if (_state.moveHistory.isEmpty || _state.isTerminal) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          'Leave Match?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Leaving will reset the current board. Are you sure you want to quit?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Playing',
              style: TextStyle(color: AppColors.textMuted),
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
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Quit Game',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final isP1Active = _state.activePlayerId == _state.player1Id;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          backgroundColor: theme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.textPrimary),
            onPressed: _confirmExit,
          ),
          title: Text(
            'Gravity Drop Duel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: soundEnabled ? theme.accent : theme.textMuted,
              ),
              tooltip: soundEnabled ? 'Mute' : 'Unmute',
              onPressed: () {
                final next = !soundEnabled;
                SoundService.enabled = next;
                ref.read(soundEnabledProvider.notifier).state = next;
              },
            ),
            IconButton(
              icon: Icon(
                Icons.help_outline_rounded,
                color: theme.accent,
              ),
              tooltip: 'Rules & Strategy',
              onPressed: () => ConnectFourRulesDialog.show(context),
            ),
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: theme.textSecondary,
              ),
              tooltip: 'Restart Game',
              onPressed: _startNewGame,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Mode Selector & Status Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.surfaceElevated,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mode Toggle Pill
                    SegmentedButton<ConnectFourMode>(
                      segments: const [
                        ButtonSegment(
                          value: ConnectFourMode.vsAi,
                          label: Text('vs AI', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.smart_toy_outlined, size: 14),
                        ),
                        ButtonSegment(
                          value: ConnectFourMode.passAndPlay,
                          label: Text(
                            '2-Player',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.people_outline, size: 14),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _mode = selected.first;
                          _startNewGame();
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        selectedBackgroundColor: AppColors.player1.withValues(
                          alpha: 0.2,
                        ),
                        selectedForegroundColor: AppColors.player1,
                        foregroundColor: AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),

                    // Turn Timer Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _secondsLeft <= 5
                            ? AppColors.error.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _secondsLeft <= 5
                              ? AppColors.error
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: _secondsLeft <= 5
                                ? AppColors.error
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_secondsLeft}s',
                            style: TextStyle(
                              color: _secondsLeft <= 5
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Player 1 vs Player 2 Status Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Player 1 Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isP1Active
                              ? AppColors.player1.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isP1Active
                                ? AppColors.player1
                                : AppColors.surfaceBorder,
                            width: isP1Active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.player1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _state.player1Id,
                                style: TextStyle(
                                  color: isP1Active
                                      ? AppColors.player1
                                      : AppColors.textSecondary,
                                  fontWeight: isP1Active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Player 2 Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: !isP1Active
                              ? AppColors.player2.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !isP1Active
                                ? AppColors.player2
                                : AppColors.surfaceBorder,
                            width: !isP1Active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.player2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _state.player2Id,
                                style: TextStyle(
                                  color: !isP1Active
                                      ? AppColors.player2
                                      : AppColors.textSecondary,
                                  fontWeight: !isP1Active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // AI Thinking / Turn Indicator Banner
              Container(
                height: 28,
                alignment: Alignment.center,
                child: _isAiThinking
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.player2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tactical Bot calculating optimal drop...',
                            style: TextStyle(
                              color: AppColors.player2,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_state.isTerminal) ...[
                            Icon(
                              Icons.stars_rounded,
                              color: theme.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _state.isTerminal
                                ? (_state.isDraw
                                      ? 'TACTICAL DRAW (BOARD FULL)'
                                      : '🏆 ${_state.winnerId?.toUpperCase()} CONNECTS 4 IN A ROW!')
                                : '${_state.activePlayerId.toUpperCase()}\'S TURN',
                            style: TextStyle(
                              color: _state.isTerminal
                                  ? theme.accent
                                  : (isP1Active
                                        ? AppColors.player1
                                        : AppColors.player2),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
              ),

              // Connect Four Interactive Board
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ConnectFourBoard(
                    state: _state,
                    currentUserId: _state.activePlayerId,
                    onColumnSelected: _onColumnSelected,
                    isInteractive: !_isAiThinking && !_state.isTerminal,
                  ),
                ),
              ),

              // Footer / Game Over Controls
              if (_state.isTerminal || _isGameOver) ...[
                if (_showGameOverSummary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      border: Border(
                        top: BorderSide(
                          color: _state.isDraw
                              ? AppColors.surfaceBorder
                              : (_state.winnerId == _p1Id
                                    ? AppColors.player1
                                    : AppColors.player2),
                          width: 2.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _state.isDraw
                                      ? Icons.handshake_outlined
                                      : Icons.emoji_events,
                                  color: _state.isDraw
                                      ? AppColors.textSecondary
                                      : (_state.winnerId == _p1Id
                                            ? AppColors.player1
                                            : AppColors.player2),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _state.isDraw
                                      ? 'Tactical Draw (Grid Full)'
                                      : '🏆 ${_state.winnerId} Wins!',
                                  style: TextStyle(
                                    color: _state.isDraw
                                        ? AppColors.textPrimary
                                        : (_state.winnerId == _p1Id
                                              ? AppColors.player1
                                              : AppColors.player2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                side: BorderSide(
                                  color: theme.accent,
                                ),
                                foregroundColor: theme.accent,
                              ),
                              onPressed: () =>
                                  setState(() => _showGameOverSummary = false),
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                              ),
                              label: const Text(
                                'View Full Board',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.player1,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _startNewGame,
                                icon: const Icon(
                                  Icons.replay_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Play Rematch',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(
                                    color: AppColors.surfaceBorder,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Exit'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  // Minimal Inspector Pill at bottom
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: AppColors.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: theme.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Inspecting Connected Dots',
                              style: TextStyle(
                                color: theme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: AppColors.textSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => _showGameOverSummary = true),
                              child: const Text(
                                'Show Menu',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.player1,
                                foregroundColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: _startNewGame,
                              child: const Text(
                                'Rematch',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ] else ...[
                // Normal In-game footer bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: AppColors.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Move #${_state.moveHistory.length + 1}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () => ConnectFourRulesDialog.show(context),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.player1,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'How to Win',
                              style: TextStyle(
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
