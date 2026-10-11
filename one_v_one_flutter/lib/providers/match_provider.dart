import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../models/player_session.dart';
import '../services/tactical_bot.dart';

class MatchUiState {
  final GameMatch? match;
  final TriangleTacticsState? gameState;
  final bool isLoading;
  final String? errorMessage;
  final bool isConnected;
  final bool showExtraTurnNotice;
  final bool isLocal;
  final bool isAiMatch;

  const MatchUiState({
    this.match,
    this.gameState,
    this.isLoading = false,
    this.errorMessage,
    this.isConnected = true,
    this.showExtraTurnNotice = false,
    this.isLocal = false,
    this.isAiMatch = false,
  });

  MatchUiState copyWith({
    GameMatch? match,
    TriangleTacticsState? gameState,
    bool? isLoading,
    String? errorMessage,
    bool? isConnected,
    bool? showExtraTurnNotice,
    bool? isLocal,
    bool? isAiMatch,
  }) {
    return MatchUiState(
      match: match ?? this.match,
      gameState: gameState ?? this.gameState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isConnected: isConnected ?? this.isConnected,
      showExtraTurnNotice: showExtraTurnNotice ?? this.showExtraTurnNotice,
      isLocal: isLocal ?? this.isLocal,
      isAiMatch: isAiMatch ?? this.isAiMatch,
    );
  }
}

class MatchNotifier extends StateNotifier<MatchUiState> {
  StreamSubscription<MatchEvent>? _streamSub;

  MatchNotifier() : super(const MatchUiState());

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void startLocalMatch({int boardSize = 4}) {
    _streamSub?.cancel();
    final initialState = TriangleTacticsState.initial(
      boardSize: boardSize,
      player1Id: 'Player 1',
      player2Id: 'Player 2',
    );
    state = MatchUiState(
      gameState: initialState,
      isLocal: true,
      isAiMatch: false,
      isLoading: false,
      isConnected: true,
    );
  }

  void startAiMatch({int boardSize = 4}) {
    _streamSub?.cancel();
    final initialState = TriangleTacticsState.initial(
      boardSize: boardSize,
      player1Id: 'Player 1',
      player2Id: 'Tactical Bot (AI)',
    );
    state = MatchUiState(
      gameState: initialState,
      isLocal: true,
      isAiMatch: true,
      isLoading: false,
      isConnected: true,
    );
  }

  void _onMatchUpdated(GameMatch match) {
    TriangleTacticsState? gState;
    try {
      final json = jsonDecode(match.stateJson) as Map<String, dynamic>;
      gState = TriangleTacticsState.fromJson(json);
    } catch (_) {}

    state = state.copyWith(
      match: match,
      gameState: gState,
      isLoading: false,
      errorMessage: null,
      isLocal: false,
    );

    _listenToMatchStream(match.matchId);
  }

  void _listenToMatchStream(String matchId) {
    _streamSub?.cancel();
    try {
      final stream = client.match.streamMatchEvents(matchId);
      _streamSub = stream.listen(
        (event) {
          if (event.stateJson != null) {
            try {
              final json = jsonDecode(event.stateJson!) as Map<String, dynamic>;
              final nextGameState = TriangleTacticsState.fromJson(json);

              var updatedMatch = state.match;
              if (updatedMatch != null) {
                final isMatchStarted = event.eventType == 'matchStarted';
                final isCompleted = event.isTerminal;
                final newStatus = isCompleted
                    ? 'completed'
                    : (isMatchStarted ? 'in_progress' : updatedMatch.status);

                updatedMatch = updatedMatch.copyWith(
                  status: newStatus,
                  player2Id: nextGameState.player2Id,
                  activePlayerId: event.activePlayerId,
                  stateVersion: event.stateVersion,
                  player1Score: event.player1Score,
                  player2Score: event.player2Score,
                  stateJson: event.stateJson!,
                );
              }

              state = state.copyWith(
                match: updatedMatch,
                gameState: nextGameState,
                showExtraTurnNotice: event.extraTurn == true,
              );

              if (event.extraTurn == true) {
                Future.delayed(const Duration(milliseconds: 1800), () {
                  if (mounted) {
                    state = state.copyWith(showExtraTurnNotice: false);
                  }
                });
              }
            } catch (_) {}
          }
        },
        onError: (err) {
          state = state.copyWith(isConnected: false);
        },
      );
    } catch (_) {}
  }

  Future<void> createPrivateMatch({int boardSize = 4}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final match = await client.match.createMatch(
        playerId: PlayerSession.currentId,
        boardSize: boardSize,
        isPublic: false,
      );
      _onMatchUpdated(match);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> joinPrivateMatch(String roomCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final match = await client.match.joinMatch(
        playerId: PlayerSession.currentId,
        roomCode: roomCode,
      );
      _onMatchUpdated(match);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> playOnline({int boardSize = 4}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final match = await client.match.findMatch(
        playerId: PlayerSession.currentId,
        boardSize: boardSize,
      );
      _onMatchUpdated(match);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> submitMove(GridNode node1, GridNode node2) async {
    final currentGameState = state.gameState;
    if (currentGameState == null) return;

    if (state.isLocal) {
      try {
        final engine = TriangleTacticsEngine();
        final result = engine.applyMove(
          currentGameState,
          currentGameState.activePlayerId,
          TriangleTacticsMove(node1: node1, node2: node2),
        );
        if (result is MoveAccepted) {
          state = state.copyWith(
            gameState: result.nextState,
            showExtraTurnNotice: result.extraTurnAwarded,
          );
          if (result.extraTurnAwarded) {
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) {
                state = state.copyWith(showExtraTurnNotice: false);
              }
            });
          }

          if (state.isAiMatch &&
              result.nextState.activePlayerId == 'Tactical Bot (AI)' &&
              !result.nextState.isTerminal) {
            Future.delayed(const Duration(milliseconds: 650), () {
              if (mounted &&
                  state.isAiMatch &&
                  state.gameState?.activePlayerId == 'Tactical Bot (AI)' &&
                  !(state.gameState?.isTerminal ?? true)) {
                final aiMove = TacticalBot.selectBestMove(
                  state: state.gameState!,
                  botPlayerId: 'Tactical Bot (AI)',
                );
                if (aiMove != null) {
                  submitMove(aiMove.node1, aiMove.node2);
                }
              }
            });
          }
        } else if (result is MoveRejected) {
          state = state.copyWith(errorMessage: result.violation.message);
        }
      } catch (e) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return;
    }

    final currentMatch = state.match;
    if (currentMatch == null) return;

    if (currentMatch.status != 'in_progress') {
      state = state.copyWith(
        errorMessage: 'Match is waiting for opponent to join.',
      );
      return;
    }

    try {
      final updatedMatch = await client.match.submitMove(
        matchId: currentMatch.matchId,
        playerId: PlayerSession.currentId,
        node1R: node1.r,
        node1C: node1.c,
        node2R: node2.r,
        node2C: node2.c,
        clientStateVersion: currentGameState.stateVersion,
      );
      _onMatchUpdated(updatedMatch);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> resign() async {
    final currentMatch = state.match;
    if (currentMatch == null) return;

    try {
      final updatedMatch = await client.match.resign(
        matchId: currentMatch.matchId,
        playerId: PlayerSession.currentId,
      );
      _onMatchUpdated(updatedMatch);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void clearMatch() {
    _streamSub?.cancel();
    state = const MatchUiState();
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, MatchUiState>((ref) {
  return MatchNotifier();
});
