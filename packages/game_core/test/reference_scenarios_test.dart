import 'package:game_test_support/game_test_support.dart';
import 'package:test/test.dart';

void main() {
  group('Reference Scenarios (Deterministic Gameplay Cases)', () {
    test('Scenario 1: Quiet move switches turns', () {
      expect(() => ReferenceScenarios.runQuietMoveScenario(), returnsNormally);
    });

    test(
      'Scenario 2: Single triangle completion awards 1 point and extra turn',
      () {
        expect(
          () => ReferenceScenarios.runSingleTriangleCompletionScenario(),
          returnsNormally,
        );
      },
    );

    test(
      'Scenario 3: Double triangle completion awards 2 points and extra turn',
      () {
        expect(
          () => ReferenceScenarios.runDoubleTriangleCompletionScenario(),
          returnsNormally,
        );
      },
    );

    test('Scenario 4: Rejection of out-of-turn move', () {
      expect(
        () => ReferenceScenarios.runOutOfTurnRejectionScenario(),
        returnsNormally,
      );
    });

    test('Scenario 5: Rejection of duplicate edge move', () {
      expect(
        () => ReferenceScenarios.runDuplicateEdgeRejectionScenario(),
        returnsNormally,
      );
    });
  });
}
