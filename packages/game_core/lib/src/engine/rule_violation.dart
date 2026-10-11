import 'package:meta/meta.dart';

enum RuleViolationType {
  notYourTurn,
  matchAlreadyTerminal,
  unknownPlayer,
  nodeOutOfBounds,
  nonAdjacentNodes,
  selfLoop,
  edgeAlreadyOccupied,
  malformedAction,
  stateVersionMismatch,
}

@immutable
class RuleViolation {
  final RuleViolationType type;
  final String message;
  final Map<String, dynamic> details;

  const RuleViolation({
    required this.type,
    required this.message,
    this.details = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'details': details,
  };

  factory RuleViolation.fromJson(Map<String, dynamic> json) => RuleViolation(
    type: RuleViolationType.values.byName(json['type'] as String),
    message: json['message'] as String,
    details: (json['details'] as Map<String, dynamic>?) ?? {},
  );

  @override
  String toString() => 'RuleViolation($type: $message)';
}
