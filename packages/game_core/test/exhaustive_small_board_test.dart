import 'package:game_test_support/game_test_support.dart';
import 'package:test/test.dart';

void main() {
  group('Exhaustive Small-Board State Validation (Suite A.3)', () {
    test(
      'exhaustively traverses all reachable states on board size 2 with invariant verification',
      () {
        final result = ExhaustiveSmallBoardValidator.run(
          boardSize: 2,
          maxStates: 5000,
        );

        expect(result.success, isTrue, reason: result.error);
        expect(result.uniqueStatesExplored, greaterThan(100));
        expect(result.terminalStatesReached, greaterThan(0));
      },
    );
  });
}
