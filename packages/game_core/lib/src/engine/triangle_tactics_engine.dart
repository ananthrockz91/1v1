import '../board/board_geometry.dart';
import 'game_engine_interface.dart';
import 'move_result.dart';
import 'rule_violation.dart';
import 'state_validator.dart';
import 'triangle_tactics_move.dart';
import 'triangle_tactics_state.dart';

/// Pure, deterministic rules engine for Triangle Tactics.
class TriangleTacticsEngine
    implements GameEngine<TriangleTacticsState, TriangleTacticsMove> {
  static const String engineGameId = 'triangle_tactics';
  static const String engineRulesetVersion = '1.0.0';

  @override
  String get gameId => engineGameId;

  @override
  String get rulesetVersion => engineRulesetVersion;

  final Map<int, BoardGeometry> _geometryCache = {};

  BoardGeometry getGeometry(int size) {
    return _geometryCache.putIfAbsent(size, () => BoardGeometry(size));
  }

  @override
  RuleViolation? validateMove(
    TriangleTacticsState state,
    String playerId,
    TriangleTacticsMove move,
  ) {
    if (state.isTerminal) {
      return const RuleViolation(
        type: RuleViolationType.matchAlreadyTerminal,
        message:
            'The match has already concluded. No further moves are allowed.',
      );
    }

    if (!state.isParticipant(playerId)) {
      return RuleViolation(
        type: RuleViolationType.unknownPlayer,
        message:
            'Player $playerId is not a registered participant in this match.',
        details: {'player1Id': state.player1Id, 'player2Id': state.player2Id},
      );
    }

    if (state.activePlayerId != playerId) {
      return RuleViolation(
        type: RuleViolationType.notYourTurn,
        message:
            'It is not player $playerId\'s turn. Active player: ${state.activePlayerId}.',
        details: {'activePlayerId': state.activePlayerId},
      );
    }

    final geometry = getGeometry(state.boardSize);

    if (!geometry.containsNode(move.node1) ||
        !geometry.containsNode(move.node2)) {
      return RuleViolation(
        type: RuleViolationType.nodeOutOfBounds,
        message: 'One or both nodes are outside the board boundaries.',
        details: {'node1': move.node1.toJson(), 'node2': move.node2.toJson()},
      );
    }

    if (move.node1 == move.node2) {
      return const RuleViolation(
        type: RuleViolationType.selfLoop,
        message: 'Cannot place an edge connecting a node to itself.',
      );
    }

    final edge = move.edge;

    if (!edge.isAdjacent) {
      return RuleViolation(
        type: RuleViolationType.nonAdjacentNodes,
        message: 'Nodes are not directly adjacent on the triangular lattice.',
        details: {'node1': move.node1.toJson(), 'node2': move.node2.toJson()},
      );
    }

    if (!geometry.containsEdge(edge.id)) {
      return RuleViolation(
        type: RuleViolationType.nonAdjacentNodes,
        message:
            'Edge ${edge.id} does not exist on a board of size ${state.boardSize}.',
      );
    }

    if (state.occupiedEdges.contains(edge.id)) {
      return RuleViolation(
        type: RuleViolationType.edgeAlreadyOccupied,
        message: 'Edge ${edge.id} is already occupied.',
        details: {'edgeId': edge.id},
      );
    }

    return null;
  }

  @override
  MoveResult applyMove(
    TriangleTacticsState state,
    String playerId,
    TriangleTacticsMove move,
  ) {
    final violation = validateMove(state, playerId, move);
    if (violation != null) {
      return MoveRejected(violation);
    }

    final geometry = getGeometry(state.boardSize);
    final edge = move.edge;
    final edgeId = edge.id;

    final nextOccupiedEdges = Set<String>.from(state.occupiedEdges)
      ..add(edgeId);

    // Evaluate adjacent elementary triangles
    final adjacentTriangles = geometry.edgeToTriangles[edgeId] ?? [];
    final newlyClaimedTriangles = <String>[];
    final nextClaimedTriangles = Map<String, String>.from(
      state.claimedTriangles,
    );

    for (final tri in adjacentTriangles) {
      if (!nextClaimedTriangles.containsKey(tri.id)) {
        if (tri.isCompleted(nextOccupiedEdges)) {
          newlyClaimedTriangles.add(tri.id);
          nextClaimedTriangles[tri.id] = playerId;
        }
      }
    }

    final extraTurnAwarded = newlyClaimedTriangles.isNotEmpty;
    final nextPlayerId = extraTurnAwarded
        ? playerId
        : state.opponentOf(playerId);

    final p1ScoreDelta = playerId == state.player1Id
        ? newlyClaimedTriangles.length
        : 0;
    final p2ScoreDelta = playerId == state.player2Id
        ? newlyClaimedTriangles.length
        : 0;
    final nextP1Score = state.player1Score + p1ScoreDelta;
    final nextP2Score = state.player2Score + p2ScoreDelta;

    final isTerminal = nextOccupiedEdges.length == geometry.edges.length;

    String? winnerId;
    bool isDraw = false;
    if (isTerminal) {
      if (nextP1Score > nextP2Score) {
        winnerId = state.player1Id;
      } else if (nextP2Score > nextP1Score) {
        winnerId = state.player2Id;
      } else {
        isDraw = true;
      }
    }

    final nextStateVersion = state.stateVersion + 1;

    final record = MoveRecord(
      moveIndex: state.moveHistory.length,
      playerId: playerId,
      node1: move.node1,
      node2: move.node2,
      edgeId: edgeId,
      claimedTriangles: List.unmodifiable(newlyClaimedTriangles),
      extraTurn: extraTurnAwarded,
      stateVersion: nextStateVersion,
    );

    final nextState = state.copyWith(
      occupiedEdges: Set.unmodifiable(nextOccupiedEdges),
      claimedTriangles: Map.unmodifiable(nextClaimedTriangles),
      moveHistory: List.unmodifiable([...state.moveHistory, record]),
      stateVersion: nextStateVersion,
      activePlayerId: nextPlayerId,
      player1Score: nextP1Score,
      player2Score: nextP2Score,
      isTerminal: isTerminal,
      winnerId: winnerId,
      isDraw: isDraw,
    );

    return MoveAccepted(
      nextState: nextState,
      edgeId: edgeId,
      newlyClaimedTriangles: List.unmodifiable(newlyClaimedTriangles),
      extraTurnAwarded: extraTurnAwarded,
      nextPlayerId: nextPlayerId,
      isTerminal: isTerminal,
      winnerId: winnerId,
      isDraw: isDraw,
    );
  }

  @override
  StateValidationResult validateInvariants(TriangleTacticsState state) {
    return StateValidator.validate(state, getGeometry(state.boardSize));
  }

  @override
  Map<String, dynamic> serializeState(TriangleTacticsState state) =>
      state.toJson();

  @override
  TriangleTacticsState deserializeState(Map<String, dynamic> json) =>
      TriangleTacticsState.fromJson(json);

  /// Helper to return all legal moves available in the given state.
  List<TriangleTacticsMove> getLegalMoves(TriangleTacticsState state) {
    if (state.isTerminal) return const [];
    final geometry = getGeometry(state.boardSize);
    final moves = <TriangleTacticsMove>[];
    for (final edge in geometry.edges) {
      if (!state.occupiedEdges.contains(edge.id)) {
        moves.add(TriangleTacticsMove(node1: edge.node1, node2: edge.node2));
      }
    }
    return moves;
  }
}
