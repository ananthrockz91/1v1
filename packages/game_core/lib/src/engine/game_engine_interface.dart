import 'package:meta/meta.dart';
import 'move_result.dart';
import 'rule_violation.dart';

@immutable
class StateValidationResult {
  final bool isValid;
  final List<String> violations;

  const StateValidationResult({
    required this.isValid,
    this.violations = const [],
  });

  static const valid = StateValidationResult(isValid: true);

  factory StateValidationResult.invalid(List<String> errors) =>
      StateValidationResult(isValid: false, violations: errors);

  @override
  String toString() => isValid
      ? 'StateValidationResult.valid'
      : 'StateValidationResult.invalid(${violations.join("; ")})';
}

/// Abstract contract implemented by every game on the 1v1 platform.
abstract class GameEngine<TState, TMove> {
  String get gameId;
  String get rulesetVersion;

  RuleViolation? validateMove(TState state, String playerId, TMove move);
  MoveResult applyMove(TState state, String playerId, TMove move);
  StateValidationResult validateInvariants(TState state);
  Map<String, dynamic> serializeState(TState state);
  TState deserializeState(Map<String, dynamic> json);
}
