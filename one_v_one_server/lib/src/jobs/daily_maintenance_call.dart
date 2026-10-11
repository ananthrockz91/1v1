import 'package:serverpod/serverpod.dart';
import '../services/daily_maintenance_processor.dart';

class DailyMaintenanceFutureCall extends FutureCall {
  Future<void> run(Session session) async {
    session.log('Running daily maintenance scheduled job.');
    await DailyMaintenanceProcessor.run(session);
  }
}
