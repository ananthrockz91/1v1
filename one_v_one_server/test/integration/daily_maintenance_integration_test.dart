import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Suite G: Daily Maintenance Job & Idempotency', (
    sessionBuilder,
    endpoints,
  ) {
    test('triggerDailyMaintenance runs cleanly and records log', () async {
      final log = await endpoints.admin.triggerDailyMaintenance(
        sessionBuilder,
        targetDate: '2026-10-11',
      );

      expect(log.success, isTrue);
      expect(log.jobName, equals('daily_maintenance'));
      expect(log.targetDate, equals('2026-10-11'));
      expect(log.errorDetails, isNull);
    });

    test(
      're-running daily maintenance for same date is fully idempotent',
      () async {
        final run1 = await endpoints.admin.triggerDailyMaintenance(
          sessionBuilder,
          targetDate: '2026-10-11',
        );
        expect(run1.success, isTrue);

        final run2 = await endpoints.admin.triggerDailyMaintenance(
          sessionBuilder,
          targetDate: '2026-10-11',
        );
        expect(run2.success, isTrue);

        // Verify leaderboard entries are consistent
        final leaderboard = await endpoints.leaderboard.getDailyLeaderboard(
          sessionBuilder,
          dateString: '2026-10-11',
          limit: 50,
        );

        // Rankings must be distinct
        final ranks = leaderboard.map((e) => e.rank).toList();
        expect(ranks.toSet().length, equals(ranks.length));
      },
    );
  });
}
