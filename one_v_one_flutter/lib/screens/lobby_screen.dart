import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/match_provider.dart';
import '../theme/theme_provider.dart';
import 'connect_four_screen.dart';
import 'game_screen.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<MatchUiState>(matchProvider, (prev, next) {
      if (next.match?.status == 'in_progress') {
        if (next.match?.gameType == 'connect_four') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ConnectFourScreen(
                initialMode: ConnectFourMode.online,
                onlineMatch: next.match,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        }
      }
    });

    final theme = ref.watch(currentThemeProvider);
    final matchState = ref.watch(matchProvider);
    final match = matchState.match;
    final isPublic = match?.isPublic == true;
    final roomCode = match?.roomCode ?? '------';
    final baseOrigin = kIsWeb
        ? Uri.base.origin
        : 'https://onevone.serverpod.space';
    final inviteUrl = '$baseOrigin/?room=$roomCode';

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.textPrimary),
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
                        color: theme.player2.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.player2.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: theme.player2,
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
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPublic
                        ? 'Waiting for another player to join public matchmaking...'
                        : 'Share room code or QR code with a friend to play instantly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textSecondary,
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
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ROOM CODE',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            roomCode,
                            style: TextStyle(
                              color: theme.player2,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // QR Code Container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.player2.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: inviteUrl,
                              version: QrVersions.auto,
                              size: 150.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scan with phone camera to join instantly',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.textPrimary,
                                    side: BorderSide(
                                      color: theme.surfaceBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.copy, size: 15),
                                  label: const Text(
                                    'Copy Code',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: roomCode),
                                    );
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.buttonBackground,
                                    foregroundColor: theme.buttonForeground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.link_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Copy Link',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: inviteUrl),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Invite URL copied! Open in phone or another window.',
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'PUBLIC 1V1 QUEUE',
                            style: TextStyle(
                              color: theme.player1,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match?.gameType == 'connect_four'
                                ? 'Gravity Drop Duel (7×6)'
                                : 'Triangle Tactics (4x4)',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Open a second browser tab or invite a peer to start playing instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.statusError,
                      side: BorderSide(
                        color: theme.statusError.withValues(alpha: 0.5),
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
