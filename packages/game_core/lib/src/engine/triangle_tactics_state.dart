import 'package:meta/meta.dart';
import '../board/grid_node.dart';

@immutable
class MoveRecord {
  final int moveIndex;
  final String playerId;
  final GridNode node1;
  final GridNode node2;
  final String edgeId;
  final List<String> claimedTriangles;
  final bool extraTurn;
  final int stateVersion;

  const MoveRecord({
    required this.moveIndex,
    required this.playerId,
    required this.node1,
    required this.node2,
    required this.edgeId,
    required this.claimedTriangles,
    required this.extraTurn,
    required this.stateVersion,
  });

  Map<String, dynamic> toJson() => {
    'moveIndex': moveIndex,
    'playerId': playerId,
    'node1': node1.toJson(),
    'node2': node2.toJson(),
    'edgeId': edgeId,
    'claimedTriangles': claimedTriangles,
    'extraTurn': extraTurn,
    'stateVersion': stateVersion,
  };

  factory MoveRecord.fromJson(Map<String, dynamic> json) => MoveRecord(
    moveIndex: json['moveIndex'] as int,
    playerId: json['playerId'] as String,
    node1: GridNode.fromJson(json['node1'] as Map<String, dynamic>),
    node2: GridNode.fromJson(json['node2'] as Map<String, dynamic>),
    edgeId: json['edgeId'] as String,
    claimedTriangles: (json['claimedTriangles'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    extraTurn: json['extraTurn'] as bool,
    stateVersion: json['stateVersion'] as int,
  );
}

@immutable
class TriangleTacticsState {
  static const String currentRulesetVersion = '1.0.0';

  final String rulesetVersion;
  final int boardSize;
  final String player1Id;
  final String player2Id;
  final String activePlayerId;
  final int player1Score;
  final int player2Score;
  final Set<String> occupiedEdges;
  final Map<String, String> claimedTriangles; // triangleId -> playerId
  final List<MoveRecord> moveHistory;
  final int stateVersion;
  final bool isTerminal;
  final String? winnerId;
  final bool isDraw;

  const TriangleTacticsState({
    required this.rulesetVersion,
    required this.boardSize,
    required this.player1Id,
    required this.player2Id,
    required this.activePlayerId,
    required this.player1Score,
    required this.player2Score,
    required this.occupiedEdges,
    required this.claimedTriangles,
    required this.moveHistory,
    required this.stateVersion,
    required this.isTerminal,
    this.winnerId,
    this.isDraw = false,
  });

  factory TriangleTacticsState.initial({
    required String player1Id,
    required String player2Id,
    int boardSize = 4,
    String? startingPlayerId,
  }) {
    return TriangleTacticsState(
      rulesetVersion: currentRulesetVersion,
      boardSize: boardSize,
      player1Id: player1Id,
      player2Id: player2Id,
      activePlayerId: startingPlayerId ?? player1Id,
      player1Score: 0,
      player2Score: 0,
      occupiedEdges: const {},
      claimedTriangles: const {},
      moveHistory: const [],
      stateVersion: 0,
      isTerminal: false,
      winnerId: null,
      isDraw: false,
    );
  }

  String opponentOf(String playerId) {
    if (playerId == player1Id) return player2Id;
    if (playerId == player2Id) return player1Id;
    throw ArgumentError('Player $playerId is not in this match');
  }

  bool isParticipant(String playerId) =>
      playerId == player1Id || playerId == player2Id;

  TriangleTacticsState copyWith({
    String? rulesetVersion,
    int? boardSize,
    String? player1Id,
    String? player2Id,
    String? activePlayerId,
    int? player1Score,
    int? player2Score,
    Set<String>? occupiedEdges,
    Map<String, String>? claimedTriangles,
    List<MoveRecord>? moveHistory,
    int? stateVersion,
    bool? isTerminal,
    String? winnerId,
    bool? isDraw,
  }) {
    return TriangleTacticsState(
      rulesetVersion: rulesetVersion ?? this.rulesetVersion,
      boardSize: boardSize ?? this.boardSize,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      activePlayerId: activePlayerId ?? this.activePlayerId,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      occupiedEdges: occupiedEdges ?? this.occupiedEdges,
      claimedTriangles: claimedTriangles ?? this.claimedTriangles,
      moveHistory: moveHistory ?? this.moveHistory,
      stateVersion: stateVersion ?? this.stateVersion,
      isTerminal: isTerminal ?? this.isTerminal,
      winnerId: winnerId ?? this.winnerId,
      isDraw: isDraw ?? this.isDraw,
    );
  }

  Map<String, dynamic> toJson() => {
    'rulesetVersion': rulesetVersion,
    'boardSize': boardSize,
    'player1Id': player1Id,
    'player2Id': player2Id,
    'activePlayerId': activePlayerId,
    'player1Score': player1Score,
    'player2Score': player2Score,
    'occupiedEdges': occupiedEdges.toList(),
    'claimedTriangles': claimedTriangles,
    'moveHistory': moveHistory.map((m) => m.toJson()).toList(),
    'stateVersion': stateVersion,
    'isTerminal': isTerminal,
    if (winnerId != null) 'winnerId': winnerId,
    'isDraw': isDraw,
  };

  factory TriangleTacticsState.fromJson(Map<String, dynamic> json) =>
      TriangleTacticsState(
        rulesetVersion: json['rulesetVersion'] as String,
        boardSize: json['boardSize'] as int,
        player1Id: json['player1Id'] as String,
        player2Id: json['player2Id'] as String,
        activePlayerId: json['activePlayerId'] as String,
        player1Score: json['player1Score'] as int,
        player2Score: json['player2Score'] as int,
        occupiedEdges: Set<String>.from(json['occupiedEdges'] as List<dynamic>),
        claimedTriangles: Map<String, String>.from(
          json['claimedTriangles'] as Map<dynamic, dynamic>,
        ),
        moveHistory: (json['moveHistory'] as List<dynamic>)
            .map((m) => MoveRecord.fromJson(m as Map<String, dynamic>))
            .toList(),
        stateVersion: json['stateVersion'] as int,
        isTerminal: json['isTerminal'] as bool,
        winnerId: json['winnerId'] as String?,
        isDraw: json['isDraw'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriangleTacticsState &&
          runtimeType == other.runtimeType &&
          rulesetVersion == other.rulesetVersion &&
          boardSize == other.boardSize &&
          player1Id == other.player1Id &&
          player2Id == other.player2Id &&
          activePlayerId == other.activePlayerId &&
          player1Score == other.player1Score &&
          player2Score == other.player2Score &&
          stateVersion == other.stateVersion &&
          isTerminal == other.isTerminal &&
          winnerId == other.winnerId &&
          isDraw == other.isDraw &&
          occupiedEdges.length == other.occupiedEdges.length &&
          occupiedEdges.containsAll(other.occupiedEdges) &&
          claimedTriangles.length == other.claimedTriangles.length;

  @override
  int get hashCode => Object.hash(
    rulesetVersion,
    boardSize,
    player1Id,
    player2Id,
    activePlayerId,
    player1Score,
    player2Score,
    stateVersion,
    isTerminal,
    winnerId,
    isDraw,
  );
}
