import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart';
import 'lobby_screen.dart';

class GameCatalogueScreen extends ConsumerWidget {
  const GameCatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Game Catalogue',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'ACTIVE TITLES',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Triangle Tactics (Playable)
          _buildGameCard(
            title: 'Triangle Tactics',
            tagline: 'Territory Strategy on a Triangular Lattice',
            description:
                'Connect discrete lattice nodes with lines to complete elementary triangular faces. Every triangle captured awards points and grants an immediate extra turn.',
            isPlayable: true,
            accentColor: AppColors.player1,
            badge: 'PLAYABLE NOW',
            icon: Icons.change_history,
            onPlay: () async {
              await ref.read(matchProvider.notifier).playOnline(boardSize: 4);
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
          const SizedBox(height: 24),

          const Text(
            'COMING SOON',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Future Titles
          _buildGameCard(
            title: 'Tic-Tac-Toe Duel',
            tagline: 'Classic 3x3 Deterministic Grid Match',
            description:
                'Turn-based alignment strategy. First to align 3 consecutive marks takes the round.',
            isPlayable: false,
            accentColor: Colors.purpleAccent,
            badge: 'COMING SOON',
            icon: Icons.grid_3x3,
          ),
          const SizedBox(height: 12),

          _buildGameCard(
            title: 'Connect Four',
            tagline: 'Vertical Gravity Drop Tactics',
            description:
                'Drop discs into columns to form vertical, horizontal, or diagonal quadruples.',
            isPlayable: false,
            accentColor: Colors.blueAccent,
            badge: 'COMING SOON',
            icon: Icons.blur_linear,
          ),
          const SizedBox(height: 12),

          _buildGameCard(
            title: 'Memory Duel',
            tagline: 'Simultaneous Grid Recall',
            description:
                'Reveal tiles to find matched pairs in real time with quick combo bonuses.',
            isPlayable: false,
            accentColor: Colors.tealAccent,
            badge: 'COMING SOON',
            icon: Icons.psychology_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String tagline,
    required String description,
    required bool isPlayable,
    required Color accentColor,
    required String badge,
    required IconData icon,
    VoidCallback? onPlay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayable
              ? accentColor.withValues(alpha: 0.4)
              : AppColors.surfaceBorder,
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
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
                      : AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isPlayable ? accentColor : AppColors.textMuted,
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (isPlayable) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPlay,
              child: const Text(
                'Play Triangle Tactics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
