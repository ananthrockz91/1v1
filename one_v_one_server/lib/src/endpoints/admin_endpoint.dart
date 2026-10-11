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
    session.log('Manual trigger of daily maintenance requested.');
    return await DailyMaintenanceProcessor.run(
      session,
      targetDate: targetDate,
    );
  }
}
