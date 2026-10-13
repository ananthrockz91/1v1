import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../models/player_session.dart';
import '../services/sound_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/connect_four_board.dart';
import '../widgets/connect_four_rules_dialog.dart';

enum ConnectFourMode {
  vsAi,
  passAndPlay,
  online,
}

enum GravityGridPreset {
  classic(
    label: 'Classic 7×6',
    rows: 6,
    cols: 7,
    targetStreak: 4,
    badge: 'Connect 4',
  ),
  tactical(
    label: 'Tactical 8×7',
    rows: 7,
    cols: 8,
    targetStreak: 4,
    badge: 'Connect 4',
  ),
  grandArena(
    label: 'Grand 9×8',
    rows: 8,
    cols: 9,
    targetStreak: 5,
    badge: 'Connect 5',
  );

  final String label;
  final int rows;
  final int cols;
  final int targetStreak;
  final String badge;

  const GravityGridPreset({
    required this.label,
    required this.rows,
    required this.cols,
    required this.targetStreak,
    required this.badge,
  });
}

class ConnectFourScreen extends ConsumerStatefulWidget {
  final ConnectFourMode initialMode;
  final GameMatch? onlineMatch;
  final GravityGridPreset? preset;

  const ConnectFourScreen({
    super.key,
    this.initialMode = ConnectFourMode.vsAi,
    this.onlineMatch,
    this.preset,
  });

  @override
  ConsumerState<ConnectFourScreen> createState() => _ConnectFourScreenState();
}

class _ConnectFourScreenState extends ConsumerState<ConnectFourScreen> {
  late ConnectFourEngine _engine;
  late ConnectFourState _state;
  late ConnectFourMode _mode;

  GravityGridPreset _selectedPreset = GravityGridPreset.classic;

  static const String _p1Id = 'Player 1';
  static const String _p2AiId = 'Tactical Bot';
  static const String _p2HumanId = 'Player 2';

  bool _isAiThinking = false;
  bool _isGameOver = false;
  bool _showGameOverSummary = true;
  Timer? _turnTimer;
  int _secondsLeft = 30;

  GameMatch? _onlineMatch;
  StreamSubscription<MatchEvent>? _matchSubscription;
  bool _isWaitingForOpponent = false;

  String _player1Name = 'Player 1';
  String _player2Name = 'Player 2';

  String _getRoomCode() {
    if (_onlineMatch == null) return '';
    if (_onlineMatch!.roomCode != null && _onlineMatch!.roomCode!.isNotEmpty) {
      return _onlineMatch!.roomCode!;
    }
    final id = _onlineMatch!.matchId;
    if (id.length > 6) {
      return id.substring(id.length - 6).toUpperCase();
    }
    return id.toUpperCase();
  }

  String _getDisplayName(bool isP1) {
    if (_mode == ConnectFourMode.online) {
      return isP1 ? _player1Name : _player2Name;
    }
    if (_mode == ConnectFourMode.vsAi) {
      return isP1 ? '${PlayerSession.displayName} (You)' : _p2AiId;
    }
    return isP1 ? _p1Id : _p2HumanId;
  }

  String _getPlayerName(String? playerId) {
    if (playerId == null || playerId.isEmpty) return 'Nobody';
    if (playerId == PlayerSession.currentId) return PlayerSession.displayName;
    if (playerId == _state.player1Id || playerId == _p1Id) {
      return _player1Name.replaceAll(' (You)', '');
    }
    if (playerId == _state.player2Id ||
        playerId == _p2AiId ||
        playerId == _p2HumanId) {
      return _player2Name.replaceAll(' (You)', '');
    }
    return playerId;
  }

