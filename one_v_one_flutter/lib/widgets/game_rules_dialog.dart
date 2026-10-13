import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class GameRulesDialog extends ConsumerStatefulWidget {
  const GameRulesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GameRulesDialog(),
    );
  }

  @override
  ConsumerState<GameRulesDialog> createState() => _GameRulesDialogState();
}

class _GameRulesDialogState extends ConsumerState<GameRulesDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);

    return Dialog(
      backgroundColor: theme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.surfaceBorder, width: 1.2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 560,
          maxHeight: 680,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.player1.withValues(alpha: 0.25),
                          theme.player2.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.player1.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.change_history,
                      color: theme.player1,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Play Triangle Tactics',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Game Rules, Controls & Strategy Guide',
                          style: TextStyle(
                            color: theme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.textMuted,
                      size: 20,
                    ),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.surfaceBorder),

            // Tab Bar
            Container(
              color: theme.surfaceElevated.withValues(alpha: 0.4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: theme.player1,
                indicatorWeight: 2.5,
                labelColor: theme.player1,
                unselectedLabelColor: theme.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.flash_on, size: 16), text: 'Overview'),
                  Tab(icon: Icon(Icons.linear_scale, size: 16), text: 'Bands'),
                  Tab(icon: Icon(Icons.category, size: 16), text: 'Conquering'),
                  Tab(icon: Icon(Icons.radar, size: 16), text: 'Strategy'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(theme),
                  _buildBandsTab(theme),
                  _buildConqueringTab(theme),
                  _buildStrategyTab(theme),
                ],
              ),
            ),

            Divider(height: 1, color: theme.surfaceBorder),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Triggle-inspired 1v1 Arena',
                      style: TextStyle(
                        color: theme.textMuted.withValues(alpha: 0.8),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonBackground,
                      foregroundColor: theme.buttonForeground,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Got It, Let\'s Play!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          theme: theme,
          icon: Icons.emoji_events_outlined,
          iconColor: theme.player2,
          title: 'The Goal: Conquer More Triangles',
          description:
              'Triangle Tactics is a fast-paced 1v1 territory strategy game. Two players take turns placing elastic bands on a hexagonal lattice. Your goal is to capture the most triangular territories before all moves are exhausted.',
        ),
        const SizedBox(height: 14),
        Text(
          'QUICK RULES AT A GLANCE',
          style: TextStyle(
            color: theme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildStepTile(
          theme: theme,
          step: '1',
          title: 'Take Turns',
          text:
              'Players alternate turns placing 1 rubber band on the lattice board.',
        ),
        _buildStepTile(
          theme: theme,
          step: '2',
          title: 'Span 4 Pegs in a Straight Line',
          text:
              'Every band must stretch straight across exactly 4 consecutive pegs.',
        ),
        _buildStepTile(
          theme: theme,
          step: '3',
          title: 'Complete Triangles',
          text:
              'Whenever your band forms the 3rd and final edge of a triangle, you conquer it!',
        ),
        _buildStepTile(
          theme: theme,
          step: '4',
          title: 'Earn Bonus Turns',
          text:
              'Conquering one or more triangles immediately awards you an extra bonus turn!',
        ),
        const SizedBox(height: 12),
        _buildTipBox(
          theme: theme,
          text:
              '💡 Tip: Chaining multiple conquests in a row can swing the game dramatically! Plan your lines ahead.',
        ),
      ],
    );
  }

  Widget _buildBandsTab(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          theme: theme,
          icon: Icons.alt_route,
          iconColor: theme.player1,
          title: 'The 4-Peg Straight Line Rule',
          description:
              'Unlike simple connect-the-dots games, every rubber band in Triangle Tactics must span exactly 4 pegs in a collinear line (a single continuous band line).',
        ),
        const SizedBox(height: 14),
        Text(
          'HOW TO PLACE BANDS',
          style: TextStyle(
            color: theme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.touch_app_outlined,
          title: 'Option A: Drag & Snap',
          description:
              'Touch/click a starting peg and drag your finger or mouse across the board. The rubber band will stretch and snap to valid 4-peg endpoint targets.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.ads_click,
          title: 'Option B: Tap to Select, Tap Target',
          description:
              'Tap a peg once to highlight it. The game will illuminate glowing target beacons at all legal straight-line endpoints. Tap any glowing beacon to lock the band in.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.block,
          title: 'No Duplicate Bands',
          description:
              'Once a band is placed between two 4-peg endpoints, that specific line cannot be placed again. However, bands can freely intersect across each other!',
        ),
        const SizedBox(height: 14),
        _buildTipBox(
          theme: theme,
          text:
              '🎯 Tip: Every band you place fills 3 adjacent segment edges on the board simultaneously. Look at all triangles touched by the path!',
        ),
      ],
    );
  }

  Widget _buildConqueringTab(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          theme: theme,
          icon: Icons.change_history,
          iconColor: theme.player1,
          title: 'Conquering & 3D Pegs',
          description:
              'Every triangle on the board is bounded by 3 perimeter edges. When your rubber band placement closes the 3rd missing edge, you claim that territory!',
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.palette_outlined,
          title: 'Territory Claim & Colored Token',
          description:
              'The triangle lights up in your player color, and your 3D molded token drops into the central socket with a celebratory bounce!',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.bolt,
          title: '⚡ Instant Bonus Turn',
          description:
              'Capturing one or more triangles immediately awards you another turn! You keep placing bands as long as you continue completing triangles.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.filter_2,
          title: 'Multi-Capture Combos',
          description:
              'A single placed rubber band can slice through the board and conquer TWO triangles at the exact same moment! You earn +2 points and an extra turn.',
        ),
        const SizedBox(height: 14),
        _buildTipBox(
          theme: theme,
          text:
              '🔥 Pro Strategy: Avoid giving your opponent 2-edge triangles. If you leave a triangle with 2 edges, your opponent can easily snap the 3rd edge on their turn!',
        ),
      ],
    );
  }

  Widget _buildStrategyTab(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          theme: theme,
          icon: Icons.radar,
          iconColor: theme.statusWarning,
          title: 'In-Game Tactical Threat Radar',
          description:
              'While dragging or aiming a rubber band, the live Tactical Threat Radar automatically analyzes the future board state and highlights critical outcomes:',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.player1.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.player1.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: theme.player1,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Glowing Player Color (Victory Capture)',
                      style: TextStyle(
                        color: theme.player1,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Indicates that this move will complete the 3rd edge of a triangle and conquer it immediately for you!',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.statusWarning.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.statusWarning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.statusWarning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Warning (Alert Indicator)',
                      style: TextStyle(
                        color: theme.statusWarning,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Alerts you that this move leaves a triangle with 2 edges completed — handing an easy capture to your opponent on their very next turn!',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MATCH RULES & FAIR PLAY',
          style: TextStyle(
            color: theme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.timer_outlined,
          title: '30-Second Turn Timer',
          description:
              'Each move has a 30-second countdown timer. If your timer reaches 0, you forfeit the match and victory is awarded to your opponent.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.flag_outlined,
          title: 'Resignation & Forfeits',
          description:
              'Leaving or backing out of an ongoing match forfeits the game to your opponent. You will be prompted with a confirmation dialog before resigning.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          theme: theme,
          icon: Icons.military_tech_outlined,
          title: 'End of Game & Winner',
          description:
              'The match concludes when all valid rubber bands have been placed. The player with the highest total captured triangles wins the match!',
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required AppThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
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

  Widget _buildStepTile({
    required AppThemeData theme,
    required String step,
    required String title,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.badgeBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.badgeBorder,
              ),
            ),
            child: Text(
              step,
              style: TextStyle(
                color: theme.badgeText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required AppThemeData theme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox({
    required AppThemeData theme,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.badgeBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.badgeBorder),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.badgeText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}
