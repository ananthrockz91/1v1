import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../client.dart';
import '../providers/match_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/player_avatar.dart';
import 'admin_board_screen.dart';
import 'game_catalogue_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'sign_in_screen.dart';
import 'triangle_tactics_hub_screen.dart';
import 'connect_four_hub_screen.dart';
import '../widgets/architecture_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _roomCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeepLinkRoomCode();
    });
  }

  void _checkDeepLinkRoomCode() {
    if (!kIsWeb) return;
    try {
      final roomParam = Uri.base.queryParameters['room']?.trim().toUpperCase();
      if (roomParam != null && roomParam.length == 6) {
        _roomCodeController.text = roomParam;
        _showJoinDialog();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
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
          'Please sign in or create an account to $action. It keeps your matches and stats saved across devices!',
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

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProfileProvider);
    final theme = ref.watch(currentThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header: Player Profile + Telemetry Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Player Profile Chip
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: playerState.isAuthenticated
                                  ? theme.accent.withValues(alpha: 0.6)
                                  : theme.surfaceBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  AvatarPickerSheet.show(
                                    context: context,
                                    initialSeed: playerState.avatarSeed,
                                    onSelected: (newSeed) {
                                      ref
                                          .read(playerProfileProvider.notifier)
                                          .updateAvatar(newSeed);
                                    },
                                  );
                                },
                                child: Stack(
                                  children: [
                                    PlayerAvatar(
                                      avatarSeed: playerState.avatarSeed,
                                      displayName: playerState.displayName,
                                      size: 26,
                                      borderColor: playerState.isAuthenticated
                                          ? AppColors.player1
                                          : AppColors.player2,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: const BoxDecoration(
                                          color: AppColors.surface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.photo_camera,
                                          size: 8,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => SignInScreen.show(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 80,
                                      ),
                                      child: Text(
                                        playerState.displayName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: playerState.isAuthenticated
                                            ? AppColors.player1.withValues(
                                                alpha: 0.15,
                                              )
                                            : AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        playerState.isAuthenticated
                                            ? 'VERIFIED'
                                            : 'GUEST',
                                        style: TextStyle(
                                          color: playerState.isAuthenticated
                                              ? AppColors.player1
                                              : AppColors.textMuted,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Platform Actions & Theme Switcher
                      Row(
                        children: [
                          // Theme Switcher Toggle Pill
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              ref.read(themeModeProvider.notifier).toggle();
                              final nextModeIsMono = !theme.isMonochrome;
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1400),
                                  backgroundColor: nextModeIsMono
                                      ? const Color(0xFF18181B)
                                      : const Color(0xFF131B2E),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: nextModeIsMono
                                          ? const Color(0xFF3F3F46)
                                          : const Color(0xFF14B8A6),
                                    ),
                                  ),
                                  content: Text(
                                    nextModeIsMono
                                        ? 'Switched to B&W Minimal Theme'
                                        : 'Switched to Teal Cyber Theme',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: theme.surfaceElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.isMonochrome
                                      ? const Color(0xFF3F3F46)
                                      : const Color(
                                          0xFF14B8A6,
                                        ).withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    theme.isMonochrome
                                        ? Icons.contrast_rounded
                                        : Icons.palette_outlined,
                                    size: 14,
                                    color: theme.accent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    theme.name,
                                    style: TextStyle(
                                      color: theme.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              Icons.memory_rounded,
                              color: theme.isMonochrome
                                  ? Colors.white70
                                  : AppColors.teal,
                              size: 20,
                            ),
                            tooltip: 'Serverpod Live Admin Board',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminBoardScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.hub_outlined,
                              color: theme.isMonochrome
                                  ? Colors.white70
                                  : AppColors.tealLight,
                              size: 20,
                            ),
                            tooltip: 'Serverpod Architecture & Cloud Specs',
                            onPressed: () => ArchitectureDialog.show(context),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.leaderboard_outlined,
                              color: theme.isMonochrome
                                  ? Colors.white70
                                  : Colors.amberAccent,
                              size: 20,
                            ),
                            tooltip: 'Leaderboards',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeaderboardScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Brand Hero Header (Both 1s are Teal in Teal mode; White in B&W mode)
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '1',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: theme.logoPrimary,
                                  letterSpacing: -2,
                                ),
                              ),
                              TextSpan(
                                text: 'v',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: theme.logoVs,
                                ),
                              ),
                              TextSpan(
                                text: '1',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: theme.logoSecondary,
                                  letterSpacing: -2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SELECT YOUR ARENA',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Game Touch Point 1: Triangle Tactics
                  _buildGameTouchPoint(
                    theme: theme,
                    title: 'Triangle Tactics',
                    tagline: 'Territory Strategy on a Triangular Lattice',
                    description:
                        'Span elastic bands straight across 4 pegs to complete triangles, capture territory, and trigger bonus turns.',
                    accentColor: AppColors.teal,
                    badge: 'POPULAR',
                    icon: Icons.change_history,
                    modes: const ['Online 1v1', 'Tactical AI', 'Pass & Play'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TriangleTacticsHubScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Game Touch Point 2: Gravity Drop Duel (Connect Four)
                  _buildGameTouchPoint(
                    theme: theme,
                    title: 'Gravity Drop Duel',
                    tagline: 'Connect Four: Vertical Column Tactics',
                    description:
                        'Drop neon discs down 7 columns obeying gravity physics. Align four consecutive discs to trigger the victory laser.',
                    accentColor: AppColors.tealLight,
                    badge: 'NEW TITLE',
                    icon: Icons.blur_linear,
                    modes: const [
                      'Minimax AI Bot',
                      'Pass & Play',
                      'Vector Guide',
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectFourHubScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Quick Join / Private Room Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.isMonochrome
                                ? const Color(0xFF27272A)
                                : AppColors.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.vpn_key_outlined,
                            color: theme.isMonochrome
                                ? Colors.white
                                : AppColors.tealLight,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Have a Private Room Code?',
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Join a 6-letter match code from a friend',
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.isMonochrome
                                ? const Color(0xFF27272A)
                                : theme.surface,
                            foregroundColor: theme.accent,
                            side: BorderSide(
                              color: theme.isMonochrome
                                  ? const Color(0xFF3F3F46)
                                  : AppColors.teal.withValues(alpha: 0.5),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (!ref
                                .read(playerProfileProvider)
                                .isAuthenticated) {
                              _showAuthPrompt(context, 'join a private room');
                              return;
                            }
                            _showJoinDialog();
                          },
                          child: const Text(
                            'Join Room',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Upcoming Titles Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UPCOMING TITLES',
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GameCatalogueScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Full Catalogue',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.isMonochrome
                                    ? Colors.white70
                                    : AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: theme.isMonochrome
                                  ? Colors.white70
                                  : AppColors.teal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Coming soon horizontal cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildUpcomingTile(
                          theme: theme,
                          title: 'Tic-Tac-Toe Duel',
                          accentColor: theme.isMonochrome
                              ? Colors.white70
                              : AppColors.teal,
                          icon: Icons.grid_3x3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildUpcomingTile(
                          theme: theme,
                          title: 'Memory Duel',
                          accentColor: theme.isMonochrome
                              ? Colors.white70
                              : AppColors.tealLight,
                          icon: Icons.psychology_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Footer Telemetry Bar
                  Center(
                    child: Text(
                      'Full-Stack Dart • Serverpod Cloud • Real-Time WebSockets',
                      style: TextStyle(
                        color: theme.textMuted.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTouchPoint({
    required AppThemeData theme,
    required String title,
    required String tagline,
    required String description,
    required Color accentColor,
    required String badge,
    required IconData icon,
    required List<String> modes,
    required VoidCallback onTap,
  }) {
    final effectiveAccent = theme.isMonochrome ? Colors.white : accentColor;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.isMonochrome
              ? const Color(0xFF27272A)
              : effectiveAccent.withValues(alpha: 0.35),
        ),
        boxShadow: theme.isMonochrome
            ? null
            : [
                BoxShadow(
                  color: effectiveAccent.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.isMonochrome
                                  ? const Color(0xFF18181B)
                                  : effectiveAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: theme.isMonochrome
                                  ? Border.all(color: const Color(0xFF3F3F46))
                                  : null,
                            ),
                            child: Icon(icon, color: effectiveAccent, size: 24),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  tagline,
                                  style: TextStyle(
                                    color: theme.isMonochrome
                                        ? theme.textSecondary
                                        : effectiveAccent.withValues(
                                            alpha: 0.85,
                                          ),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.badgeBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.badgeBorder),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: theme.badgeText,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Modes pills row + Enter button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: modes.map((mode) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.surfaceBorder,
                              ),
                            ),
                            child: Text(
                              mode,
                              style: TextStyle(
                                color: theme.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.buttonBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Play',
                            style: TextStyle(
                              color: theme.buttonForeground,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: theme.buttonForeground,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTile({
    required AppThemeData theme,
    required String title,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Coming Soon',
                  style: TextStyle(color: theme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