  Future<void> _fetchProfiles() async {
    final p1Id = _onlineMatch?.player1Id ?? _state.player1Id;
    final p2Id = _onlineMatch?.player2Id ?? _state.player2Id;

    if (p1Id == PlayerSession.currentId) {
      if (mounted) {
        setState(() {
          _player1Name = '${PlayerSession.displayName} (You)';
        });
      }
    } else if (p1Id.isNotEmpty) {
      try {
        final profile = await client.player.getProfile(p1Id);
        if (mounted && profile != null && profile.displayName.isNotEmpty) {
          setState(() {
            _player1Name = profile.displayName;
          });
        }
      } catch (_) {}
    }

    if (p2Id == PlayerSession.currentId) {
      if (mounted) {
        setState(() {
          _player2Name = '${PlayerSession.displayName} (You)';
        });
      }
    } else if (p2Id.isNotEmpty) {
      try {
        final profile = await client.player.getProfile(p2Id);
        if (mounted && profile != null && profile.displayName.isNotEmpty) {
          setState(() {
            _player2Name = profile.displayName;
          });
        }
      } catch (_) {}
    } else if (_isWaitingForOpponent) {
      if (mounted) {
        setState(() {
          _player2Name = 'Waiting...';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _engine = ConnectFourEngine();
    _mode = widget.initialMode;
    if (widget.preset != null) {
      _selectedPreset = widget.preset!;
    }

    if (_mode == ConnectFourMode.online && widget.onlineMatch != null) {
      _onlineMatch = widget.onlineMatch;
      _initOnlineMatch();
    } else {
      _startNewGame();
    }
  }

  void _initOnlineMatch() {
    final match = _onlineMatch!;
    if (match.stateJson.isNotEmpty) {
      try {
        _state = ConnectFourState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
      } catch (_) {
        _state = ConnectFourState.initial(
          player1Id: match.player1Id,
          player2Id: match.player2Id ?? '',
          rows: _selectedPreset.rows,
          cols: _selectedPreset.cols,
          targetStreak: _selectedPreset.targetStreak,
        );
      }
    } else {
      _state = ConnectFourState.initial(
        player1Id: match.player1Id,
        player2Id: match.player2Id ?? '',
        rows: _selectedPreset.rows,
        cols: _selectedPreset.cols,
        targetStreak: _selectedPreset.targetStreak,
      );
    }

    _isWaitingForOpponent = match.status == 'waiting';
    _isGameOver = _state.isTerminal;

    _player1Name = match.player1Id == PlayerSession.currentId
        ? '${PlayerSession.displayName} (You)'
        : 'Player 1';
    _player2Name = match.player2Id == PlayerSession.currentId
        ? '${PlayerSession.displayName} (You)'
        : (_isWaitingForOpponent ? 'Waiting...' : 'Player 2');

    _fetchProfiles();

    _matchSubscription = client.match
        .streamMatchEvents(match.matchId)
        .listen(
          _handleMatchEvent,
          onError: (_) {},
        );

    if (!_isWaitingForOpponent && !_state.isTerminal) {
      _startTimer();
    }
  }

  void _handleMatchEvent(MatchEvent event) {
    if (!mounted) return;

    if (event.eventType == 'matchStarted') {
      setState(() {
        _isWaitingForOpponent = false;
        if (event.stateJson != null) {
          try {
            _state = ConnectFourState.fromJson(
              jsonDecode(event.stateJson!) as Map<String, dynamic>,
            );
          } catch (_) {}
        }
        if (_onlineMatch != null) {
          _onlineMatch = _onlineMatch!.copyWith(
            status: 'in_progress',
            player2Id: _state.player2Id,
          );
        }
      });
      _fetchProfiles();
      SoundService.playMove();
      _startTimer();
      return;
    }

    if (event.eventType == 'moveAccepted' ||
        event.eventType == 'matchCompleted') {
      if (event.stateJson != null) {
        try {
          final nextState = ConnectFourState.fromJson(
            jsonDecode(event.stateJson!) as Map<String, dynamic>,
          );
          if (nextState.stateVersion >= _state.stateVersion) {
            SoundService.playMove();
            setState(() {
              _state = nextState;
              _secondsLeft = 30;
            });
            if (_onlineMatch != null) {
              _onlineMatch = _onlineMatch!.copyWith(
                stateVersion: nextState.stateVersion,
                player1Score: event.player1Score,
                player2Score: event.player2Score,
              );
            }
          }
        } catch (_) {}
      }

      if (event.isTerminal) {
        _turnTimer?.cancel();
        if (event.winnerId != null) {
          SoundService.playVictory();
        }
        setState(() {
          _isGameOver = true;
          _showGameOverSummary = true;
        });
      }
      return;
    }

    if (event.eventType == 'resigned') {
      _turnTimer?.cancel();
      setState(() {
        _isGameOver = true;
        _showGameOverSummary = true;
      });
    }
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _matchSubscription?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _turnTimer?.cancel();
    final p2 = _mode == ConnectFourMode.vsAi ? _p2AiId : _p2HumanId;

    setState(() {
      _state = ConnectFourState.initial(
        player1Id: _p1Id,
        player2Id: p2,
        rows: _selectedPreset.rows,
        cols: _selectedPreset.cols,
        targetStreak: _selectedPreset.targetStreak,
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
    if (_state.isTerminal || _isAiThinking || _isWaitingForOpponent) return;

    if (_mode == ConnectFourMode.online) {
      if (_state.activePlayerId != PlayerSession.currentId) {
        final theme = ref.read(currentThemeProvider);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: theme.surfaceBorder),
            ),
            content: Text(
              "Opponent's turn — please wait for their move",
              style: TextStyle(color: theme.textPrimary),
            ),
            duration: const Duration(milliseconds: 900),
          ),
        );
        return;
      }

      final currentVersion = _state.stateVersion;
      final result = _engine.applyMove(
        _state,
        PlayerSession.currentId,
        ConnectFourMove.drop(column),
      );
      if (result is! MoveAccepted) return;

      // Optimistically apply locally
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
        setState(() {
          _isGameOver = true;
          _showGameOverSummary = true;
        });
      }

      // Transmit to Serverpod backend with version captured BEFORE applying
      if (_onlineMatch != null) {
        client.match
            .submitMove(
              matchId: _onlineMatch!.matchId,
              playerId: PlayerSession.currentId,
              node1R: 0,
              node1C: column,
              node2R: 0,
              node2C: column,
              clientStateVersion: currentVersion,
            )
            .then((updatedMatch) {
              _onlineMatch = updatedMatch;
            })
            .catchError((err) {
              debugPrint('submitMove failed: $err');
              if (mounted) {
                final theme = ref.read(currentThemeProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: theme.statusError),
                    ),
                    content: Text(
                      'Move error: $err',
                      style: TextStyle(color: theme.statusError),
                    ),
                  ),
                );
              }
            });
      }
      return;
    }

