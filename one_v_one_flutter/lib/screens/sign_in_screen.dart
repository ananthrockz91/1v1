import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../client.dart';
import '../models/player_session.dart';
import '../providers/player_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/player_avatar.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final Widget? child;
  const SignInScreen({super.key, this.child});

  static Future<void> show(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const SignInScreen(),
          ),
        ),
      );
    }
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
  late final EmailAuthController _authController;
  bool _obscurePassword = true;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _callsignController.text = ref.read(playerProfileProvider).displayName;
    _authController = EmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.login,
      onAuthenticated: () async {
        final email = _authController.emailController.text.trim();
        if (email.contains('@')) {
          final prefix = email.split('@').first;
          if (prefix.isNotEmpty) {
            PlayerSession.setDisplayName(prefix);
            try {
              await client.player.getOrCreateProfile(
                playerId: PlayerSession.currentId,
                displayName: prefix,
              );
            } catch (_) {}
          }
        }
        await ref.read(playerProfileProvider.notifier).refreshProfile();
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _inlineError = '$error'.replaceAll('Exception:', '').trim();
          });
        }
      },
    );
    _authController.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {
        if (_authController.state != EmailAuthState.error) {
          _inlineError = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    _authController.dispose();
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: isDesktop
                ? BorderRadius.circular(24)
                : const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
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
                  // Drag Handle (mobile only)
                  if (!isDesktop)
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
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
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
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playerState.isAuthenticated
                                    ? 'Player Profile'
                                    : _getHeaderTitle(),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                playerState.isAuthenticated
                                    ? 'Your verified profile and battle statistics'
                                    : 'Sign in or register to track matches & ranks',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: AppColors.surfaceBorder, height: 1),

                  // Body: Authenticated Profile vs Responsive Authentication Flow
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: playerState.isAuthenticated
                          ? _buildAuthenticatedProfileView(playerState)
                          : _buildCustomAuthFlow(),
                    ),
                  ),
                ],
              ),
            ),
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

  String _getHeaderTitle() {
    return switch (_authController.currentScreen) {
      EmailFlowScreen.login => 'Sign In',
      EmailFlowScreen.startRegistration => 'Create Account',
      EmailFlowScreen.verifyRegistration => 'Verify Account',
      EmailFlowScreen.completeRegistration => 'Set Password',
      EmailFlowScreen.requestPasswordReset => 'Reset Password',
      EmailFlowScreen.verifyPasswordReset => 'Verify Reset Code',
      EmailFlowScreen.completePasswordReset => 'New Password',
    };
  }

  // ==========================================
  // RESPONSIVE AUTHENTICATION FLOW
  // ==========================================
  Widget _buildCustomAuthFlow() {
    final isLoading = _authController.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_inlineError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _inlineError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        switch (_authController.currentScreen) {
          EmailFlowScreen.login => _buildLoginView(isLoading),
          EmailFlowScreen.startRegistration => _buildStartRegistrationView(
            isLoading,
          ),
          EmailFlowScreen.verifyRegistration => _buildVerifyRegistrationView(
            isLoading,
          ),
          EmailFlowScreen.completeRegistration =>
            _buildCompleteRegistrationView(isLoading),
          EmailFlowScreen.requestPasswordReset =>
            _buildRequestPasswordResetView(isLoading),
          EmailFlowScreen.verifyPasswordReset => _buildVerifyPasswordResetView(
            isLoading,
          ),
          EmailFlowScreen.completePasswordReset =>
            _buildCompletePasswordResetView(isLoading),
        },
      ],
    );
  }

  // 1. Sign In View
  Widget _buildLoginView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _authController.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: 'player@example.com',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => _authController.navigateTo(
                      EmailFlowScreen.requestPasswordReset,
                    ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColors.player1,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _authController.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onSubmitted: (_) {
            if (!isLoading) _authController.login();
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading ? null : () => _authController.login(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Sign In',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => _authController.navigateTo(
                      EmailFlowScreen.startRegistration,
                    ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: AppColors.player1,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Start Registration View
  Widget _buildStartRegistrationView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _authController.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: 'player@example.com',
            icon: Icons.email_outlined,
          ),
          onSubmitted: (_) {
            if (!isLoading) _authController.startRegistration();
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.startRegistration(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => _authController.navigateTo(EmailFlowScreen.login),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.player1,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Responsive 4-Digit Verification View (Compact PIN Fields & No Timer)
  Widget _buildVerifyRegistrationView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter the verification code sent to your email below.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),

        // Default Code Helper Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.player1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.player1.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: AppColors.player1, size: 15),
              SizedBox(width: 6),
              Text(
                'Default test code: 1234',
                style: TextStyle(
                  color: AppColors.player1,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Compact & Responsive 4-digit PIN Input
        Center(
          child: Pinput(
            controller: _authController.verificationCodeController,
            length: 4,
            autofocus: true,
            keyboardType: TextInputType.number,
            defaultPinTheme: PinTheme(
              width: 52,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 52,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.player1,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.player1, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.player1.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            onCompleted: (pin) {
              if (!isLoading) {
                _authController.verifyRegistrationCode();
              }
            },
          ),
        ),
        const SizedBox(height: 12),

        // Resend code button (No countdown timer 53)
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.resendVerificationCode(),
            child: const Text(
              "Didn't receive? Send a new code",
              style: TextStyle(
                color: AppColors.player2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.verifyRegistrationCode(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Verify',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to sign in',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Complete Registration (Set Password) View
  Widget _buildCompleteRegistrationView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose a password for your new player account.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const Text(
          'Password',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _authController.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onSubmitted: (_) {
            if (!isLoading) _authController.finishRegistration();
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.finishRegistration(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Complete & Sign In',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to sign in',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 5. Request Password Reset View
  Widget _buildRequestPasswordResetView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter your email address to receive a reset code.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const Text(
          'Email Address',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _authController.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: 'player@example.com',
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.startPasswordReset(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Request Reset Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to sign in',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Verify Password Reset View
  Widget _buildVerifyPasswordResetView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter the 4-digit reset code sent to your email (Default test code: 1234).',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Center(
          child: Pinput(
            controller: _authController.verificationCodeController,
            length: 4,
            autofocus: true,
            keyboardType: TextInputType.number,
            defaultPinTheme: PinTheme(
              width: 52,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 52,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.player1,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.player1, width: 2),
              ),
            ),
            onCompleted: (_) {
              if (!isLoading) _authController.verifyPasswordResetCode();
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.verifyPasswordResetCode(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Verify Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to sign in',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // 7. Complete Password Reset View
  Widget _buildCompletePasswordResetView(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter your new password.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _authController.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: _primaryButtonStyle(),
          onPressed: isLoading
              ? null
              : () => _authController.finishPasswordReset(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Save & Sign In',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => _authController.navigateTo(EmailFlowScreen.login),
            child: const Text(
              'Back to sign in',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.player1, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.player1,
      foregroundColor: Colors.black,
      minimumSize: const Size.fromHeight(46),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ==========================================
  // AUTHENTICATED PROFILE VIEW
  // ==========================================
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
              GestureDetector(
                onTap: () {
                  AvatarPickerSheet.show(
                    context: context,
                    initialSeed: state.avatarSeed,
                    onSelected: (newSeed) {
                      ref
                          .read(playerProfileProvider.notifier)
                          .updateAvatar(newSeed);
                    },
                  );
                },
                child: Tooltip(
                  message: 'Tap to change avatar',
                  child: Stack(
                    children: [
                      PlayerAvatar(
                        avatarSeed: state.avatarSeed,
                        displayName: state.displayName,
                        size: 54,
                        borderColor: AppColors.player1,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 13,
                            color: AppColors.player1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                              fontSize: 17,
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
                    const SizedBox(height: 3),
                    Text(
                      'Account ID: ${state.playerId}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        AvatarPickerSheet.show(
                          context: context,
                          initialSeed: state.avatarSeed,
                          onSelected: (newSeed) {
                            ref
                                .read(playerProfileProvider.notifier)
                                .updateAvatar(newSeed);
                          },
                        );
                      },
                      child: const Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: AppColors.player1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Edit your callsign',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.surfaceBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.surfaceBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.player1,
                      width: 1.5,
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
                elevation: 0,
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
        const SizedBox(height: 20),

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
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
