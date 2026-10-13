import 'package:flutter/material.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../theme/app_colors.dart';
import '../widgets/player_avatar.dart';

class AdminBoardScreen extends StatefulWidget {
  const AdminBoardScreen({super.key});

  @override
  State<AdminBoardScreen> createState() => _AdminBoardScreenState();
}

class _AdminBoardScreenState extends State<AdminBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdminDashboardData? _data;
  bool _isLoading = true;
  bool _isActionRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await client.admin.getDashboardData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load backend metrics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerMaintenance() async {
    setState(() => _isActionRunning = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final log = await client.admin.triggerDailyMaintenance();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily Maintenance completed! Lobbies cleaned: ${log.staleLobbiesCleaned}, '
                  'Rankings aggregated: ${log.leaderboardsAggregated}, Cache group invalidated.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceElevated,
          duration: const Duration(seconds: 4),
        ),
      );
      await _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to trigger maintenance: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  Future<void> _clearCaches() async {
    setState(() => _isActionRunning = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await client.admin.clearCaches();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Serverpod local in-memory caches flushed successfully!'
                : 'Could not flush caches.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      await _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error clearing caches: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isActionRunning = false);
    }
  }

  String _formatUptime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.player1.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.memory_rounded,
                color: AppColors.player1,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serverpod Command Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Live Authoritative Backend Inspector',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.player1,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh Metrics',
            onPressed: _isLoading ? null : _fetchDashboardData,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.player1,
          indicatorWeight: 3,
          labelColor: AppColors.player1,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Live Matches'),
            Tab(text: 'Cron Logs'),
            Tab(text: 'Architecture'),
          ],
        ),
      ),
      body: _isLoading && _data == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.player1),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _data != null
                    ? _buildOverviewTab()
                    : _buildRestartRequiredOverviewTab(),
                _buildMatchesTab(),
                _buildCronLogsTab(),
                _buildArchitectureShowcaseTab(),
              ],
            ),
    );
  }

  Widget _buildRestartRequiredOverviewTab() {
    final isMethodNotFound =
        _errorMessage?.contains('Method not found in endpoint') ?? false;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_problem_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Serverpod Restart Required',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isMethodNotFound
                          ? 'New methods (getDashboardData) were generated for AdminEndpoint. In Serverpod, newly added endpoint methods require a server restart to register into the route dispatcher.'
                          : (_errorMessage ?? 'Could not connect to backend.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            color: AppColors.player1,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Switch to the terminal running "serverpod start" and press "R" to hot-restart the backend.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.player1,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _fetchDashboardData,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'Retry Connection',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber,
                            side: BorderSide(
                              color: Colors.amber.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _triggerMaintenance,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Test Maintenance RPC'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tip: You can still click the "Architecture" tab above to review all Serverpod features!',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: OVERVIEW METRICS & CONTROLS
  // -------------------------------------------------------------
  Widget _buildOverviewTab() {
    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.player1.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Serverpod Engine: ONLINE',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  d.runMode.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.player1,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Server ID: ${d.serverId} • Uptime: ${_formatUptime(d.uptimeSeconds)} • DB Latency: ${d.dbLatencyMs} ms',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metric Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 1.4 : 1.3,
                    children: [
                      _buildMetricCard(
                        title: 'Total Matches',
                        value: '${d.totalMatches}',
                        subtitle:
                            '${d.inProgressMatches} active • ${d.waitingMatches} waiting',
                        icon: Icons.sports_esports_outlined,
                        color: AppColors.player1,
                      ),
                      _buildMetricCard(
                        title: 'Total Players',
                        value: '${d.totalPlayers}',
                        subtitle: 'PostgreSQL registered profiles',
                        icon: Icons.people_outline,
                        color: AppColors.player2,
                      ),
                      _buildMetricCard(
                        title: 'ACID Moves',
                        value: '${d.totalMoves}',
                        subtitle: 'Recorded in match_move_record',
                        icon: Icons.sync_alt_outlined,
                        color: AppColors.success,
                      ),
                      _buildMetricCard(
                        title: 'Local Caches',
                        value: '${d.localCacheEntries}',
                        subtitle: 'In-memory keys (TTL enabled)',
                        icon: Icons.bolt_outlined,
                        color: AppColors.tealLight,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Multi-Game Arena Telemetry Card
              _buildGameBreakdownCard(d),
              const SizedBox(height: 24),

              // Interactive Action Triggers
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.terminal,
                          color: AppColors.player1,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Interactive Serverpod Control Actions',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trigger backend actions to witness Serverpod scheduled jobs, transaction processors, and cache invalidation in real time:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.player1,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isActionRunning
                              ? null
                              : _triggerMaintenance,
                          icon: const Icon(Icons.schedule, size: 18),
                          label: const Text(
                            'Execute 1:00 AM Maintenance (FutureCall)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.surfaceBorder,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isActionRunning ? null : _clearCaches,
                          icon: const Icon(
                            Icons.delete_sweep_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Flush In-Memory Caches (session.caches.local)',
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.player2,
                            side: BorderSide(
                              color: AppColors.player2.withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showHealthzDialog(context),
                          icon: const Icon(
                            Icons.health_and_safety_outlined,
                            size: 18,
                          ),
                          label: const Text('Probe /healthz Route'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Players Strip
              if (d.recentPlayers.isNotEmpty) ...[
                const Text(
                  'Top Ranked Players (PostgreSQL Table: player_profile)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: d.recentPlayers.take(4).map((p) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerAvatar(
                            avatarSeed: p.avatarSeed,
                            displayName: p.displayName,
                            size: 38,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${p.wins} wins • ${p.totalMatches} matches',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGameBreakdownCard(AdminDashboardData d) {
    int triangleActive = 0, triangleWaiting = 0, triangleCompleted = 0;
    int connectFourActive = 0, connectFourWaiting = 0, connectFourCompleted = 0;
    int reversiActive = 0, reversiWaiting = 0, reversiCompleted = 0;

    for (final m in d.recentMatches) {
      if (m.gameType == 'triangle_tactics') {
        if (m.status == 'in_progress') {
          triangleActive++;
        } else if (m.status == 'waiting') {
          triangleWaiting++;
        } else if (m.status == 'completed') {
          triangleCompleted++;
        }
      } else if (m.gameType == 'connect_four') {
        if (m.status == 'in_progress') {
          connectFourActive++;
        } else if (m.status == 'waiting') {
          connectFourWaiting++;
        } else if (m.status == 'completed') {
          connectFourCompleted++;
        }
      } else if (m.gameType == 'reversi') {
        if (m.status == 'in_progress') {
          reversiActive++;
        } else if (m.status == 'waiting') {
          reversiWaiting++;
        } else if (m.status == 'completed') {
          reversiCompleted++;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AppColors.player1,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Multi-Game Telemetry Breakdown',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '3 ENGINES ACTIVE',
                  style: TextStyle(
                    color: AppColors.player1,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildGameTelemetryItem(
                  title: 'Triangle Tactics',
                  icon: Icons.change_history,
                  color: AppColors.player1,
                  active: triangleActive,
                  waiting: triangleWaiting,
                  completed: triangleCompleted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGameTelemetryItem(
                  title: 'Gravity Drop',
                  icon: Icons.blur_linear,
                  color: AppColors.tealLight,
                  active: connectFourActive,
                  waiting: connectFourWaiting,
                  completed: connectFourCompleted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGameTelemetryItem(
                  title: 'Chroma Reversi',
                  icon: Icons.radio_button_checked,
                  color: AppColors.teal,
                  active: reversiActive,
                  waiting: reversiWaiting,
                  completed: reversiCompleted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameTelemetryItem({
    required String title,
    required IconData icon,
    required Color color,
    required int active,
    required int waiting,
    required int completed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live: $active',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Wait: $waiting',
                style: const TextStyle(
                  color: AppColors.player2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Completed: $completed',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: LIVE MATCHES TABLE (game_match)
  // -------------------------------------------------------------
  Widget _buildMatchesTab() {
    final matches = _data?.recentMatches ?? [];
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          'No matches recorded in game_match yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final m = matches[index];
        final isWaiting = m.status == 'waiting';
        final isInProgress = m.status == 'in_progress';

        final statusColor = isInProgress
            ? AppColors.player1
            : isWaiting
            ? AppColors.player2
            : AppColors.textMuted;

        final String gameName;
        final IconData gameIcon;
        final Color gameColor;
        if (m.gameType == 'triangle_tactics') {
          gameName = 'TRIANGLE';
          gameIcon = Icons.change_history;
          gameColor = AppColors.player1;
        } else if (m.gameType == 'connect_four') {
          gameName = 'GRAVITY DROP';
          gameIcon = Icons.blur_linear;
          gameColor = AppColors.tealLight;
        } else if (m.gameType == 'reversi') {
          gameName = 'REVERSI';
          gameIcon = Icons.radio_button_checked;
          gameColor = AppColors.teal;
        } else {
          gameName = m.gameType.toUpperCase();
          gameIcon = Icons.sports_esports;
          gameColor = AppColors.player2;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              // Game Badge & Room Code Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: gameColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: gameColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(gameIcon, size: 10, color: gameColor),
                        const SizedBox(width: 4),
                        Text(
                          gameName,
                          style: TextStyle(
                            color: gameColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Text(
                      m.roomCode ?? 'PUBLIC',
                      style: const TextStyle(
                        color: AppColors.player1,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P1: ${m.player1Id} vs P2: ${m.player2Id ?? '(Awaiting)'}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${m.player1Score} - ${m.player2Score} • Turn: ${m.activePlayerId} • Game: ${m.gameType}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: CRON SCHEDULED JOB LOGS (scheduled_job_log)
  // -------------------------------------------------------------
  Widget _buildCronLogsTab() {
    final logs = _data?.recentJobLogs ?? [];
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'No scheduled maintenance executions recorded yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.alarm_on,
                        color: AppColors.player1,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log.jobName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (log.success ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      log.success ? 'SUCCESS' : 'FAILED',
                      style: TextStyle(
                        color: log.success
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Target Date: ${log.targetDate} • Executed: ${log.executedAt.toLocal().toString().split('.').first}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stale Lobbies Cleaned: ${log.staleLobbiesCleaned} • Leaderboards Aggregated: ${log.leaderboardsAggregated}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 4: SERVERPOD ARCHITECTURE SHOWCASE
  // -------------------------------------------------------------
  Widget _buildArchitectureShowcaseTab() {
    final features = [
      _FeatureInfo(
        title: 'Type-Safe RPC & Endpoint Generation',
        icon: Icons.code,
        color: AppColors.player1,
        description:
            'All server endpoints (MatchEndpoint, PlayerEndpoint, LeaderboardEndpoint, AdminEndpoint) '
            'automatically generate strongly typed client methods in one_v_one_client. '
            'Zero manual HTTP mapping or JSON encoding boilerplate.',
      ),
      _FeatureInfo(
        title: 'Serverpod ORM & Database Schema',
        icon: Icons.storage,
        color: AppColors.player2,
        description:
            'Models defined in .spy.yaml (GameMatch, MatchMoveRecord, PlayerProfile, DailyLeaderboard, ScheduledJobLog) '
            'map to PostgreSQL tables. Queries are fully typed (GameMatch.db.findFirstRow, etc.).',
      ),
      _FeatureInfo(
        title: 'In-Memory Caching (session.caches.local)',
        icon: Icons.flash_on,
        color: AppColors.tealLight,
        description:
            'High-speed in-memory cache with TTL (5m daily leaderboards, 2m all-time leaderboards, 5m player profiles). '
            'Group invalidation automatically wipes "leaderboards" cache on daily aggregation.',
      ),
      _FeatureInfo(
        title: 'Task Scheduling & Future Calls (Cron)',
        icon: Icons.access_time_filled,
        color: AppColors.success,
        description:
            'Automated nightly cron job runs at 1:00 AM IST (19:30 UTC) using Serverpod FutureCalls. '
            'Cleans up abandoned lobbies, compiles daily stats, and logs execution into scheduled_job_log.',
      ),
      _FeatureInfo(
        title: 'Real-Time WebSocket Streaming (session.messages)',
        icon: Icons.stream,
        color: AppColors.tealLight,
        description:
            'Live multiplayer gameplay streams over WebSockets via Serverpod\'s message hub. '
            'Subscribing to match_\$matchId allows instant broadcast of player moves, scores, and forfeits.',
      ),
      _FeatureInfo(
        title: 'Direct Cloud Storage (session.storage & FileUploader)',
        icon: Icons.cloud_upload_outlined,
        color: AppColors.teal,
        description:
            'Player avatars stream directly to Serverpod Cloud Storage using presigned upload descriptions '
            'and native FileUploader, eliminating the need to store heavy base64 strings in database rows.',
      ),
      _FeatureInfo(
        title: 'ACID Database Transactions',
        icon: Icons.lock_outline,
        color: Colors.amberAccent,
        description:
            'Move submissions and room join operations execute inside session.db.transaction. '
            'Includes optimistic state locking (clientStateVersion == match.stateVersion) to prevent race conditions.',
      ),
      _FeatureInfo(
        title: 'Built-in Web Server & Health Probes',
        icon: Icons.health_and_safety_outlined,
        color: Colors.tealAccent,
        description:
            'Serverpod hosts the Flutter Web application at /, serves dynamic config at /assets/assets/config.json, '
            'and provides /healthz, /livez, and /readyz probes for container orchestration.',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: features.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final feat = features[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: feat.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(feat.icon, color: feat.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feat.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feat.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHealthzDialog(BuildContext context) {
    final d = _data;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: AppColors.player2, size: 22),
            SizedBox(width: 8),
            Text(
              'Public Probe: /healthz',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Text(
              '{\n'
              '  "status": "healthy",\n'
              '  "database": {\n'
              '    "connected": true,\n'
              '    "latencyMs": ${d?.dbLatencyMs ?? 2},\n'
              '    "totalJobLogs": ${d?.totalScheduledLogs ?? 0}\n'
              '  },\n'
              '  "server": {\n'
              '    "serverId": "${d?.serverId ?? "default"}",\n'
              '    "runMode": "${d?.runMode ?? "development"}",\n'
              '    "uptimeSeconds": ${d?.uptimeSeconds ?? 0}\n'
              '  },\n'
              '  "caches": {\n'
              '    "localCacheEntries": ${d?.localCacheEntries ?? 0},\n'
              '    "localPrioCacheEntries": ${d?.localPrioCacheEntries ?? 0}\n'
              '  }\n'
              '}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppColors.player1,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FeatureInfo {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _FeatureInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}
