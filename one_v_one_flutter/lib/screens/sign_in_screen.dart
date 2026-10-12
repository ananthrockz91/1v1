import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../client.dart';
import '../models/player_session.dart';
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

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Form Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Registration Form Controllers
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regCodeController = TextEditingController();

  // Guest Customization Controller
  final _guestNameController = TextEditingController();

  // Registration Step State
  bool _registrationStarted = false;
  UuidValue? _pendingRequestId;

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _guestNameController.text = PlayerSession.displayName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regNameController.dispose();
    _regCodeController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    setState(() {
      _loginEmailController.text = 'commander@1v1.game';
      _loginPasswordController.text = 'tacticsPass123!';
    });
  }

  void _fillDemoRegistration() {
    final randId = DateTime.now().millisecondsSinceEpoch % 10000;
    setState(() {
      _regEmailController.text = 'player$randId@1v1.game';
      _regPasswordController.text = 'tacticsPass123!';
      _regNameController.text = 'Commander_$randId';
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProfileProvider);

    // If wrapper mode and user is authenticated, render child
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
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                            : Icons.military_tech_outlined,
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
                                : 'Player Onboarding',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            playerState.isAuthenticated
                                ? 'Serverpod Cloud Authenticated'
                                : 'Zero-effort Guest play or Serverpod account',
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

              // If already authenticated: show profile view
              if (playerState.isAuthenticated)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildAuthenticatedProfileView(playerState),
                  ),
                )
              else ...[
                // Unauthenticated: Tabs for minimal effort onboarding
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.player1,
                  indicatorWeight: 3,
                  labelColor: AppColors.player1,
                  unselectedLabelColor: AppColors.textMuted,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.flash_on, size: 18),
                      text: 'Quick Guest',
                    ),
                    Tab(
                      icon: Icon(Icons.login, size: 18),
                      text: 'Sign In',
                    ),
                    Tab(
                      icon: Icon(Icons.person_add_outlined, size: 18),
                      text: 'Register',
                    ),
                    Tab(
                      icon: Icon(Icons.shield_outlined, size: 18),
                      text: 'Official Auth',
                    ),
                  ],
                ),
                Flexible(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuickGuestTab(playerState),
                      _buildSignInTab(playerState),
                      _buildRegisterTab(playerState),
                      _buildOfficialWidgetTab(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // If displayed inside another scaffold, wrap with Scaffold or return directly
    if (widget.child != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: content),
      );
    }
    return content;
  }

  // 1. Authenticated Profile View
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
                      'Player ID: ${state.playerId}',
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
                controller: _guestNameController,
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
                final newName = _guestNameController.text.trim();
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

        // Stats Matrix
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
            'Sign Out (Switch to Guest)',
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

  // 2. Quick Guest Tab (Minimal Effort)
  Widget _buildQuickGuestTab(PlayerProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.player2, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Zero Friction Quick Start',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start playing Triangle Tactics immediately without creating passwords or email verification. You can link a full Serverpod account anytime.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Callsign Input
          const Text(
            'YOUR TACTICAL CALLSIGN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _guestNameController,
            decoration: InputDecoration(
              hintText: 'Enter Callsign (e.g., ApexTactician)',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColors.player1,
              ),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Preset Callsigns (1-Tap Selection)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'Vanguard',
                  'ApexTactician',
                  'NovaStrike',
                  'HexaMaster',
                  'CyberKnight',
                ].map((name) {
                  return ActionChip(
                    backgroundColor: AppColors.surfaceElevated,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    label: Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _guestNameController.text = name;
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),

          // Play as Guest Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final name = _guestNameController.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(playerProfileProvider.notifier)
                    .updateDisplayName(name);
              }
              if (mounted) Navigator.of(context).maybePop();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 20),
                SizedBox(width: 8),
                Text(
                  'Continue as Guest',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Sign In Tab
  Widget _buildSignInTab(PlayerProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Fill Demo Account
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Credentials',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '1-tap pre-fill for effortless evaluation',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.player2,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Quick Fill'),
                  onPressed: _fillDemoCredentials,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Email Field
          const Text(
            'EMAIL ADDRESS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.player1,
              ),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Password Field
          const Text(
            'PASSWORD',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.player1,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Login Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.isLoading
                ? null
                : () async {
                    final email = _loginEmailController.text.trim();
                    final password = _loginPasswordController.text;
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter both email and password.',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    final success = await ref
                        .read(playerProfileProvider.notifier)
                        .login(email: email, password: password);
                    if (success && mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sign In with Serverpod',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // 4. Register Tab (Start -> Verification -> Finish)
  Widget _buildRegisterTab(PlayerProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Registration Header & Demo Helper
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fast Registration',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate unique credentials in 1 tap',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.player1,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Auto-Fill'),
                  onPressed: _fillDemoRegistration,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!_registrationStarted) ...[
            // Step 1: Input Email, Password, Callsign
            const Text(
              'CALLSIGN (PLAYER NAME)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regNameController,
              decoration: InputDecoration(
                hintText: 'e.g., TacticalMaster',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.player2,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'EMAIL ADDRESS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'player@example.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.player2,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'PASSWORD',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regPasswordController,
              obscureText: _obscureRegPassword,
              decoration: InputDecoration(
                hintText: 'At least 8 characters',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.player2,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureRegPassword = !_obscureRegPassword;
                    });
                  },
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.player2,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final email = _regEmailController.text.trim();
                      final password = _regPasswordController.text;
                      if (email.isEmpty || password.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid email and a password of at least 8 characters.',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      final reqId = await ref
                          .read(playerProfileProvider.notifier)
                          .startRegistration(email: email);
                      if (reqId != null) {
                        setState(() {
                          _registrationStarted = true;
                          _pendingRequestId = reqId;
                        });
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Next: Verify Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ] else ...[
            // Step 2: Verification Code Entry
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.player2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.mark_email_read,
                        color: AppColors.player2,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verification Code Sent',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check your server logs or console for the 8-character verification code for ${_regEmailController.text.trim()}.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '8-CHARACTER VERIFICATION CODE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _regCodeController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                letterSpacing: 4,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.player1,
              ),
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: const TextStyle(letterSpacing: 2),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.player1,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: state.isLoading || _pendingRequestId == null
                  ? null
                  : () async {
                      final code = _regCodeController.text.trim();
                      if (code.isEmpty) return;
                      final success = await ref
                          .read(playerProfileProvider.notifier)
                          .completeRegistration(
                            accountRequestId: _pendingRequestId!,
                            verificationCode: code,
                            password: _regPasswordController.text,
                            displayName: _regNameController.text.trim(),
                          );
                      if (success && mounted) {
                        Navigator.of(context).maybePop();
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Complete Registration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _registrationStarted = false;
                });
              },
              child: const Text(
                'Back to Step 1',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. Official Serverpod SignInWidget Tab
  Widget _buildOfficialWidgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Official Serverpod IDP Component',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Direct integration with Serverpod auth widgets',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SignInWidget(
            client: client,
            onAuthenticated: () {
              ref.read(playerProfileProvider.notifier).refreshProfile();
              if (mounted) Navigator.of(context).maybePop();
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Serverpod Auth Error: $error'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
