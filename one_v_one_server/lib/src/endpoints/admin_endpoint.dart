import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/daily_maintenance_processor.dart';

class AdminEndpoint extends Endpoint {
  /// Development/demo manual trigger to run the daily maintenance process
  /// on demand without waiting for 1:00 AM IST.
  Future<ScheduledJobLog> triggerDailyMaintenance(
    Session session, {
    String? targetDate,
  }) async {
    final caller = session.authenticated?.userIdentifier ?? 'development_user';
    session.log(
      'Manual trigger of daily maintenance requested by $caller',
      level: LogLevel.info,
    );
    return await DailyMaintenanceProcessor.run(
      session,
      targetDate: targetDate,
    );
  }

  /// Clears in-memory caches across leaderboards and profiles.
  Future<bool> clearCaches(Session session) async {
    try {
      await session.caches.local.clear();
      await session.caches.localPrio.clear();
      session.log('Admin cleared server local caches', level: LogLevel.info);
      return true;
    } catch (e) {
      session.log('Failed to clear caches: $e', level: LogLevel.error);
      return false;
    }
  }
}