    final active = _state.activePlayerId;
    if (_mode == ConnectFourMode.vsAi && active != _p1Id) return;

    _applyMove(active, ConnectFourMove.drop(column));
  }

  void _applyMove(String playerId, ConnectFourMove move) {
    final result = _engine.applyMove(_state, playerId, move);
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
        setState(() {
          _isGameOver = true;
          _showGameOverSummary = true;
        });
        return;
      }

      if (_mode == ConnectFourMode.vsAi && next.activePlayerId == _p2AiId) {
        _triggerAiMove();
      }
    }
  }

  void _triggerAiMove() {
    setState(() => _isAiThinking = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _state.isTerminal) return;

      final botMove = ConnectFourBot.selectBestMove(
        state: _state,
        botPlayerId: _p2AiId,
      );

      setState(() => _isAiThinking = false);
      _applyMove(_p2AiId, botMove);
    });
  }

  void _confirmExit() {
    if (_mode == ConnectFourMode.online) {
      if (_onlineMatch != null &&
          !_state.isTerminal &&
          !_isWaitingForOpponent) {
        client.match
            .resign(
              matchId: _onlineMatch!.matchId,
              playerId: PlayerSession.currentId,
            )
            .catchError((_) => _onlineMatch!);
      }
      _matchSubscription?.cancel();
      Navigator.pop(context);
      return;
    }

    if (_state.moveHistory.isEmpty || _state.isTerminal) {
      Navigator.pop(context);
      return;
    }

    final theme = ref.read(currentThemeProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.surfaceBorder),
        ),
        title: Text(
          'Leave Match?',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          'Leaving will reset the current board. Are you sure you want to quit?',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Playing',
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.statusError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Quit Match'),
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
              tooltip: 'Rules & Tactics Guide',
              onPressed: () => ConnectFourRulesDialog.show(context),
            ),
            if (_mode != ConnectFourMode.online)
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
              // Arena Config & Mode Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                color: theme.surfaceElevated,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_mode == ConnectFourMode.online)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_tethering_rounded,
                              size: 14,
                              color: theme.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ONLINE 1V1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.accent,
                                letterSpacing: 0.6,
                              ),
                            ),
                            if (_onlineMatch != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.surface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Room #${_getRoomCode()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      // Mode Toggle Pill
                      SegmentedButton<ConnectFourMode>(
                        segments: const [
                          ButtonSegment(
                            value: ConnectFourMode.vsAi,
                            label: Text(
                              'vs AI',
                              style: TextStyle(fontSize: 11),
                            ),
                            icon: Icon(Icons.smart_toy_outlined, size: 13),
                          ),
                          ButtonSegment(
                            value: ConnectFourMode.passAndPlay,
                            label: Text(
                              '2-Player',
                              style: TextStyle(fontSize: 11),
                            ),
                            icon: Icon(Icons.people_outline, size: 13),
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
                          backgroundColor: theme.surface,
                          selectedBackgroundColor: theme.accentSurface,
                          selectedForegroundColor: theme.accent,
                          foregroundColor: theme.textSecondary,
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
                            ? theme.statusError.withValues(alpha: 0.2)
                            : theme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _secondsLeft <= 5
                              ? theme.statusError
                              : theme.surfaceBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: _secondsLeft <= 5
                                ? theme.statusError
                                : theme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_secondsLeft}s',
                            style: TextStyle(
                              color: _secondsLeft <= 5
                                  ? theme.statusError
                                  : theme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Grid Preset Strip (or Online Match Info Strip)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border(
                    bottom: BorderSide(color: theme.surfaceBorder, width: 1),
                  ),
                ),
                child: _mode == ConnectFourMode.online
                    ? Row(
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            size: 13,
                            color: theme.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arena: ${_state.numCols}×${_state.numRows} • Win Streak: ${_state.targetStreak} in a row',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AUTHORITATIVE SERVERPOD',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: theme.accent,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Preset chips
                            ...GravityGridPreset.values.map((preset) {
                              final isSelected = _selectedPreset == preset;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    if (_selectedPreset != preset) {
                                      setState(() {
                                        _selectedPreset = preset;
                                        _startNewGame();
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.accentSurface
                                          : theme.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.accent
                                            : theme.surfaceBorder,
                                        width: isSelected ? 1.4 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          preset.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? theme.accent
                                                : theme.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.accent.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : theme.surface,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            preset.badge,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? theme.accent
                                                  : theme.textMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
              ),

              // Waiting For Opponent Banner
              if (_isWaitingForOpponent && _onlineMatch != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accentSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Waiting for Challenger to join...',
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Room Code: ${_getRoomCode()}',
                              style: TextStyle(
                                color: theme.accent,
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: theme.accent,
                        ),
                        tooltip: 'Copy Room Code',
                        onPressed: () {
                          final code = _getRoomCode();
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: theme.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: theme.surfaceBorder),
                              ),
                              content: Text(
                                'Copied room code $code to clipboard!',
                                style: TextStyle(color: theme.textPrimary),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Player 1 vs Player 2 Scoreboard
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Player 1 Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isP1Active
                              ? theme.player1Surface
                              : theme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isP1Active
                                ? theme.player1
                                : theme.surfaceBorder,
                            width: isP1Active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.player1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getDisplayName(true),
                                style: TextStyle(
                                  color: isP1Active
                                      ? theme.player1
                                      : theme.textSecondary,
                                  fontWeight: isP1Active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Player 2 Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: !isP1Active
                              ? theme.player2Surface
                              : theme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !isP1Active
                                ? theme.player2
                                : theme.surfaceBorder,
                            width: !isP1Active ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.player2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getDisplayName(false),
                                style: TextStyle(
                                  color: !isP1Active
                                      ? theme.player2
                                      : theme.textSecondary,
                                  fontWeight: !isP1Active
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
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
              const SizedBox(height: 6),

              // AI Thinking / Match Status Banner
              Container(
                height: 24,
                alignment: Alignment.center,
                child: _isAiThinking
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.player2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tactical Bot calculating move...',
                            style: TextStyle(
                              color: theme.player2,
                              fontSize: 11,
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
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            _state.isTerminal
                                ? (_state.isDraw
                                      ? 'TACTICAL DRAW (BOARD FULL)'
                                      : '🏆 ${_getPlayerName(_state.winnerId).toUpperCase()} CONNECTS ${_state.targetStreak} IN A ROW!')
                                : (_isWaitingForOpponent
                                      ? 'AWAITING OPPONENT TO JOIN...'
                                      : (_mode == ConnectFourMode.online
                                            ? (_state.activePlayerId ==
                                                      PlayerSession.currentId
                                                  ? 'YOUR TURN — DROP A DISC'
                                                  : 'OPPONENT\'S TURN — PLEASE WAIT')
                                            : '${_getPlayerName(_state.activePlayerId).toUpperCase()}\'S TURN')),
                            style: TextStyle(
                              color: _state.isTerminal
                                  ? theme.accent
                                  : (_isWaitingForOpponent
                                        ? theme.accent
                                        : (_mode == ConnectFourMode.online
                                              ? (_state.activePlayerId ==
                                                        PlayerSession.currentId
                                                    ? theme.player1
                                                    : theme.player2)
                                              : (isP1Active
                                                    ? theme.player1
                                                    : theme.player2))),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
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
                    vertical: 4,
                  ),
                  child: ConnectFourBoard(
                    state: _state,
                    currentUserId: _mode == ConnectFourMode.online
                        ? PlayerSession.currentId
                        : (_mode == ConnectFourMode.vsAi
                              ? _p1Id
                              : _state.activePlayerId),
                    onColumnSelected: _onColumnSelected,
                    isInteractive:
                        !_state.isTerminal &&
                        !_isWaitingForOpponent &&
                        (_mode == ConnectFourMode.online
                            ? _state.activePlayerId == PlayerSession.currentId
                            : (_mode == ConnectFourMode.vsAi
                                  ? !_isAiThinking &&
                                        _state.activePlayerId == _p1Id
                                  : true)),
                  ),
                ),
              ),

              // Footer / Game Over Summary
              if (_state.isTerminal || _isGameOver) ...[
                if (_showGameOverSummary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceElevated,
                      border: Border(
                        top: BorderSide(
                          color: _state.isDraw
                              ? theme.surfaceBorder
                              : (_state.winnerId == _p1Id
                                    ? theme.player1
                                    : theme.player2),
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
                                Builder(
                                  builder: (context) {
                                    final bool isP1Winner =
                                        _state.winnerId == _state.player1Id;
                                    final Color winnerColor = _state.isDraw
                                        ? theme.textSecondary
                                        : (isP1Winner
                                              ? theme.player1
                                              : theme.player2);
                                    final String winTitle = _state.isDraw
                                        ? 'Tactical Draw (Grid Full)'
                                        : (_state.winnerId ==
                                                  PlayerSession.currentId
                                              ? '🏆 Victory! You Won!'
                                              : (_mode == ConnectFourMode.online
                                                    ? 'Defeat — ${_getPlayerName(_state.winnerId)} Won'
                                                    : '🏆 ${_getPlayerName(_state.winnerId)} Wins!'));

                                    return Row(
                                      children: [
                                        Icon(
                                          _state.isDraw
                                              ? Icons.handshake_outlined
                                              : Icons.emoji_events,
                                          color: winnerColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          winTitle,
                                          style: TextStyle(
                                            color: winnerColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                side: BorderSide(color: theme.accent),
                                foregroundColor: theme.accent,
                              ),
                              onPressed: () =>
                                  setState(() => _showGameOverSummary = false),
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 13,
                              ),
                              label: const Text(
                                'View Full Board',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.accent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _mode == ConnectFourMode.online
                                    ? () => Navigator.pop(context)
                                    : _startNewGame,
                                icon: Icon(
                                  _mode == ConnectFourMode.online
                                      ? Icons.home_outlined
                                      : Icons.replay,
                                  size: 16,
                                ),
                                label: Text(
                                  _mode == ConnectFourMode.online
                                      ? 'Return to Hub'
                                      : 'Play Rematch',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.textSecondary,
                                  side: BorderSide(color: theme.surfaceBorder),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Exit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
