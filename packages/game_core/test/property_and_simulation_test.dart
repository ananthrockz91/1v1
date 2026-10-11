import 'package:game_test_support/game_test_support.dart';
import 'package:test/test.dart';

void main() {
  group('Random Match Simulator (Property-Based Suite A.2)', () {
    test(
      'simulates 50 complete matches with invariant checking at every step',
      () {
        final result = RandomMatchSimulator.run(
          matchCount: 50,
          initialSeed: 1337,
          boardSize: 3,
          injectInvalidMoves: true,
        );

        expect(result.success, isTrue, reason: result.failureMessage);
        expect(result.matchesCompleted, equals(50));
        expect(result.totalMovesPlayed, greaterThan(0));
      },
    );
  });
}
