import 'package:meta/meta.dart';
import 'rule_violation.dart';
import 'triangle_tactics_state.dart';

/// Sealed result of applying an action to the game state.
@immutable
sealed class MoveResult {
  const MoveResult();

  bool get isAccepted => this is MoveAccepted;
  bool get isRejected => this is MoveRejected;
}

class MoveAccepted extends MoveResult {
  final TriangleTacticsState nextState;
  final String edgeId;
  final List<String> newlyClaimedTriangles;
  final bool extraTurnAwarded;
  final String nextPlayerId;
  final bool isTerminal;
  final String? winnerId;
  final bool isDraw;

  const MoveAccepted({
    required this.nextState,
    required this.edgeId,
    required this.newlyClaimedTriangles,
    required this.extraTurnAwarded,
    required this.nextPlayerId,
    required this.isTerminal,
    this.winnerId,
    this.isDraw = false,
  });

  Map<String, dynamic> toJson() => {
    'status': 'accepted',
    'edgeId': edgeId,
    'newlyClaimedTriangles': newlyClaimedTriangles,
    'extraTurnAwarded': extraTurnAwarded,
    'nextPlayerId': nextPlayerId,
    'isTerminal': isTerminal,
    if (winnerId != null) 'winnerId': winnerId,
    'isDraw': isDraw,
    'nextState': nextState.toJson(),
  };
}

class MoveRejected extends MoveResult {
  final RuleViolation violation;

  const MoveRejected(this.violation);

  Map<String, dynamic> toJson() => {
    'status': 'rejected',
    'violation': violation.toJson(),
  };

  @override
  String toString() => 'MoveRejected(${violation.message})';
}
