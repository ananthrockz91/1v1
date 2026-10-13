import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class ConnectFourRulesDialog extends ConsumerWidget {
  const ConnectFourRulesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ConnectFourRulesDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      color: theme.accentSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.surfaceBorder,
                      ),
                    ),
                    child: Icon(
                      Icons.blur_linear,
                      color: theme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gravity Drop Duel — Strategy & Rules',
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Classic, Tactical & Grand Arena Grid Sizes',
                          style: TextStyle(
                            color: theme.textMuted,
                            fontSize: 11.5,
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

            // Rules Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHighlightCard(
                    theme: theme,
                    icon: Icons.emoji_events_outlined,
                    iconColor: theme.accent,
                    title: 'Objective: Connect Discs to Win',
                    description:
                        'Be the first player to form an unbroken horizontal, vertical, or diagonal streak of consecutive discs in your color (4 in Classic/Tactical, 5 in Grand Arena).',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ARENA GRID SIZES',
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
                    step: 'A',
                    title: 'Classic (7×6) — Connect 4',
                    text:
                        'The traditional 7-column by 6-row tournament grid. 42 total slots requiring 4-in-a-row to win.',
                  ),
                  _buildStepTile(
                    theme: theme,
                    step: 'B',
                    title: 'Tactical (8×7) — Connect 4',
                    text:
                        'Expanded 8-column battlefield offering deeper flanking routes and dual-center columns (Cols 3 & 4).',
                  ),
                  _buildStepTile(
                    theme: theme,
                    step: 'C',
                    title: 'Grand Arena (9×8) — Connect 5',
                    text:
                        'A vast 9-column arena featuring Gomoku-style 5-in-a-row alignment rules for massive tactical depth.',
                  ),
                  const SizedBox(height: 14),
                  _buildTipBox(
                    theme: theme,
                    text:
                        '⚡ Victory Laser: When a player achieves the required streak, a neon laser beam locks in across the winning discs with audio-visual fanfare.',
                  ),
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
                      'Deterministic Engine • AI Supported',
                      style: TextStyle(
                        color: theme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
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
                      'Ready to Duel',
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
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
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.accentSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.surfaceBorder),
            ),
            child: Text(
              step,
              style: TextStyle(
                color: theme.accent,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
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
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}
