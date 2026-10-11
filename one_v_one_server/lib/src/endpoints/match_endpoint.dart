import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/match_service.dart';

class MatchEndpoint extends Endpoint {
  /// Create a new match (private or public).
  Future<GameMatch> createMatch(
    Session session, {
    required String playerId,
    int boardSize = 4,
    bool isPublic = false,
  }) async {
    return await MatchService.createMatch(
      session,
      playerId: playerId,
      boardSize: boardSize,
      isPublic: isPublic,
    );
  }

  /// Join a private room with a 6-character room code.
  Future<GameMatch> joinMatch(
    Session session, {
    required String playerId,
    required String roomCode,
  }) async {
    return await MatchService.joinMatch(
      session,
      playerId: playerId,
      roomCode: roomCode.trim().toUpperCase(),
    );
  }

  /// Matchmake with an available player.
  Future<GameMatch> findMatch(
    Session session, {
    required String playerId,
    int boardSize = 4,
  }) async {
    return await MatchService.findMatch(
      session,
      playerId: playerId,
      boardSize: boardSize,
    );
  }

  /// Fetch authoritative match snapshot.
  Future<GameMatch?> getMatch(Session session, String matchId) async {
    return await GameMatch.db.findFirstRow(
      session,
      where: (t) => t.matchId.equals(matchId),
    );
  }

  /// Submit an edge connection move.
  Future<GameMatch> submitMove(
    Session session, {
    required String matchId,
    required String playerId,
    required int node1R,
    required int node1C,
    required int node2R,
    required int node2C,
    required int clientStateVersion,
  }) async {
    return await MatchService.submitMove(
      session,
      matchId: matchId,
      playerId: playerId,
      node1R: node1R,
      node1C: node1C,
      node2R: node2R,
      node2C: node2C,
      clientStateVersion: clientStateVersion,
    );
  }

  /// Resign from an active match.
  Future<GameMatch> resign(
    Session session, {
    required String matchId,
    required String playerId,
  }) async {
    return await MatchService.resign(
      session,
      matchId: matchId,
      playerId: playerId,
    );
  }

  /// Retrieve match history for a player or platform.
  Future<List<GameMatch>> getMatchHistory(
    Session session, {
    String? playerId,
    int limit = 20,
  }) async {
    if (playerId != null) {
      return await GameMatch.db.find(
        session,
        where: (t) =>
            t.status.equals('completed') &
            (t.player1Id.equals(playerId) | t.player2Id.equals(playerId)),
        orderByList: (t) => [t.completedAt.desc()],
        limit: limit,
      );
    }
    return await GameMatch.db.find(
      session,
      where: (t) => t.status.equals('completed'),
      orderByList: (t) => [t.completedAt.desc()],
      limit: limit,
    );
  }

  /// Retrieve all moves for a match for auditable replay.
  Future<List<MatchMoveRecord>> getMoves(
    Session session,
    String matchId,
  ) async {
    return await MatchMoveRecord.db.find(
      session,
      where: (t) => t.matchId.equals(matchId),
      orderByList: (t) => [t.moveIndex.asc()],
    );
  }

  /// Real-time stream of authoritative match events.
  Stream<MatchEvent> streamMatchEvents(Session session, String matchId) {
    return session.messages.createStream<MatchEvent>('match_$matchId');
  }
}
