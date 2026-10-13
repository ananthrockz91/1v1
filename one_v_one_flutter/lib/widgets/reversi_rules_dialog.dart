import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class ReversiRulesDialog extends ConsumerWidget {
  const ReversiRulesDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReversiRulesDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.surfaceBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.radio_button_checked,
                      color: theme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chroma Reversi Rules',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Brisk Flanking & Mind Strategy',
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
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildRuleCard(
                      theme: theme,
                      icon: Icons.track_changes,
                      title: '1. The Flanking Rule',
                      content:
                          'Place a disk on an empty square such that you trap one or more opponent disks in a straight line (horizontal, vertical, or diagonal) between your new disk and an existing disk of your color.',
                    ),
                    const SizedBox(height: 12),
                    _buildRuleCard(
                      theme: theme,
                      icon: Icons.flip_camera_android,
                      title: '2. Cascade Disk Flipping',
                      content:
                          'All opponent disks bounded in every flanked direction are converted and flipped to your color. Every move must flank at least one disk.',
                    ),
                    const SizedBox(height: 12),
                    _buildRuleCard(
                      theme: theme,
                      icon: Icons.fast_forward,
                      title: '3. Automatic Pass',
                      content:
                          'If you have no valid moves on your turn, your turn is forfeited and automatically passed to your opponent. If neither player has a valid move, the match concludes.',
                    ),
                    const SizedBox(height: 12),
                    _buildRuleCard(
                      theme: theme,
                      icon: Icons.star_border_purple500,
                      title: '4. Corner & Edge Dominance',
                      content:
                          'Corner squares (0,0), (0,7), (7,0), (7,7) can NEVER be flipped once claimed. Secure corners early to lock down surrounding edges.',
                    ),
                    const SizedBox(height: 12),
                    _buildRuleCard(
                      theme: theme,
                      icon: Icons.emoji_events_outlined,
                      title: '5. Victory Condition',
                      content:
                          'When the board is filled or neither player can make a move, the player with the most disks of their color wins the duel.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonBackground,
                    foregroundColor: theme.buttonForeground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Got It — Ready to Duel!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required AppThemeData theme,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.accentSecondary, size: 20),
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
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
  }
}
