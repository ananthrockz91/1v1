import 'package:flutter/material.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../theme/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
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
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _triggerMaintenance() async {
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
          const SnackBar(
            content: Text('Leaderboard updated via daily maintenance process!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Rankings & Leaderboards',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      'all',
                      'ALL GAMES (OVERALL)',
                      Icons.public,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      'triangle_tactics',
                      'TRIANGLE TACTICS',
                      Icons.change_history,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      'connect_four',
                      'GRAVITY DROP',
                      Icons.blur_linear,
                    ),
                    const SizedBox(width: 8),
                    _buildGameFilterChip(
                      'reversi',
                      'CHROMA REVERSI',
                      Icons.radio_button_checked,
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.player1,
                labelColor: AppColors.player1,
                unselectedLabelColor: AppColors.textMuted,
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.player1),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyTab(),
                    _buildAllTimeTab(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.teal),
                ),
              ),
              icon: const Icon(Icons.bolt, size: 18),
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

  Widget _buildDailyTab() {
    if (_dailyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'No matches aggregated for today yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.player1,
                foregroundColor: Colors.black,
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

  Widget _buildAllTimeTab() {
    if (_allTimeList.isEmpty) {
      return const Center(
        child: Text(
          'No players registered yet.',
          style: TextStyle(color: AppColors.textSecondary),
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
    required int rank,
    required String name,
    required int wins,
    required int losses,
    required int draws,
    required int triangles,
    required double winRate,
  }) {
    Color rankColor = AppColors.textMuted;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = const Color(0xFFC0C0C0);
    if (rank == 3) rankColor = const Color(0xFFCD7F32);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3
              ? rankColor.withValues(alpha: 0.3)
              : AppColors.surfaceBorder,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$wins W • $losses L • $draws D  (${winRate.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
                style: const TextStyle(
                  color: AppColors.player1,
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
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameFilterChip(String gameType, String label, IconData icon) {
    final isSelected = _selectedGameType == gameType;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _onGameFilterChanged(gameType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.player1.withValues(alpha: 0.2)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.player1 : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.player1 : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.player1 : AppColors.textSecondary,
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
