import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../theme/theme_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DailyLeaderboard> _dailyList = [];
  List<PlayerProfile> _allTimeList = [];
  bool _isLoading = true;
  String _selectedGameType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final daily = await client.leaderboard.getDailyLeaderboard(limit: 50);
      final gameLeaderboard = await client.leaderboard.getGameLeaderboard(
        gameType: _selectedGameType,
        limit: 50,
      );
      if (!mounted) return;
      setState(() {
        _dailyList = daily;
        _allTimeList = gameLeaderboard;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _triggerMaintenance() async {
    final theme = ref.read(currentThemeProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Executing scheduled maintenance aggregation...'),
      ),
    );
    try {
      await client.admin.triggerDailyMaintenance();
      await _loadData();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              'Leaderboard updated via daily maintenance process!',
            ),
            backgroundColor: theme.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.statusError,
          ),
        );
      }
    }
  }

  void _onGameFilterChanged(String gameType) {
    if (_selectedGameType == gameType) return;
    setState(() => _selectedGameType = gameType);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'Rankings & Leaderboards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Column(
            children: [
              // Horizontal Game Type Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    _buildGameFilterChip(
                      theme,
                      'all',
                      'ALL GAMES (OVERALL)',
                      Icons.public,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      theme,
                      'triangle_tactics',
                      'TRIANGLE TACTICS',
                      Icons.change_history,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      theme,
                      'connect_four',
                      'GRAVITY DROP',
                      Icons.blur_linear,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      theme,
                      'reversi',
                      'CHROMA REVERSI',
                      Icons.radio_button_checked,
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: theme.player1,
                labelColor: theme.player1,
                unselectedLabelColor: theme.textMuted,
                tabs: [
                  Tab(
                    text: _selectedGameType == 'all'
                        ? 'DAILY RANKINGS'
                        : 'ACTIVE STANDINGS',
                  ),
                  Tab(
                    text: _selectedGameType == 'all'
                        ? 'ALL-TIME LEGENDS'
                        : 'HALL OF FAME',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.player1),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyTab(theme),
                    _buildAllTimeTab(theme),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.surfaceBorder)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.surfaceElevated,
                foregroundColor: theme.accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: theme.accent),
                ),
              ),
              icon: Icon(Icons.bolt, size: 18, color: theme.accent),
              label: const Text(
                'Trigger Daily Processing Job (Demo)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _triggerMaintenance,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTab(AppThemeData theme) {
    if (_dailyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: theme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No matches aggregated for today yet.',
              style: TextStyle(color: theme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.buttonBackground,
                foregroundColor: theme.buttonForeground,
              ),
              onPressed: _triggerMaintenance,
              child: const Text('Aggregate Now'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _dailyList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = _dailyList[index];
        return _buildLeaderboardTile(
          theme: theme,
          rank: row.rank,
          name: row.displayName,
          wins: row.wins,
          losses: row.losses,
          draws: row.draws,
          triangles: row.trianglesCaptured,
          winRate: row.winRate,
        );
      },
    );
  }

  Widget _buildAllTimeTab(AppThemeData theme) {
    if (_allTimeList.isEmpty) {
      return Center(
        child: Text(
          'No players registered yet.',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _allTimeList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final profile = _allTimeList[index];
        final total = profile.wins + profile.losses + profile.draws;
        final winRate = total > 0 ? (profile.wins / total) * 100.0 : 0.0;

        return _buildLeaderboardTile(
          theme: theme,
          rank: index + 1,
          name: profile.displayName,
          wins: profile.wins,
          losses: profile.losses,
          draws: profile.draws,
          triangles: profile.trianglesCaptured,
          winRate: winRate,
        );
      },
    );
  }

  Widget _buildLeaderboardTile({
    required AppThemeData theme,
    required int rank,
    required String name,
    required int wins,
    required int losses,
    required int draws,
    required int triangles,
    required double winRate,
  }) {
    Color rankColor = theme.textMuted;
    if (rank == 1) {
      rankColor = theme.isMonochrome ? theme.textPrimary : Colors.amber;
    } else if (rank == 2) {
      rankColor = theme.isMonochrome
          ? theme.textSecondary
          : const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankColor = theme.isMonochrome
          ? theme.textMuted
          : const Color(0xFFCD7F32);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3
              ? rankColor.withValues(alpha: 0.3)
              : theme.surfaceBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$wins W • $losses L • $draws D  (${winRate.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$triangles',
                style: TextStyle(
                  color: theme.player1,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                _selectedGameType == 'reversi'
                    ? 'Disks'
                    : (_selectedGameType == 'connect_four'
                          ? 'Points'
                          : 'Triangles'),
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameFilterChip(
    AppThemeData theme,
    String gameType,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedGameType == gameType;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _onGameFilterChanged(gameType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.player1.withValues(alpha: 0.2)
              : theme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.player1 : theme.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? theme.player1 : theme.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.player1 : theme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
