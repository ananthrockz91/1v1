import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_core/game_core.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../models/player_session.dart';

class MatchUiState {
  final GameMatch? match;
  final TriangleTacticsState? gameState;
  final bool isLoading;
  final String? errorMessage;
  final bool isConnected;
  final bool showExtraTurnNotice;

  const MatchUiState({
    this.match,
    this.gameState,
    this.isLoading = false,
    this.errorMessage,
    this.isConnected = true,
    this.showExtraTurnNotice = false,
  });

  MatchUiState copyWith({
    GameMatch? match,
    TriangleTacticsState? gameState,
    bool? isLoading,
    String? errorMessage,
    bool? isConnected,
    bool? showExtraTurnNotice,
  }) {
    return MatchUiState(
      match: match ?? this.match,
      gameState: gameState ?? this.gameState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isConnected: isConnected ?? this.isConnected,
      showExtraTurnNotice: showExtraTurnNotice ?? this.showExtraTurnNotice,
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

              state = state.copyWith(
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
    final currentMatch = state.match;
    final currentGameState = state.gameState;
    if (currentMatch == null || currentGameState == null) return;

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
