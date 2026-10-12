import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final PlayerProfile? player1Profile;
  final PlayerProfile? player2Profile;

  const MatchUiState({
    this.match,
    this.gameState,
    this.isLoading = false,
    this.errorMessage,
    this.isConnected = true,
    this.showExtraTurnNotice = false,
    this.isLocal = false,
    this.isAiMatch = false,
    this.player1Profile,
    this.player2Profile,
  });

  String get player1Name {
    if (player1Profile != null && player1Profile!.displayName.isNotEmpty) {
      return player1Profile!.displayName;
    }
    if (match?.player1Id == PlayerSession.currentId) {
      return PlayerSession.displayName;
    }
    return 'Player 1';
  }

  String get player1Avatar {
    if (match?.player1Id == PlayerSession.currentId &&
        PlayerSession.hasCustomAvatar) {
      return PlayerSession.avatarSeed;
    }
    if (player1Profile != null && player1Profile!.avatarSeed.isNotEmpty) {
      return player1Profile!.avatarSeed;
    }
    if (match?.player1Id == PlayerSession.currentId) {
      return PlayerSession.avatarSeed;
    }
    return 'avatar_1';
  }

  String get player2Name {
    if (isAiMatch) return 'Tactical Bot (AI)';
    if (isLocal) return 'Player 2';
    if (match?.player2Id == PlayerSession.currentId) {
      return PlayerSession.displayName;
    }
    if (player2Profile != null && player2Profile!.displayName.isNotEmpty) {
      return player2Profile!.displayName;
    }
    return match?.player2Id != null ? 'Player 2' : 'Waiting...';
  }

  String get player2Avatar {
    if (isAiMatch) return 'avatar_5';
    if (isLocal) return 'avatar_2';
    if (match?.player2Id == PlayerSession.currentId &&
        PlayerSession.hasCustomAvatar) {
      return PlayerSession.avatarSeed;
    }
    if (player2Profile != null && player2Profile!.avatarSeed.isNotEmpty) {
      return player2Profile!.avatarSeed;
    }
    if (match?.player2Id == PlayerSession.currentId) {
      return PlayerSession.avatarSeed;
    }
    return 'avatar_2';
  }

  MatchUiState copyWith({
    GameMatch? match,
    TriangleTacticsState? gameState,
    bool? isLoading,
    String? errorMessage,
    bool? isConnected,
    bool? showExtraTurnNotice,
    bool? isLocal,
    bool? isAiMatch,
    PlayerProfile? player1Profile,
    PlayerProfile? player2Profile,
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
      player1Profile: player1Profile ?? this.player1Profile,
      player2Profile: player2Profile ?? this.player2Profile,
    );
  }
}

class MatchNotifier extends StateNotifier<MatchUiState> {
  StreamSubscription<MatchEvent>? _streamSub;
  String? _currentSubscribedMatchId;

