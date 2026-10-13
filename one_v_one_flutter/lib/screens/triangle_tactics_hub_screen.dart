import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/game_rules_dialog.dart';
import '../widgets/architecture_dialog.dart';
import 'game_screen.dart';
import 'lobby_screen.dart';
import 'sign_in_screen.dart';

class TriangleTacticsHubScreen extends ConsumerStatefulWidget {
  const TriangleTacticsHubScreen({super.key});

  @override
  ConsumerState<TriangleTacticsHubScreen> createState() =>
      _TriangleTacticsHubScreenState();
}

class _TriangleTacticsHubScreenState
    extends ConsumerState<TriangleTacticsHubScreen> {
  final _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _showAuthPrompt(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.player1, size: 22),
            SizedBox(width: 8),
            Text(
              'Sign In Required',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Please sign in or create an account to $action. It only takes a few seconds and keeps your matches saved!',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              SignInScreen.show(context);
            },
            child: const Text(
              'Sign In / Register',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          'Join Private Match',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the 6-character room code shared by your opponent:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomCodeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                color: AppColors.player1,
                letterSpacing: 4,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ROOM CODE',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.player1),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final code = _roomCodeController.text.trim();
              if (code.length == 6) {
                Navigator.pop(dialogContext);
                await ref.read(matchProvider.notifier).joinPrivateMatch(code);
                if (!mounted) return;
                final match = ref.read(matchProvider).match;
                if (match != null && match.status == 'in_progress') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                }
              }
            },
            child: const Text(
              'Join Room',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
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
          'Triangle Tactics Hub',
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
            tooltip: 'Rules & Strategy Guide',
            onPressed: () => GameRulesDialog.show(context),
          ),
          IconButton(
            icon: Icon(
              Icons.hub_outlined,
              color: theme.isMonochrome ? Colors.white70 : Colors.cyanAccent,
            ),
            tooltip: 'Architecture Specs',
            onPressed: () => ArchitectureDialog.show(context),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.badgeBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.badgeBorder,
                            ),
                          ),
                          child: Text(
                            'HEXAGONAL LATTICE',
                            style: TextStyle(
                              color: theme.badgeText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => GameRulesDialog.show(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: theme.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Guide',
                                style: TextStyle(
                                  color: theme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Triangle Tactics',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Connect pegs with rubber bands straight across 4 pegs. Completing a triangular cell captures territory and awards an instant extra turn.',
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

              const Text(
                'SELECT PLAY MODE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Mode 1: Quick Online Match
              _buildModeCard(
                icon: Icons.bolt,
                iconColor: AppColors.player1,
                title: 'Play Online (Quick Match)',
                subtitle: 'Automated matchmaking via Serverpod WebSockets',
                badge: 'MULTIPLAYER',
                isLoading: matchState.isLoading,
                onTap: () async {
                  await ref.read(matchProvider.notifier).playOnline();
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
              const SizedBox(height: 12),

              // Mode 2: Play vs AI
              _buildModeCard(
                icon: Icons.smart_toy_outlined,
                iconColor: AppColors.player2,
                title: 'Solo vs AI (Tactical Bot)',
                subtitle: 'Offline practice against our strategic bot engine',
                badge: 'OFFLINE',
                onTap: () {
                  ref.read(matchProvider.notifier).startAiMatch();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Mode 3: Pass & Play
              _buildModeCard(
                icon: Icons.people_outline,
                iconColor: Colors.tealAccent,
                title: 'Pass & Play (Local 2-Player)',
                subtitle: 'Challenge a friend sitting with you on one device',
                badge: 'LOCAL',
                onTap: () {
                  ref.read(matchProvider.notifier).startLocalMatch();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'PRIVATE MATCH ROOMS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Private Rooms Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (!ref.read(playerProfileProvider).isAuthenticated) {
                          _showAuthPrompt(context, 'create a private room');
                          return;
                        }
                        await ref
                            .read(matchProvider.notifier)
                            .createPrivateMatch();
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LobbyScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.player2,
                        size: 20,
                      ),
                      label: const Text(
                        'Create Room',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!ref.read(playerProfileProvider).isAuthenticated) {
                          _showAuthPrompt(context, 'join a private room');
                          return;
                        }
                        _showJoinDialog();
                      },
                      icon: const Icon(
                        Icons.meeting_room_outlined,
                        color: AppColors.player1,
                        size: 20,
                      ),
                      label: const Text(
                        'Join Room',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.player1,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
