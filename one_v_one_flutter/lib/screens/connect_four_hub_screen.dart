import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../client.dart';
import '../models/player_session.dart';
import '../theme/theme_provider.dart';
import '../widgets/connect_four_rules_dialog.dart';
import '../widgets/room_action_card.dart';
import 'connect_four_screen.dart';

class ConnectFourHubScreen extends ConsumerStatefulWidget {
  const ConnectFourHubScreen({super.key});

  @override
  ConsumerState<ConnectFourHubScreen> createState() =>
      _ConnectFourHubScreenState();
}

class _ConnectFourHubScreenState extends ConsumerState<ConnectFourHubScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isMatchmaking = false;
  bool _isCreatingRoom = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _startOnlineQuickMatch() async {
    setState(() => _isMatchmaking = true);
    try {
      final match = await client.match.findMatch(
        playerId: PlayerSession.currentId,
        gameType: 'connect_four',
        boardSize: 7,
      );
      if (!mounted) return;
      setState(() => _isMatchmaking = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectFourScreen(
            initialMode: ConnectFourMode.online,
            onlineMatch: match,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMatchmaking = false);
      final msg = e
          .toString()
          .replaceAll('ServerpodClientInternalServerError: ', '')
          .replaceAll('ServerpodClientException: ', '')
          .replaceAll('Exception: ', '')
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Matchmaking failed: $msg'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _createPrivateRoom() async {
    setState(() => _isCreatingRoom = true);
    try {
      final match = await client.match.createMatch(
        playerId: PlayerSession.currentId,
        gameType: 'connect_four',
        boardSize: 7,
        isPublic: false,
      );
      if (!mounted) return;
      setState(() => _isCreatingRoom = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectFourScreen(
            initialMode: ConnectFourMode.online,
            onlineMatch: match,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingRoom = false);
      final msg = e
          .toString()
          .replaceAll('ServerpodClientInternalServerError: ', '')
          .replaceAll('ServerpodClientException: ', '')
          .replaceAll('Exception: ', '')
          .trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create private room: $msg'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showJoinRoomDialog() {
    final theme = ref.read(currentThemeProvider);
    _roomCodeController.clear();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.surfaceBorder),
        ),
        title: Text(
          'Join Gravity Drop Duel',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 6-character room code to join an online duel:',
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomCodeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: TextStyle(
                color: theme.player1,
                letterSpacing: 4,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'ROOM CODE',
                hintStyle: TextStyle(
                  color: theme.textMuted,
                  letterSpacing: 2,
                ),
                filled: true,
                fillColor: theme.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.player1),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.buttonBackground,
              foregroundColor: theme.buttonForeground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final code = _roomCodeController.text.trim().toUpperCase();
              if (code.length == 6) {
                Navigator.pop(dialogCtx);
                try {
                  final match = await client.match.joinMatch(
                    playerId: PlayerSession.currentId,
                    roomCode: code,
                  );
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConnectFourScreen(
                        initialMode: ConnectFourMode.online,
                        onlineMatch: match,
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  final msg = e
                      .toString()
                      .replaceAll('ServerpodClientInternalServerError: ', '')
                      .replaceAll('ServerpodClientException: ', '')
                      .replaceAll('Exception: ', '')
                      .trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to join room "$code": $msg'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Join Duel',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
          'Gravity Drop Duel Hub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          if (showThemeSwitcher) ...[
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
          ],
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: theme.accent,
            ),
            tooltip: 'Rules & Vector Guide',
            onPressed: () => ConnectFourRulesDialog.show(context),
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
                            'VARIABLE ARENA GRIDS',
                            style: TextStyle(
                              color: theme.badgeText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => ConnectFourRulesDialog.show(context),
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
                      'Gravity Drop Duel',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Drop neon discs down custom arenas (Classic 7×6, Tactical 8×7, Grand 9×8 Connect-5). Duel online with players or practice vs AI!',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'SELECT PLAY MODE',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Mode 1: Play Online (Quick Match)
              _buildModeCard(
                theme: theme,
                icon: Icons.bolt_rounded,
                iconColor: theme.player1,
                title: 'Play Online (Quick Match)',
                subtitle:
                    'Automated matchmaking via Serverpod WebSockets streaming',
                badge: 'ONLINE 1V1',
                isLoading: _isMatchmaking,
                onTap: _isMatchmaking ? null : _startOnlineQuickMatch,
              ),
              const SizedBox(height: 12),

              // Mode 2: Play vs AI
              _buildModeCard(
                theme: theme,
                icon: Icons.smart_toy_outlined,
                iconColor: theme.player2,
                title: 'Solo vs AI (Tactical Bot)',
                subtitle:
                    'Challenge our minimax bot with intelligent defensive blocking',
                badge: 'OFFLINE / BOT',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectFourScreen(
                        initialMode: ConnectFourMode.vsAi,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Mode 3: Pass & Play
              _buildModeCard(
                theme: theme,
                icon: Icons.people_outline,
                iconColor: theme.accentSecondary,
                title: 'Pass & Play (Local 2-Player)',
                subtitle:
                    'Take turns dropping discs on the same screen with a friend',
                badge: 'LOCAL',
                onTap: () {
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
              const SizedBox(height: 20),

              // Private Match Rooms
              Text(
                'PRIVATE MATCH ROOMS',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: RoomActionCard(
                      theme: theme,
                      icon: Icons.add_circle_outline_rounded,
                      iconColor: theme.player2,
                      title: 'Create Room',
                      subtitle: 'Generate a 6-letter room code',
                      isLoading: _isCreatingRoom,
                      onTap: _isCreatingRoom ? null : _createPrivateRoom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RoomActionCard(
                      theme: theme,
                      icon: Icons.login_rounded,
                      iconColor: theme.accentSecondary,
                      title: 'Join Room',
                      subtitle: 'Enter an existing room code',
                      isLoading: false,
                      onTap: _showJoinRoomDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'GAME GUIDE & STRATEGY',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Strategy Guide Card
              ListTile(
                tileColor: theme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.surfaceBorder),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: theme.accent,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Rules, Vectors & Winning Tips',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Learn how to control column 3 and set up unblockable forks',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.textMuted,
                  size: 20,
                ),
                onTap: () => ConnectFourRulesDialog.show(context),
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
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
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
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: iconColor,
                          ),
                        )
                      : Icon(icon, color: iconColor, size: 24),
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
                              style: TextStyle(
                                color: theme.textPrimary,
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
                        isLoading ? 'Connecting to Serverpod...' : subtitle,
                        style: TextStyle(
                          color: isLoading ? iconColor : theme.textSecondary,
                          fontSize: 12,
                          fontWeight: isLoading
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.textMuted,
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
