import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../client.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const SignInScreen({super.key, this.child});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SignInScreen(),
    );
  }

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _callsignController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _callsignController.text = ref.read(playerProfileProvider).displayName;
  }

  @override
  void dispose() {
    _callsignController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProfileProvider);

    // If used as a wrapper widget and user is authenticated, render child
    if (widget.child != null && playerState.isAuthenticated) {
      return widget.child!;
    }

    ref.listen<PlayerProfileState>(playerProfileProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    final content = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Icon(
                        playerState.isAuthenticated
                            ? Icons.verified_user_outlined
                            : Icons.lock_outline,
                        color: playerState.isAuthenticated
                            ? AppColors.player1
                            : AppColors.player2,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerState.isAuthenticated
                                ? 'Player Profile'
                                : 'Sign In or Register',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            playerState.isAuthenticated
                                ? 'Your authenticated player identity and career records'
                                : 'Sign in or create an account to save matches and rank on leaderboards',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.surfaceBorder, height: 1),

              // Body: Authenticated Profile vs Authentication Flow
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: playerState.isAuthenticated
                      ? _buildAuthenticatedProfileView(playerState)
                      : _buildAuthenticationView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.child != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: content),
      );
    }
    return content;
  }

  // 1. Authentication Flow (Built-in Auth IDP Component)
  Widget _buildAuthenticationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignInWidget(
          client: client,
          onAuthenticated: () async {
            await ref.read(playerProfileProvider.notifier).refreshProfile();
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Authentication error: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Authenticated Profile View (Mapped to auth user records)
  Widget _buildAuthenticatedProfileView(PlayerProfileState state) {
    final profile = state.profile;
    final totalMatches = profile?.totalMatches ?? 0;
    final wins = profile?.wins ?? 0;
    final losses = profile?.losses ?? 0;
    final triangles = profile?.trianglesCaptured ?? 0;
    final winRate = totalMatches > 0
        ? ((wins / totalMatches) * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verified Player Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.player1.withValues(alpha: 0.2),
                child: Text(
                  state.displayName.isNotEmpty
                      ? state.displayName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    color: AppColors.player1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          color: AppColors.player1,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account ID: ${state.playerId}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Callsign Editor
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _callsignController,
                decoration: InputDecoration(
                  hintText: 'Edit your callsign',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.surfaceBorder,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.player1,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onPressed: () async {
                final newName = _callsignController.text.trim();
                if (newName.isNotEmpty) {
                  await ref
                      .read(playerProfileProvider.notifier)
                      .updateDisplayName(newName);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Career Statistics Matrix
        const Text(
          'CAREER STATISTICS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard('Matches', '$totalMatches', AppColors.textPrimary),
            const SizedBox(width: 8),
            _buildStatCard('Wins', '$wins', AppColors.player1),
            const SizedBox(width: 8),
            _buildStatCard('Losses', '$losses', AppColors.player2),
            const SizedBox(width: 8),
            _buildStatCard('Win %', '$winRate%', AppColors.success),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.change_history,
                    color: AppColors.player1,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Triangles Captured',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                '$triangles',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Sign Out Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: state.isLoading
              ? null
              : () async {
                  await ref.read(playerProfileProvider.notifier).signOut();
                },
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
