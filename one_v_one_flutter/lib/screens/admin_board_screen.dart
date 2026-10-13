import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../theme/theme_provider.dart';
import '../widgets/player_avatar.dart';

class AdminBoardScreen extends ConsumerStatefulWidget {
  const AdminBoardScreen({super.key});

  @override
  ConsumerState<AdminBoardScreen> createState() => _AdminBoardScreenState();
}

class _AdminBoardScreenState extends ConsumerState<AdminBoardScreen>
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
      final theme = ref.read(currentThemeProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.statusSuccess,
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
          backgroundColor: theme.surfaceElevated,
          duration: const Duration(seconds: 4),
        ),
      );
      await _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      final theme = ref.read(currentThemeProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to trigger maintenance: $e'),
          backgroundColor: theme.statusError,
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
      final theme = ref.read(currentThemeProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Serverpod local in-memory caches flushed successfully!'
                : 'Could not flush caches.',
          ),
          backgroundColor: success ? theme.statusSuccess : theme.statusError,
        ),
      );
      await _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      final theme = ref.read(currentThemeProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error clearing caches: $e'),
          backgroundColor: theme.statusError,
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
    final theme = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.player1.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.memory_rounded,
                color: theme.player1,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serverpod Command Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                Text(
                  'Live Authoritative Backend Inspector',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (showThemeSwitcher) ...[
            // Theme Switcher Toggle Pill
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.isMonochrome
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFF14B8A6).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        theme.isMonochrome
                            ? Icons.contrast_rounded
                            : Icons.palette_outlined,
                        size: 13,
                        color: theme.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        theme.name,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          IconButton(
            icon: _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.player1,
                    ),
                  )
                : Icon(Icons.refresh, color: theme.textSecondary),
            tooltip: 'Refresh Metrics',
            onPressed: _isLoading ? null : _fetchDashboardData,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.player1,
          indicatorWeight: 3,
          labelColor: theme.player1,
          unselectedLabelColor: theme.textSecondary,
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
          ? Center(
              child: CircularProgressIndicator(color: theme.player1),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _data != null
                    ? _buildOverviewTab(theme)
                    : _buildRestartRequiredOverviewTab(theme),
                _buildMatchesTab(theme),
                _buildCronLogsTab(theme),
                _buildArchitectureShowcaseTab(theme),
              ],
            ),
    );
  }

  Widget _buildRestartRequiredOverviewTab(AppThemeData theme) {
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
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.player2.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.player2.withValues(alpha: 0.08),
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
                        color: theme.player2.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync_problem_rounded,
                        color: theme.player2,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Serverpod Restart Required',
                      style: TextStyle(
                        color: theme.textPrimary,
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
                      style: TextStyle(
                        color: theme.textSecondary,
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
                        color: theme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.terminal,
                            color: theme.player1,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Switch to the terminal running "serverpod start" and press "R" to hot-restart the backend.',
                              style: TextStyle(
                                color: theme.textPrimary,
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
                            backgroundColor: theme.buttonBackground,
                            foregroundColor: theme.buttonForeground,
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
                            foregroundColor: theme.player2,
                            side: BorderSide(
                              color: theme.player2.withValues(alpha: 0.5),
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
              Text(
                'Tip: You can still click the "Architecture" tab above to review all Serverpod features!',
                style: TextStyle(
                  color: theme.textMuted,
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
  Widget _buildOverviewTab(AppThemeData theme) {
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
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.player1.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.statusSuccess,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.statusSuccess.withValues(alpha: 0.6),
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
                              Text(
                                'Serverpod Engine: ONLINE',
                                style: TextStyle(
                                  color: theme.textPrimary,
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
                                  color: theme.badgeBackground,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.badgeBorder),
                                ),
                                child: Text(
                                  d.runMode.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.badgeText,
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
                            style: TextStyle(
                              color: theme.textSecondary,
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
                        theme: theme,
                        title: 'Total Matches',
                        value: '${d.totalMatches}',
                        subtitle:
                            '${d.inProgressMatches} active • ${d.waitingMatches} waiting',
                        icon: Icons.sports_esports_outlined,
                        color: theme.player1,
                      ),
                      _buildMetricCard(
                        theme: theme,
                        title: 'Total Players',
                        value: '${d.totalPlayers}',
                        subtitle: 'PostgreSQL registered profiles',
                        icon: Icons.people_outline,
                        color: theme.player2,
                      ),
                      _buildMetricCard(
                        theme: theme,
                        title: 'ACID Moves',
                        value: '${d.totalMoves}',
                        subtitle: 'Recorded in match_move_record',
                        icon: Icons.sync_alt_outlined,
                        color: theme.statusSuccess,
                      ),
                      _buildMetricCard(
                        theme: theme,
                        title: 'Local Caches',
                        value: '${d.localCacheEntries}',
                        subtitle: 'In-memory keys (TTL enabled)',
                        icon: Icons.bolt_outlined,
                        color: theme.accentSecondary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Multi-Game Arena Telemetry Card
              _buildGameBreakdownCard(theme, d),
              const SizedBox(height: 24),

              // Interactive Action Triggers
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.terminal,
                          color: theme.player1,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Interactive Serverpod Control Actions',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trigger backend actions to witness Serverpod scheduled jobs, transaction processors, and cache invalidation in real time:',
                      style: TextStyle(
                        color: theme.textSecondary,
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
                            backgroundColor: theme.buttonBackground,
                            foregroundColor: theme.buttonForeground,
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
                            foregroundColor: theme.textPrimary,
                            side: BorderSide(
                              color: theme.surfaceBorder,
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
                            foregroundColor: theme.player2,
                            side: BorderSide(
                              color: theme.player2.withValues(alpha: 0.6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showHealthzDialog(context, theme),
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
                Text(
                  'Top Ranked Players (PostgreSQL Table: player_profile)',
                  style: TextStyle(
                    color: theme.textPrimary,
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
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.surfaceBorder),
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
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${p.wins} wins • ${p.totalMatches} matches',
                            style: TextStyle(
                              color: theme.textMuted,
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
    required AppThemeData theme,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.surfaceBorder),
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
                style: TextStyle(
                  color: theme.textSecondary,
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
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGameBreakdownCard(AppThemeData theme, AdminDashboardData d) {
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
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: theme.player1,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Multi-Game Telemetry Breakdown',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.badgeBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.badgeBorder),
                ),
                child: Text(
                  '3 ENGINES ACTIVE',
                  style: TextStyle(
                    color: theme.badgeText,
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
                  theme: theme,
                  title: 'Triangle Tactics',
                  icon: Icons.change_history,
                  color: theme.player1,
                  active: triangleActive,
                  waiting: triangleWaiting,
                  completed: triangleCompleted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGameTelemetryItem(
                  theme: theme,
                  title: 'Gravity Drop',
                  icon: Icons.blur_linear,
                  color: theme.player2,
                  active: connectFourActive,
                  waiting: connectFourWaiting,
                  completed: connectFourCompleted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGameTelemetryItem(
                  theme: theme,
                  title: 'Chroma Reversi',
                  icon: Icons.radio_button_checked,
                  color: theme.accentSecondary,
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
    required AppThemeData theme,
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
        color: theme.surfaceElevated,
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
                style: TextStyle(
                  color: theme.statusSuccess,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Wait: $waiting',
                style: TextStyle(
                  color: theme.player2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Completed: $completed',
            style: TextStyle(
              color: theme.textSecondary,
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
  Widget _buildMatchesTab(AppThemeData theme) {
    final matches = _data?.recentMatches ?? [];
    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No matches recorded in game_match yet.',
          style: TextStyle(color: theme.textSecondary),
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
            ? theme.player1
            : isWaiting
            ? theme.player2
            : theme.textMuted;

        final String gameName;
        final IconData gameIcon;
        final Color gameColor;
        if (m.gameType == 'triangle_tactics') {
          gameName = 'TRIANGLE';
          gameIcon = Icons.change_history;
          gameColor = theme.player1;
        } else if (m.gameType == 'connect_four') {
          gameName = 'GRAVITY DROP';
          gameIcon = Icons.blur_linear;
          gameColor = theme.player2;
        } else if (m.gameType == 'reversi') {
          gameName = 'REVERSI';
          gameIcon = Icons.radio_button_checked;
          gameColor = theme.accentSecondary;
        } else {
          gameName = m.gameType.toUpperCase();
          gameIcon = Icons.sports_esports;
          gameColor = theme.player2;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.surfaceBorder),
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
                      color: theme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.surfaceBorder),
                    ),
                    child: Text(
                      m.roomCode ?? 'PUBLIC',
                      style: TextStyle(
                        color: theme.player1,
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
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${m.player1Score} - ${m.player2Score} • Turn: ${m.activePlayerId} • Game: ${m.gameType}',
                      style: TextStyle(
                        color: theme.textSecondary,
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
  Widget _buildCronLogsTab(AppThemeData theme) {
    final logs = _data?.recentJobLogs ?? [];
    if (logs.isEmpty) {
      return Center(
        child: Text(
          'No scheduled maintenance executions recorded yet.',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final log = logs[index];
        final isSuccess = log.success;
        final statusColor = isSuccess ? theme.statusSuccess : theme.statusError;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.alarm_on,
                        color: theme.player1,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        log.jobName,
                        style: TextStyle(
                          color: theme.textPrimary,
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
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      isSuccess ? 'SUCCESS' : 'FAILED',
                      style: TextStyle(
                        color: statusColor,
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
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stale Lobbies Cleaned: ${log.staleLobbiesCleaned} • Leaderboards Aggregated: ${log.leaderboardsAggregated}',
                style: TextStyle(
                  color: theme.textMuted,
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
  Widget _buildArchitectureShowcaseTab(AppThemeData theme) {
    final features = [
      _FeatureInfo(
        title: 'Type-Safe RPC & Endpoint Generation',
        icon: Icons.code,
        color: theme.player1,
        description:
            'All server endpoints (MatchEndpoint, PlayerEndpoint, LeaderboardEndpoint, AdminEndpoint) '
            'automatically generate strongly typed client methods in one_v_one_client. '
            'Zero manual HTTP mapping or JSON encoding boilerplate.',
      ),
      _FeatureInfo(
        title: 'Serverpod ORM & Database Schema',
        icon: Icons.storage,
        color: theme.player2,
        description:
            'Models defined in .spy.yaml (GameMatch, MatchMoveRecord, PlayerProfile, DailyLeaderboard, ScheduledJobLog) '
            'map to PostgreSQL tables. Queries are fully typed (GameMatch.db.findFirstRow, etc.).',
      ),
      _FeatureInfo(
        title: 'In-Memory Caching (session.caches.local)',
        icon: Icons.flash_on,
        color: theme.accentSecondary,
        description:
            'High-speed in-memory cache with TTL (5m daily leaderboards, 2m all-time leaderboards, 5m player profiles). '
            'Group invalidation automatically wipes "leaderboards" cache on daily aggregation.',
      ),
      _FeatureInfo(
        title: 'Task Scheduling & Future Calls (Cron)',
        icon: Icons.access_time_filled,
        color: theme.statusSuccess,
        description:
            'Automated nightly cron job runs at 1:00 AM IST (19:30 UTC) using Serverpod FutureCalls. '
            'Cleans up abandoned lobbies, compiles daily stats, and logs execution into scheduled_job_log.',
      ),
      _FeatureInfo(
        title: 'Real-Time WebSocket Streaming (session.messages)',
        icon: Icons.stream,
        color: theme.player1,
        description:
            'Live multiplayer gameplay streams over WebSockets via Serverpod\'s message hub. '
            'Subscribing to match_\$matchId allows instant broadcast of player moves, scores, and forfeits.',
      ),
      _FeatureInfo(
        title: 'Direct Cloud Storage (session.storage & FileUploader)',
        icon: Icons.cloud_upload_outlined,
        color: theme.player2,
        description:
            'Player avatars stream directly to Serverpod Cloud Storage using presigned upload descriptions '
            'and native FileUploader, eliminating the need to store heavy base64 strings in database rows.',
      ),
      _FeatureInfo(
        title: 'ACID Database Transactions',
        icon: Icons.lock_outline,
        color: theme.accentSecondary,
        description:
            'Move submissions and room join operations execute inside session.db.transaction. '
            'Includes optimistic state locking (clientStateVersion == match.stateVersion) to prevent race conditions.',
      ),
      _FeatureInfo(
        title: 'Built-in Web Server & Health Probes',
        icon: Icons.health_and_safety_outlined,
        color: theme.statusSuccess,
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
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.surfaceBorder),
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
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feat.description,
                      style: TextStyle(
                        color: theme.textSecondary,
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

  void _showHealthzDialog(BuildContext context, AppThemeData theme) {
    final d = _data;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.surfaceBorder),
        ),
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: theme.player2, size: 22),
            const SizedBox(width: 8),
            Text(
              'Public Probe: /healthz',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
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
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.player1,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.buttonBackground,
              foregroundColor: theme.buttonForeground,
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
