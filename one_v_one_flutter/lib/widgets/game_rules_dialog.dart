import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GameRulesDialog extends StatefulWidget {
  const GameRulesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GameRulesDialog(),
    );
  }

  @override
  State<GameRulesDialog> createState() => _GameRulesDialogState();
}

class _GameRulesDialogState extends State<GameRulesDialog>
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
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.2),
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
                          AppColors.player1.withValues(alpha: 0.25),
                          AppColors.player2.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.player1.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.change_history,
                      color: AppColors.player1,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Play Triangle Tactics',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Game Rules, Controls & Strategy Guide',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceBorder),

            // Tab Bar
            Container(
              color: AppColors.surfaceElevated.withValues(alpha: 0.4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.player1,
                indicatorWeight: 2.5,
                labelColor: AppColors.player1,
                unselectedLabelColor: AppColors.textMuted,
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
                  _buildOverviewTab(),
                  _buildBandsTab(),
                  _buildConqueringTab(),
                  _buildStrategyTab(),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.surfaceBorder),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Triggle-inspired 1v1 Arena',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.player1,
                      foregroundColor: Colors.black,
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

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          icon: Icons.emoji_events_outlined,
          iconColor: AppColors.player2,
          title: 'The Goal: Conquer More Triangles',
          description:
              'Triangle Tactics is a fast-paced 1v1 territory strategy game. Two players take turns placing elastic bands on a hexagonal lattice. Your goal is to capture the most triangular territories before all moves are exhausted.',
        ),
        const SizedBox(height: 14),
        const Text(
          'QUICK RULES AT A GLANCE',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildStepTile(
          step: '1',
          title: 'Take Turns',
          text:
              'Players alternate turns placing 1 rubber band on the lattice board.',
        ),
        _buildStepTile(
          step: '2',
          title: 'Span 4 Pegs in a Straight Line',
          text:
              'Every band must stretch straight across exactly 4 consecutive pegs.',
        ),
        _buildStepTile(
          step: '3',
          title: 'Complete Triangles',
          text:
              'Whenever your band forms the 3rd and final edge of a triangle, you conquer it!',
        ),
        _buildStepTile(
          step: '4',
          title: 'Earn Bonus Turns',
          text:
              'Conquering one or more triangles immediately awards you an extra bonus turn!',
        ),
        const SizedBox(height: 12),
        _buildTipBox(
          '💡 Tip: Chaining multiple conquests in a row can swing the game dramatically! Plan your lines ahead.',
        ),
      ],
    );
  }

  Widget _buildBandsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          icon: Icons.alt_route,
          iconColor: AppColors.player1,
          title: 'The 4-Peg Straight Line Rule',
          description:
              'Unlike simple connect-the-dots games, every rubber band in Triangle Tactics must span exactly 4 pegs in a collinear line (a single continuous band line).',
        ),
        const SizedBox(height: 14),
        const Text(
          'HOW TO PLACE BANDS',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.touch_app_outlined,
          title: 'Option A: Drag & Snap',
          description:
              'Touch/click a starting peg and drag your finger or mouse across the board. The rubber band will stretch and snap to valid 4-peg endpoint targets.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.ads_click,
          title: 'Option B: Tap to Select, Tap Target',
          description:
              'Tap a peg once to highlight it. The game will illuminate glowing target beacons at all legal straight-line endpoints. Tap any glowing beacon to lock the band in.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.block,
          title: 'No Duplicate Bands',
          description:
              'Once a band is placed between two 4-peg endpoints, that specific line cannot be placed again. However, bands can freely intersect across each other!',
        ),
        const SizedBox(height: 14),
        _buildTipBox(
          '🎯 Tip: Every band you place fills 3 adjacent segment edges on the board simultaneously. Look at all triangles touched by the path!',
        ),
      ],
    );
  }

  Widget _buildConqueringTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          icon: Icons.change_history,
          iconColor: AppColors.player1,
          title: 'Conquering & 3D Pegs',
          description:
              'Every triangle on the board is bounded by 3 perimeter edges. When your rubber band placement closes the 3rd missing edge, you claim that territory!',
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          icon: Icons.palette_outlined,
          title: 'Territory Claim & Colored Token',
          description:
              'The triangle lights up in your player color (Cyan for P1, Amber for P2), and your 3D molded token drops into the central socket with a celebratory bounce!',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.bolt,
          title: '⚡ Instant Bonus Turn',
          description:
              'Capturing one or more triangles immediately awards you another turn! You keep placing bands as long as you continue completing triangles.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.filter_2,
          title: 'Multi-Capture Combos',
          description:
              'A single placed rubber band can slice through the board and conquer TWO triangles at the exact same moment! You earn +2 points and an extra turn.',
        ),
        const SizedBox(height: 14),
        _buildTipBox(
          '🔥 Pro Strategy: Avoid giving your opponent 2-edge triangles. If you leave a triangle with 2 edges, your opponent can easily snap the 3rd edge on their turn!',
        ),
      ],
    );
  }

  Widget _buildStrategyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHighlightCard(
          icon: Icons.radar,
          iconColor: Colors.orangeAccent,
          title: 'In-Game Tactical Threat Radar',
          description:
              'While dragging or aiming a rubber band, the live Tactical Threat Radar automatically analyzes the future board state and highlights critical outcomes:',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.player1.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.player1.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.player1,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Glowing Player Color (Victory Capture)',
                      style: TextStyle(
                        color: AppColors.player1,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Indicates that this move will complete the 3rd edge of a triangle and conquer it immediately for you!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orangeAccent.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orange Outline (Danger Warning)',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Alerts you that this move leaves a triangle with 2 edges completed — handing an easy capture to your opponent on their very next turn!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
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
        const Text(
          'MATCH RULES & FAIR PLAY',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.timer_outlined,
          title: '30-Second Turn Timer',
          description:
              'Each move has a 30-second countdown timer. If your timer reaches 0, you forfeit the match and victory is awarded to your opponent.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.flag_outlined,
          title: 'Resignation & Forfeits',
          description:
              'Leaving or backing out of an ongoing match forfeits the game to your opponent. You will be prompted with a confirmation dialog before resigning.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.military_tech_outlined,
          title: 'End of Game & Winner',
          description:
              'The match concludes when all valid rubber bands have been placed. The player with the highest total captured triangles wins the match!',
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
              color: AppColors.player1.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.player1.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.player1,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

  Widget _buildTipBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.player1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.player1.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.player1.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}
