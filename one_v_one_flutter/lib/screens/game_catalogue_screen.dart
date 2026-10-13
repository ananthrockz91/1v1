import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../theme/theme_provider.dart';
import 'game_screen.dart';
import 'lobby_screen.dart';
import 'connect_four_screen.dart';
import 'reversi_screen.dart';
import '../widgets/game_rules_dialog.dart';
import '../widgets/connect_four_rules_dialog.dart';
import '../widgets/reversi_rules_dialog.dart';

class GameCatalogueScreen extends ConsumerWidget {
  const GameCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: Text(
          'Game Catalogue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'ACTIVE TITLES',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Triangle Tactics (Playable)
              _buildGameCard(
                theme: theme,
                title: 'Triangle Tactics',
                tagline: 'Territory Strategy on a Triangular Lattice',
                description:
                    'Connect discrete lattice nodes with lines to complete elementary triangular faces. Every triangle captured awards points and grants an immediate extra turn.',
                isPlayable: true,
                accentColor: theme.accent,
                badge: 'PLAYABLE NOW',
                icon: Icons.change_history,
                onRules: () => GameRulesDialog.show(context),
                onPlay: () async {
                  await ref
                      .read(matchProvider.notifier)
                      .playOnline(boardSize: 4);
                  if (!context.mounted) return;
                  final match = ref.read(matchProvider).match;
                  if (match == null) return;
                  if (match.status == 'in_progress') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LobbyScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Gravity Drop Duel (Playable)
              _buildGameCard(
                theme: theme,
                title: 'Gravity Drop Duel',
                tagline: 'Connect Four: 7x6 Column Alignment Tactics',
                description:
                    'Deterministic vertical drop strategy. Align four discs vertically, horizontally, or diagonally. Challenge our tactical minimax bot or battle locally in pass & play!',
                isPlayable: true,
                accentColor: theme.accentSecondary,
                badge: 'NEW TITLE',
                icon: Icons.blur_linear,
                playButtonText: 'Play vs AI Bot',
                onRules: () => ConnectFourRulesDialog.show(context),
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectFourScreen(
                        initialMode: ConnectFourMode.vsAi,
                      ),
                    ),
                  );
                },
                secondaryButtonText: 'Pass & Play',
                onSecondaryPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectFourScreen(
                        initialMode: ConnectFourMode.passAndPlay,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Chroma Reversi (Playable)
              _buildGameCard(
                theme: theme,
                title: 'Chroma Reversi',
                tagline: 'Othello Duel: Brisk Flanking & Cascade Flips',
                description:
                    'Rapid-paced 8x8 territorial mind game. Flank opponent discs along 8 directions to trigger cascading flips. Control the four corners to seal victory!',
                isPlayable: true,
                accentColor: theme.accent,
                badge: 'MIND STRATEGY',
                icon: Icons.radio_button_checked,
                playButtonText: 'Play vs AI Bot',
                onRules: () => ReversiRulesDialog.show(context),
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReversiScreen(
                        initialMode: ReversiScreenMode.vsAi,
                      ),
                    ),
                  );
                },
                secondaryButtonText: 'Pass & Play',
                onSecondaryPlay: () {
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
              const SizedBox(height: 24),

              Text(
                'COMING SOON',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Future Titles
              _buildGameCard(
                theme: theme,
                title: 'Tic-Tac-Toe Duel',
                tagline: 'Classic 3x3 Deterministic Grid Match',
                description:
                    'Turn-based alignment strategy. First to align 3 consecutive marks takes the round.',
                isPlayable: false,
                accentColor: theme.accentSecondary,
                badge: 'COMING SOON',
                icon: Icons.grid_3x3,
              ),
              const SizedBox(height: 12),

              _buildGameCard(
                theme: theme,
                title: 'Memory Duel',
                tagline: 'Simultaneous Grid Recall',
                description:
                    'Reveal tiles to find matched pairs in real time with quick combo bonuses.',
                isPlayable: false,
                accentColor: theme.accent,
                badge: 'COMING SOON',
                icon: Icons.psychology_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required AppThemeData theme,
    required String title,
    required String tagline,
    required String description,
    required bool isPlayable,
    required Color accentColor,
    required String badge,
    required IconData icon,
    String? playButtonText,
    String? secondaryButtonText,
    VoidCallback? onPlay,
    VoidCallback? onSecondaryPlay,
    VoidCallback? onRules,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayable
              ? accentColor.withValues(alpha: 0.4)
              : theme.surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPlayable
                      ? accentColor.withValues(alpha: 0.15)
                      : theme.surfaceBorder,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isPlayable ? accentColor : theme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tagline,
            style: TextStyle(
              color: accentColor.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (isPlayable) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onPlay,
                    child: Text(
                      playButtonText ?? 'Play $title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (onSecondaryPlay != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.6),
                        ),
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onSecondaryPlay,
                      child: Text(
                        secondaryButtonText ?? 'Pass & Play',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                if (onRules != null) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onRules,
                    icon: const Icon(Icons.help_outline_rounded, size: 16),
                    label: const Text('Rules'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
