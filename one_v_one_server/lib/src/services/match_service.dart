import 'dart:convert';
import 'dart:math';
import 'package:game_core/game_core.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'player_service.dart';

class MatchService {
  static final Random _random = Random.secure();

  static String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      6,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  static String _generateMatchId() {
    return 'match_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  /// Creates a new match. If private, generates a shareable 6-character room code.
  static Future<GameMatch> createMatch(
    Session session, {
    required String playerId,
    String gameType = TriangleTacticsEngine.engineGameId,
    int boardSize = 4,
    bool isPublic = false,
  }) async {
    await PlayerService.getOrCreateProfile(session, playerId: playerId);

    final matchId = _generateMatchId();
    final roomCode = isPublic ? null : _generateRoomCode();

    String rulesetVersion;
    String stateJson;
    int p1Score = 0;
    int p2Score = 0;

    if (gameType == ConnectFourEngine.engineGameId) {
      rulesetVersion = ConnectFourEngine.engineRulesetVersion;
      final initialState = ConnectFourState.initial(
        player1Id: playerId,
        player2Id: '',
        startingPlayerId: playerId,
      );
      stateJson = jsonEncode(initialState.toJson());
    } else if (gameType == ReversiEngine.engineGameId) {
      rulesetVersion = ReversiEngine.engineRulesetVersion;
      final initialState = ReversiState.initial(
        player1Id: playerId,
        player2Id: '',
      );
      p1Score = 2;
      p2Score = 2;
      stateJson = jsonEncode(initialState.toJson());
    } else {
      gameType = TriangleTacticsEngine.engineGameId;
      rulesetVersion = TriangleTacticsEngine.engineRulesetVersion;
      final initialState = TriangleTacticsState.initial(
        player1Id: playerId,
        player2Id: '',
        boardSize: boardSize,
        boardShape: BoardShape.hexagon,
        startingPlayerId: playerId,
      );
      stateJson = jsonEncode(initialState.toJson());
    }

    final now = DateTime.now();
    final match = GameMatch(
      matchId: matchId,
      gameType: gameType,
      rulesetVersion: rulesetVersion,
      boardSize: boardSize,
      roomCode: roomCode,
      isPublic: isPublic,
      status: 'waiting',
      player1Id: playerId,
      player2Id: null,
      activePlayerId: playerId,
      player1Score: p1Score,
      player2Score: p2Score,
      stateVersion: 0,
      winnerId: null,
      isDraw: false,
      stateJson: stateJson,
      createdAt: now,
      updatedAt: now,
      completedAt: null,
    );

    return await GameMatch.db.insertRow(session, match);
  }

  /// Joins a private match by room code.
  static Future<GameMatch> joinMatch(
    Session session, {
    required String playerId,
    required String roomCode,
  }) async {
    await PlayerService.getOrCreateProfile(session, playerId: playerId);

    MatchEvent? startEvent;
    late GameMatch updatedMatch;

    await session.db.transaction((tx) async {
      final match = await GameMatch.db.findFirstRow(
        session,
        where: (t) => t.roomCode.equals(roomCode),
        transaction: tx,
      );

      if (match == null) {
        throw ArgumentError('No room found with code "$roomCode".');
      }

      if (match.player1Id == playerId) {
        throw ArgumentError(
          'You cannot play against yourself in the same match.',
        );
      }

      if (match.player2Id != null || match.status == 'in_progress') {
        throw ArgumentError(
          'This room is already full! Two players have already joined this match.',
        );
      }

      if (match.status == 'completed' || match.status == 'abandoned') {
        throw ArgumentError(
          'This match has already ended (status: ${match.status}).',
        );
      }

      if (match.status != 'waiting') {
        throw ArgumentError(
          'This room is not currently accepting players (status: ${match.status}).',
        );
      }

      if (match.gameType == ConnectFourEngine.engineGameId) {
        final existingState = ConnectFourState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final readyState = existingState.copyWith(player2Id: playerId);
        match.stateJson = jsonEncode(readyState.toJson());
      } else if (match.gameType == ReversiEngine.engineGameId) {
        final existingState = ReversiState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final readyState = existingState.copyWith(player2Id: playerId);
        match.stateJson = jsonEncode(readyState.toJson());
      } else {
        final existingState = TriangleTacticsState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final readyState = existingState.copyWith(player2Id: playerId);
        match.stateJson = jsonEncode(readyState.toJson());
      }

      match.player2Id = playerId;
      match.status = 'in_progress';
      match.updatedAt = DateTime.now();

      updatedMatch = await GameMatch.db.updateRow(
        session,
        match,
        transaction: tx,
      );

      startEvent = MatchEvent(
        matchId: match.matchId,
        eventType: 'matchStarted',
        stateVersion: match.stateVersion,
        activePlayerId: match.activePlayerId,
        player1Score: match.player1Score,
        player2Score: match.player2Score,
        isTerminal: false,
        isDraw: false,
        stateJson: match.stateJson,
        timestamp: DateTime.now(),
      );
    });

    if (startEvent != null) {
      await session.messages.postMessage(
        'match_${updatedMatch.matchId}',
        startEvent!,
      );
    }

    return updatedMatch;
  }

  /// Public Matchmaking: finds an available open public match or creates a new one.
  static Future<GameMatch> findMatch(
    Session session, {
    required String playerId,
    String gameType = TriangleTacticsEngine.engineGameId,
    int boardSize = 4,
  }) async {
    await PlayerService.getOrCreateProfile(session, playerId: playerId);

    MatchEvent? startEvent;
    GameMatch? matched;

    await session.db.transaction((tx) async {
      // Find open public match with same gameType and board size where player1 != current player
      final candidate = await GameMatch.db.findFirstRow(
        session,
        where: (t) =>
            t.isPublic.equals(true) &
            t.status.equals('waiting') &
            t.gameType.equals(gameType) &
            t.boardSize.equals(boardSize) &
            t.player1Id.notEquals(playerId),
        transaction: tx,
      );

      if (candidate != null) {
        if (candidate.gameType == ConnectFourEngine.engineGameId) {
          final existingState = ConnectFourState.fromJson(
            jsonDecode(candidate.stateJson) as Map<String, dynamic>,
          );
          final readyState = existingState.copyWith(player2Id: playerId);
          candidate.stateJson = jsonEncode(readyState.toJson());
        } else if (candidate.gameType == ReversiEngine.engineGameId) {
          final existingState = ReversiState.fromJson(
            jsonDecode(candidate.stateJson) as Map<String, dynamic>,
          );
          final readyState = existingState.copyWith(player2Id: playerId);
          candidate.stateJson = jsonEncode(readyState.toJson());
        } else {
          final existingState = TriangleTacticsState.fromJson(
            jsonDecode(candidate.stateJson) as Map<String, dynamic>,
          );
          final readyState = existingState.copyWith(player2Id: playerId);
          candidate.stateJson = jsonEncode(readyState.toJson());
        }

        candidate.player2Id = playerId;
        candidate.status = 'in_progress';
        candidate.updatedAt = DateTime.now();

        matched = await GameMatch.db.updateRow(
          session,
          candidate,
          transaction: tx,
        );

        startEvent = MatchEvent(
          matchId: matched!.matchId,
          eventType: 'matchStarted',
          stateVersion: matched!.stateVersion,
          activePlayerId: matched!.activePlayerId,
          player1Score: matched!.player1Score,
          player2Score: matched!.player2Score,
          isTerminal: false,
          isDraw: false,
          stateJson: matched!.stateJson,
          timestamp: DateTime.now(),
        );
      }
    });

    if (matched != null) {
      if (startEvent != null) {
        await session.messages.postMessage(
          'match_${matched!.matchId}',
          startEvent!,
        );
      }
      return matched!;
    }

    // No existing waiting match found -> Create new public match
    return await createMatch(
      session,
      playerId: playerId,
      gameType: gameType,
      boardSize: boardSize,
      isPublic: true,
    );
  }

  /// Submits a move transactionally with row-level integrity and authoritative validation.
  static Future<GameMatch> submitMove(
    Session session, {
    required String matchId,
    required String playerId,
    required int node1R,
    required int node1C,
    required int node2R,
    required int node2C,
    required int clientStateVersion,
  }) async {
    MatchEvent? broadcastEvent;
    late GameMatch updatedMatch;

    await session.db.transaction((tx) async {
      final match = await GameMatch.db.findFirstRow(
        session,
        where: (t) => t.matchId.equals(matchId),
        transaction: tx,
      );

      if (match == null) {
        throw ArgumentError('Match "$matchId" not found.');
      }

      if (match.status != 'in_progress') {
        throw StateError(
          'Match is not active (current status: ${match.status}).',
        );
      }

      if (match.activePlayerId != playerId) {
        throw StateError('It is not player $playerId\'s turn.');
      }

      // Optimistic concurrency control
      if (match.stateVersion != clientStateVersion) {
        throw StateError(
          'State version mismatch: client is at $clientStateVersion, server is at ${match.stateVersion}.',
        );
      }

      int nextStateVersion;
      int p1Score;
      int p2Score;
      String nextPlayerId;
      bool isTerminal;
      String? winnerId;
      bool isDraw;
      String nextStateJson;
      String? edgeId;
      List<String>? claimedTriangles;
      bool extraTurnAwarded = false;

      if (match.gameType == ConnectFourEngine.engineGameId) {
        final state = ConnectFourState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final engine = ConnectFourEngine();
        final move = ConnectFourMove(column: node1C);
        final result = engine.applyMove(state, playerId, move);
        if (result is MoveRejected) {
          throw ArgumentError(result.violation.message);
        }
        final accepted = result as MoveAccepted;
        final nextState = accepted.nextState as ConnectFourState;
        nextStateVersion = nextState.stateVersion;
        p1Score = (accepted.winnerId == match.player1Id) ? 1 : 0;
        p2Score = (accepted.winnerId == match.player2Id) ? 1 : 0;
        nextPlayerId = accepted.nextPlayerId;
        isTerminal = accepted.isTerminal;
        winnerId = accepted.winnerId;
        isDraw = accepted.isDraw;
        nextStateJson = jsonEncode(nextState.toJson());
        edgeId = 'col_$node1C';
      } else if (match.gameType == ReversiEngine.engineGameId) {
        final state = ReversiState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final engine = ReversiEngine();
        final move = (node1R < 0 || node1C < 0)
            ? const ReversiMove.pass()
            : ReversiMove(row: node1R, col: node1C);
        final result = engine.applyMove(state, playerId, move);
        if (result is MoveRejected) {
          throw ArgumentError(result.violation.message);
        }
        final accepted = result as MoveAccepted;
        final nextState = accepted.nextState as ReversiState;
        nextStateVersion = nextState.stateVersion;
        p1Score = nextState.player1Score;
        p2Score = nextState.player2Score;
        nextPlayerId = accepted.nextPlayerId;
        isTerminal = accepted.isTerminal;
        winnerId = accepted.winnerId;
        isDraw = accepted.isDraw;
        nextStateJson = jsonEncode(nextState.toJson());
        edgeId = (node1R < 0 || node1C < 0)
            ? 'pass'
            : 'reversi_${node1R}_$node1C';
      } else {
        final state = TriangleTacticsState.fromJson(
          jsonDecode(match.stateJson) as Map<String, dynamic>,
        );
        final engine = TriangleTacticsEngine();
        final move = TriangleTacticsMove(
          node1: GridNode(node1R, node1C),
          node2: GridNode(node2R, node2C),
        );
        final result = engine.applyMove(state, playerId, move);
        if (result is MoveRejected) {
          throw ArgumentError(result.violation.message);
        }
        final accepted = result as MoveAccepted;
        final nextState = accepted.nextState;
        nextStateVersion = nextState.stateVersion;
        p1Score = nextState.player1Score;
        p2Score = nextState.player2Score;
        nextPlayerId = accepted.nextPlayerId;
        isTerminal = accepted.isTerminal;
        winnerId = accepted.winnerId;
        isDraw = accepted.isDraw;
        nextStateJson = jsonEncode(nextState.toJson());
        edgeId = accepted.edgeId;
        claimedTriangles = accepted.newlyClaimedTriangles;
        extraTurnAwarded = accepted.extraTurnAwarded;
      }

      final now = DateTime.now();

      // Update game_match row
      match.stateVersion = nextStateVersion;
      match.player1Score = p1Score;
      match.player2Score = p2Score;
      match.activePlayerId = nextPlayerId;
      match.status = isTerminal ? 'completed' : 'in_progress';
      match.winnerId = winnerId;
      match.isDraw = isDraw;
      match.stateJson = nextStateJson;
      match.updatedAt = now;
      if (isTerminal) {
        match.completedAt = now;
      }

      updatedMatch = await GameMatch.db.updateRow(
        session,
        match,
        transaction: tx,
      );

      // Insert audit record
      final moveRecord = MatchMoveRecord(
        matchId: matchId,
        moveIndex: match.stateVersion,
        playerId: playerId,
        node1R: node1R,
        node1C: node1C,
        node2R: node2R,
        node2C: node2C,
        edgeId: edgeId,
        claimedTrianglesJson: jsonEncode(claimedTriangles ?? []),
        extraTurn: extraTurnAwarded,
        stateVersion: nextStateVersion,
        createdAt: now,
      );
      await MatchMoveRecord.db.insertRow(session, moveRecord, transaction: tx);

      // If match finished, update player statistics
      if (isTerminal) {
        final p1Won = winnerId == match.player1Id;
        final p2Won = winnerId == match.player2Id;

        await PlayerService.recordMatchResult(
          session,
          playerId: match.player1Id,
          isWin: p1Won,
          isLoss: p2Won,
          isDraw: isDraw,
          trianglesCaptured: p1Score,
          transaction: tx,
        );

        if (match.player2Id != null) {
          await PlayerService.recordMatchResult(
            session,
            playerId: match.player2Id!,
            isWin: p2Won,
            isLoss: p1Won,
            isDraw: isDraw,
            trianglesCaptured: p2Score,
            transaction: tx,
          );
        }
      }

      broadcastEvent = MatchEvent(
        matchId: matchId,
        eventType: isTerminal ? 'matchCompleted' : 'moveAccepted',
        stateVersion: nextStateVersion,
        activePlayerId: nextPlayerId,
        edgeId: edgeId,
        claimedTriangles: claimedTriangles,
        extraTurn: extraTurnAwarded,
        player1Score: p1Score,
        player2Score: p2Score,
        isTerminal: isTerminal,
        winnerId: winnerId,
        isDraw: isDraw,
        stateJson: match.stateJson,
        timestamp: now,
      );
    });

    // Deliver committed state change over stream
    if (broadcastEvent != null) {
      await session.messages.postMessage('match_$matchId', broadcastEvent!);
    }

    return updatedMatch;
  }

  /// Resigns an active match. Opponent is declared winner.
  static Future<GameMatch> resign(
    Session session, {
    required String matchId,
    required String playerId,
  }) async {
    MatchEvent? broadcastEvent;
    late GameMatch updatedMatch;

    await session.db.transaction((tx) async {
      final match = await GameMatch.db.findFirstRow(
        session,
        where: (t) => t.matchId.equals(matchId),
        transaction: tx,
      );

      if (match == null) {
        throw ArgumentError('Match "$matchId" not found.');
      }

      if (match.status == 'completed') {
        updatedMatch = match;
        return;
      }

      if (match.status != 'in_progress') {
        throw StateError(
          'Active match not found for resignation (current status: ${match.status}).',
        );
      }

      if (match.player1Id != playerId && match.player2Id != playerId) {
        throw ArgumentError(
          'Player $playerId is not a participant in this match.',
        );
      }

      final winnerId = match.player1Id == playerId
          ? match.player2Id
          : match.player1Id;
      final now = DateTime.now();

      // Ensure inner engine state is also terminal
      try {
        if (match.gameType == ConnectFourEngine.engineGameId) {
          final s = ConnectFourState.fromJson(
            jsonDecode(match.stateJson) as Map<String, dynamic>,
          );
          match.stateJson = jsonEncode(
            s.copyWith(isTerminal: true, winnerId: winnerId).toJson(),
          );
        } else if (match.gameType == ReversiEngine.engineGameId) {
          final s = ReversiState.fromJson(
            jsonDecode(match.stateJson) as Map<String, dynamic>,
          );
          match.stateJson = jsonEncode(
            s.copyWith(isTerminal: true, winnerId: winnerId).toJson(),
          );
        } else {
          final existingState = TriangleTacticsState.fromJson(
            jsonDecode(match.stateJson) as Map<String, dynamic>,
          );
          final terminalState = existingState.copyWith(
            isTerminal: true,
            winnerId: winnerId,
          );
          match.stateJson = jsonEncode(terminalState.toJson());
        }
      } catch (_) {}

      match.status = 'completed';
      match.winnerId = winnerId;
      match.isDraw = false;
      match.completedAt = now;
      match.updatedAt = now;

      updatedMatch = await GameMatch.db.updateRow(
        session,
        match,
        transaction: tx,
      );

      final p1Won = winnerId == match.player1Id;
      final p2Won = winnerId == match.player2Id;

      await PlayerService.recordMatchResult(
        session,
        playerId: match.player1Id,
        isWin: p1Won,
        isLoss: p2Won,
        isDraw: false,
        trianglesCaptured: match.player1Score,
        transaction: tx,
      );

      if (match.player2Id != null) {
        await PlayerService.recordMatchResult(
          session,
          playerId: match.player2Id!,
          isWin: p2Won,
          isLoss: p1Won,
          isDraw: false,
          trianglesCaptured: match.player2Score,
          transaction: tx,
        );
      }

      broadcastEvent = MatchEvent(
        matchId: matchId,
        eventType: 'matchCompleted',
        stateVersion: match.stateVersion,
        activePlayerId: match.activePlayerId,
        player1Score: match.player1Score,
        player2Score: match.player2Score,
        isTerminal: true,
        winnerId: winnerId,
        isDraw: false,
        stateJson: match.stateJson,
        timestamp: now,
      );
    });

    if (broadcastEvent != null) {
      await session.messages.postMessage('match_$matchId', broadcastEvent!);
    }

    return updatedMatch;
  }
}
