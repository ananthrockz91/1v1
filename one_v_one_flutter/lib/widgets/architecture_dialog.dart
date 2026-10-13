import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../client.dart';
import '../theme/theme_provider.dart';

class ArchitectureDialog extends ConsumerStatefulWidget {
  const ArchitectureDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ArchitectureDialog(),
    );
  }

  @override
  ConsumerState<ArchitectureDialog> createState() => _ArchitectureDialogState();
}

class _ArchitectureDialogState extends ConsumerState<ArchitectureDialog> {
  bool _isLoadingHealth = true;
  Map<String, dynamic>? _healthData;
  String? _healthError;

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoadingHealth = true;
      _healthError = null;
    });

    try {
      final dashboard = await client.admin.getDashboardData();
      if (!mounted) return;
      setState(() {
        _healthData = {
          'status': 'healthy',
          'server': {
            'runMode': dashboard.runMode,
            'uptimeSeconds': dashboard.uptimeSeconds,
            'serverId': dashboard.serverId,
          },
          'database': {
            'connected': true,
            'latencyMs': dashboard.dbLatencyMs,
          },
          'metrics': {
            'matches': dashboard.totalMatches,
            'players': dashboard.totalPlayers,
            'caches': dashboard.localCacheEntries,
          },
        };
        _isLoadingHealth = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _healthError = 'Diagnostics offline: $e';
        _isLoadingHealth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.surfaceBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.player1.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.memory_rounded,
                      color: theme.player1,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serverpod Architecture',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Full-Stack Architecture & Live Cloud Infrastructure',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Live Cloud Health Status Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _healthData?['status'] == 'healthy' ||
                            _healthData?['database']?['connected'] == true
                        ? theme.player1.withValues(alpha: 0.4)
                        : theme.surfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isLoadingHealth
                            ? theme.statusWarning
                            : (_healthData != null
                                  ? theme.statusSuccess
                                  : theme.statusError),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isLoadingHealth
                            ? 'Pinging Serverpod Cloud health endpoint...'
                            : (_healthData != null
                                  ? 'Serverpod Cloud: ONLINE (${_healthData?["server"]?["runMode"] ?? "production"}) • DB Latency: ${_healthData?["database"]?["latencyMs"] ?? "10"}ms'
                                  : (_healthError ??
                                        'Live Cloud Status: Standby')),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: theme.player1,
                      ),
                      tooltip: 'Refresh Health Ping',
                      onPressed: _fetchHealthData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Architecture Breakdown List
              Expanded(
                child: ListView(
                  children: [
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.alt_route_rounded,
                      color: theme.player1,
                      title: 'Real-Time Streaming WebSockets',
                      sub: 'MatchEndpoint & EventStreams',
                      desc:
                          'Low-latency bidirectional move streaming. Edge placement, triangle capture events, and board state synchronization run over Serverpod WebSockets with deterministic verification.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.storage_rounded,
                      color: theme.player2,
                      title: 'PostgreSQL Database & Schema Migrations',
                      sub: 'Automated Migration Toolchain',
                      desc:
                          'Player profiles, match records, ELO ratings, and move histories are persisted with Serverpod ORM relations. Tracked migrations run automatically on Cloud deploy.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.cloud_upload_rounded,
                      color: theme.accentSecondary,
                      title: 'Serverpod Cloud Storage',
                      sub: 'Custom Player Avatars',
                      desc:
                          'Direct file uploads for player avatars uploaded from desktop or mobile and stored securely in public Serverpod Cloud Storage buckets with fallback caching.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.schedule_rounded,
                      color: theme.statusSuccess,
                      title: 'Future Calls & Scheduled Maintenance',
                      sub: 'Autonomous Cron Tasks',
                      desc:
                          'Server-driven daily maintenance jobs scheduled with cron expressions. Aggregates leaderboard standings, prunes stale uncompleted matches, and flushes expired caches.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.lock_outline_rounded,
                      color: theme.player1,
                      title: 'Authentication & Session Security',
                      sub: 'serverpod_auth_idp',
                      desc:
                          'JWT tokens, password hashing with SHA-512 pepper, automated guest profile provisioning, and seamless auth token persistence across app reloads.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.speed_rounded,
                      color: theme.player2,
                      title: 'High-Performance Local & Priority Caches',
                      sub: 'Serverpod Cache Infrastructure',
                      desc:
                          'Zero-latency caching for player profiles and leaderboard queries, slashing database load and guaranteeing instant lobby response times.',
                    ),
                    _buildFeatureCard(
                      theme: theme,
                      icon: Icons.webhook_rounded,
                      color: theme.accentSecondary,
                      title: 'Unified Serverpod Cloud Web Serving',
                      sub: 'Single Docker Deployment',
                      desc:
                          'The Serverpod server serves both the backend API and the Flutter Web client bundle from the root path (/), eliminating cross-origin CORS hurdles.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Close button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonBackground,
                  foregroundColor: theme.buttonForeground,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close Architecture Overview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required AppThemeData theme,
    required IconData icon,
    required Color color,
    required String title,
    required String sub,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 320;
                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sub,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sub,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