  MatchNotifier() : super(const MatchUiState());

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void startLocalMatch({int boardSize = 4}) {
    _streamSub?.cancel();
    _currentSubscribedMatchId = null;
    final initialState = TriangleTacticsState.hexagonal(
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
    _currentSubscribedMatchId = null;
    final initialState = TriangleTacticsState.hexagonal(
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

    _fetchProfiles(match.player1Id, match.player2Id, force: true);
    _listenToMatchStream(match.matchId);
  }

  Future<void> _fetchProfiles(
    String p1Id,
    String? p2Id, {
    bool force = false,
  }) async {
    try {
      PlayerProfile? p1 = state.player1Profile;
      PlayerProfile? p2 = state.player2Profile;
      if (p1Id.isNotEmpty &&
          (force ||
              p1 == null ||
              p1.playerId != p1Id ||
              p1.avatarSeed == 'avatar_1')) {
        p1 = await client.player.getProfile(p1Id);
      }
      if (p2Id != null &&
          p2Id.isNotEmpty &&
          (force ||
              p2 == null ||
              p2.playerId != p2Id ||
              p2.avatarSeed == 'avatar_1')) {
        p2 = await client.player.getProfile(p2Id);
      }
      if (mounted) {
        state = state.copyWith(player1Profile: p1, player2Profile: p2);
      }
    } catch (_) {}
  }

  void _listenToMatchStream(String matchId) {
    if (_streamSub != null && _currentSubscribedMatchId == matchId) {
      return;
    }
    _streamSub?.cancel();
    _currentSubscribedMatchId = matchId;
    try {
      final stream = client.match.streamMatchEvents(matchId);
      _streamSub = stream.listen(
        (event) {
          if (event.stateJson != null) {
            try {
              final json = jsonDecode(event.stateJson!) as Map<String, dynamic>;
              final nextGameState = TriangleTacticsState.fromJson(json);

              var updatedMatch = state.match;
              final isMatchStarted = event.eventType == 'matchStarted';
              if (updatedMatch != null) {
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
                showExtraTurnNotice: false,
              );
              if (updatedMatch != null &&
                  updatedMatch.player2Id != null &&
                  updatedMatch.player2Id!.isNotEmpty) {
                _fetchProfiles(
                  updatedMatch.player1Id,
                  updatedMatch.player2Id,
                  force: isMatchStarted,
                );
              }
            } catch (_) {}
          }
        },
        onError: (err) {
          _currentSubscribedMatchId = null;
          state = state.copyWith(isConnected: false);
        },
      );
    } catch (_) {
      _currentSubscribedMatchId = null;
    }
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
      final msg = e
          .toString()
          .replaceAll('ServerpodClientInternalServerError: ', '')
          .replaceAll('ServerpodClientException: ', '')
          .replaceAll('Exception: ', '')
          .trim();
      state = state.copyWith(isLoading: false, errorMessage: msg);
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
      var msg = e
          .toString()
          .replaceAll('ServerpodClientInternalServerError: ', '')
          .replaceAll('ServerpodClientException: ', '')
          .replaceAll('Exception: ', '')
          .replaceAll('ArgumentError: ', '')
          .replaceAll('Invalid argument(s): ', '')
          .trim();
      if (msg.contains('You cannot play against yourself')) {
        msg =
            'You cannot join a room created by yourself. To test 2 players on this computer, open the room code in an Incognito / Private window or another browser.';
      } else if (msg.contains('already full') ||
          msg.contains('Two players have already joined')) {
        msg =
            'This room is already full! Two players have already joined this match.';
      } else if (msg.contains('No room found')) {
        msg = 'No room found with code "$roomCode". Please verify the code.';
      } else if (msg.contains('already ended')) {
        msg = 'This match has already concluded and is no longer joinable.';
      } else if (msg.contains('500') || msg.contains('Internal server error')) {
        msg =
            'Unable to join room "$roomCode". The room may be full, concluded, or invalid.';
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
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
      final msg = e
          .toString()
          .replaceAll('ServerpodClientInternalServerError: ', '')
          .replaceAll('ServerpodClientException: ', '')
          .replaceAll('Exception: ', '')
          .trim();
      state = state.copyWith(isLoading: false, errorMessage: msg);
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
            showExtraTurnNotice: false,
          );

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

    // Optimistic local update using pure rules engine
    final previousGameState = currentGameState;
    try {
      final engine = TriangleTacticsEngine();
      final localResult = engine.applyMove(
        currentGameState,
        PlayerSession.currentId,
        TriangleTacticsMove(node1: node1, node2: node2),
      );
      if (localResult is MoveAccepted) {
        state = state.copyWith(
          gameState: localResult.nextState,
          showExtraTurnNotice: false,
        );
      }
    } catch (_) {}

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
      // Revert optimistic state on failure
      state = state.copyWith(
        gameState: previousGameState,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> resign({String? timedOutPlayerId}) async {
    if (state.isLocal) {
      final currentGameState = state.gameState;
      if (currentGameState == null) return;
      final resigningPlayer =
          timedOutPlayerId ?? currentGameState.activePlayerId;
      final winner = resigningPlayer == 'Player 1'
          ? (state.isAiMatch ? 'Tactical Bot (AI)' : 'Player 2')
          : 'Player 1';
      final terminalState = currentGameState.copyWith(
        isTerminal: true,
        winnerId: winner,
      );
      state = state.copyWith(gameState: terminalState);
      return;
    }

    final currentMatch = state.match;
    if (currentMatch == null || currentMatch.status != 'in_progress') return;

    try {
      final updatedMatch = await client.match.resign(
        matchId: currentMatch.matchId,
        playerId: timedOutPlayerId ?? PlayerSession.currentId,
      );
      _onMatchUpdated(updatedMatch);
    } catch (e) {
      // Log resignation error without showing alarming toast to user
      // (usually caused by opponent resigning simultaneously or match already completed)
      debugPrint('Resignation notice: $e');
    }
  }

  void clearMatch() {
    _streamSub?.cancel();
    _currentSubscribedMatchId = null;
    state = const MatchUiState();
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, MatchUiState>((ref) {
  return MatchNotifier();
});
