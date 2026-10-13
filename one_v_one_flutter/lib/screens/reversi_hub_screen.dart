import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/reversi_rules_dialog.dart';
import 'reversi_screen.dart';

class ReversiHubScreen extends ConsumerStatefulWidget {
  const ReversiHubScreen({super.key});

  @override
  ConsumerState<ReversiHubScreen> createState() => _ReversiHubScreenState();
}

class _ReversiHubScreenState extends ConsumerState<ReversiHubScreen> {
  int _selectedAiDepth = 3;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chroma Reversi Arena',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
        actions: [
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
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: theme.accent,
            ),
            tooltip: 'Rules & Strategy',
            onPressed: () => ReversiRulesDialog.show(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.heroGradientStart,
                      theme.surfaceElevated,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.accent.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.badgeBackground,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.badgeBorder,
                            ),
                          ),
                          child: Text(
                            'NEW MIND GAME',
                            style: TextStyle(
                              color: theme.badgeText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.radio_button_checked,
                          color: theme.accent,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Chroma Reversi Duel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A minute to learn, a lifetime to master. Flank opponent disks in 8 directions, trigger cascade flips, and control key corner anchors to dominate the board.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Bot Difficulty Selector
              Container(
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
                          Icons.psychology_outlined,
                          color: theme.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tactical AI Engine Strength',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDifficultyChip(1, 'Apprentice', 'Depth 1'),
                        const SizedBox(width: 8),
                        _buildDifficultyChip(3, 'Tactician', 'Depth 3'),
                        const SizedBox(width: 8),
                        _buildDifficultyChip(4, 'Grandmaster', 'Depth 4'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mode 1: vs AI Bot
              _buildModeCard(
                theme: theme,
                icon: Icons.smart_toy_outlined,
                title: 'Play Tactical Bot',
                subtitle:
                    'Duel our heuristic minimax engine evaluated on positional corner dominance & mobility.',
                badge: 'SOLO / TRAINING',
                primary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReversiScreen(
                        initialMode: ReversiScreenMode.vsAi,
                        aiDepth: _selectedAiDepth,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Mode 2: Pass & Play
              _buildModeCard(
                theme: theme,
                icon: Icons.people_outline,
                title: 'Pass & Play Local Duel',
                subtitle:
                    'Share this device for offline head-to-head strategy with dual-color turn switches.',
                badge: 'LOCAL 1V1',
                primary: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReversiScreen(
                        initialMode: ReversiScreenMode.passAndPlay,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Rules Quick Launcher
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.accent,
                  side: BorderSide(
                    color: theme.accent.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text(
                  'View Flanking & Corner Strategy Guide',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () => ReversiRulesDialog.show(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(int depth, String label, String sub) {
    final isSelected = _selectedAiDepth == depth;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selectedAiDepth = depth),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.teal.withValues(alpha: 0.18)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.teal : AppColors.surfaceBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.tealLight
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: isSelected ? AppColors.teal : AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required AppThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary
              ? AppColors.teal.withValues(alpha: 0.4)
              : theme.surfaceBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : theme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primary ? AppColors.teal : theme.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: AppColors.tealLight,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
