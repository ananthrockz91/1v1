import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<MatchUiState>(matchProvider, (prev, next) {
      if (next.match?.status == 'in_progress') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      }
    });

    final matchState = ref.watch(matchProvider);
    final match = matchState.match;
    final isPublic = match?.isPublic == true;
    final roomCode = match?.roomCode ?? '------';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(matchProvider.notifier).clearMatch();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated waiting icon
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.player2.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.player2.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.player2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    isPublic
                        ? 'Searching for Opponent'
                        : 'Waiting for Opponent',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPublic
                        ? 'Waiting for another player to join public matchmaking...'
                        : 'Share this room code with your friend to connect and play',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Room Code Card (Private) or Public Queue Card
                  if (!isPublic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ROOM CODE',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            roomCode,
                            style: const TextStyle(
                              color: AppColors.player2,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                color: AppColors.surfaceBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Room Code'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: roomCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Room code copied to clipboard!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'PUBLIC 1V1 QUEUE',
                            style: TextStyle(
                              color: AppColors.player1,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Triangle Tactics (4x4)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Open a second browser tab or invite a peer to start playing instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ref.read(matchProvider.notifier).clearMatch();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel Matchmaking'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
