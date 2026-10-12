import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';

class HealthWidget extends JsonWidget {
  HealthWidget(Map<String, dynamic> data) : super(object: data);
}

class HealthRoute extends WidgetRoute {
  static final DateTime _startedAt = DateTime.now();

  @override
  Future<WebWidget> build(Session session, Request request) async {
    final sw = Stopwatch()..start();
    bool dbHealthy = false;
    String? dbError;
    int? logCount;

    try {
      // Test database connectivity and ORM health with a fast probe
      logCount = await ScheduledJobLog.db.count(session);
      dbHealthy = true;
    } catch (e) {
      dbError = e.toString();
    }
    sw.stop();

    final data = <String, dynamic>{
      'status': dbHealthy ? 'healthy' : 'unhealthy',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'database': {
        'connected': dbHealthy,
        'latencyMs': sw.elapsedMilliseconds,
        'totalJobLogs': ?logCount,
        'error': ?dbError,
      },
      'server': {
        'serverId': session.server.serverId,
        'runMode': session.server.runMode,
        'uptimeSeconds': DateTime.now().difference(_startedAt).inSeconds,
      },
      'caches': {
        'localCacheEntries': session.caches.local.localSize,
        'localPrioCacheEntries': session.caches.localPrio.localSize,
      },
    };

    return HealthWidget(data);
  }
}
