import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_v_one_client/one_v_one_client.dart';
import '../client.dart';
import '../models/player_session.dart';

class PlayerProfileState {
  final PlayerProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isAuthenticated;
  final String playerId;
  final String displayName;
  final String avatarSeed;

  const PlayerProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    required this.isAuthenticated,
    required this.playerId,
    required this.displayName,
    this.avatarSeed = 'avatar_1',
  });

  PlayerProfileState copyWith({
    PlayerProfile? profile,
    bool clearProfile = false,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAuthenticated,
    String? playerId,
    String? displayName,
    String? avatarSeed,
  }) {
    return PlayerProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      playerId: playerId ?? this.playerId,
      displayName: displayName ?? this.displayName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
    );
  }
}

class PlayerProfileNotifier extends StateNotifier<PlayerProfileState> {
  PlayerProfileNotifier()
    : super(
        PlayerProfileState(
          isAuthenticated: PlayerSession.isAuthenticated,
          playerId: PlayerSession.currentId,
          displayName: PlayerSession.displayName,
          avatarSeed: PlayerSession.avatarSeed,
        ),
      ) {
    try {
      client.auth.authInfoListenable.addListener(_onAuthStatusChanged);
      refreshProfile();
    } catch (_) {
      // In test environments where client is not initialized, fallback smoothly
    }
  }

  void _onAuthStatusChanged() {
    final isAuth = PlayerSession.isAuthenticated;
    if (!isAuth) {
      PlayerSession.clear();
      state = PlayerProfileState(
        profile: null,
        isAuthenticated: false,
        playerId: PlayerSession.currentId,
        displayName: PlayerSession.displayName,
        avatarSeed: 'avatar_1',
      );
    } else {
      PlayerSession.clear();
      state = state.copyWith(
        clearProfile: true,
        isAuthenticated: true,
        playerId: PlayerSession.currentId,
        displayName: PlayerSession.displayName,
        avatarSeed: PlayerSession.avatarSeed,
        isLoading: true,
      );
    }
    refreshProfile();
  }

  @override
  void dispose() {
    try {
      client.auth.authInfoListenable.removeListener(_onAuthStatusChanged);
    } catch (_) {}
    super.dispose();
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await client.player.getOrCreateProfile(
        playerId: PlayerSession.currentId,
        displayName: PlayerSession.hasCustomName
            ? PlayerSession.displayName
            : null,
        avatarSeed: PlayerSession.hasCustomAvatar
            ? PlayerSession.avatarSeed
            : null,
      );
      if (profile.displayName.isNotEmpty) {
        PlayerSession.setDisplayName(profile.displayName);
      }
      if (profile.avatarSeed.isNotEmpty) {
        PlayerSession.setAvatarSeed(profile.avatarSeed);
      }
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        playerId: PlayerSession.currentId,
        displayName: profile.displayName,
        avatarSeed: profile.avatarSeed,
        isAuthenticated: PlayerSession.isAuthenticated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    final clean = newName.trim();
    if (clean.isEmpty) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await client.player.updateProfile(
        playerId: PlayerSession.currentId,
        displayName: clean,
      );
      PlayerSession.setDisplayName(clean);
      state = state.copyWith(
        profile: updated,
        displayName: clean,
        isLoading: false,
        successMessage: 'Callsign updated to $clean',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update callsign: $e',
      );
      return false;
    }
  }

  Future<bool> updateAvatar(String newAvatarSeed) async {
    final clean = newAvatarSeed.trim();
    if (clean.isEmpty) return false;
    PlayerSession.setAvatarSeed(clean);
    state = state.copyWith(avatarSeed: clean);

    // If this is a local device image (data URI), attempt Serverpod Cloud Storage direct upload
    if (clean.startsWith('data:')) {
      try {
        final commaIndex = clean.indexOf(',');
        final base64String = commaIndex != -1
            ? clean.substring(commaIndex + 1)
            : clean;
        final bytes = base64Decode(base64String);
        final uploadDesc = await client.player.getAvatarUploadDescription(
          playerId: PlayerSession.currentId,
        );

        if (uploadDesc != null) {
          final uploader = FileUploader(uploadDesc);
          final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
          final uploaded = await uploader.uploadByteData(byteData);

          if (uploaded) {
            final verifiedProfile = await client.player.verifyAvatarUpload(
              playerId: PlayerSession.currentId,
            );
            if (verifiedProfile != null &&
                verifiedProfile.avatarSeed.isNotEmpty) {
              PlayerSession.setAvatarSeed(verifiedProfile.avatarSeed);
              state = state.copyWith(
                profile: verifiedProfile,
                avatarSeed: verifiedProfile.avatarSeed,
                successMessage: 'Profile photo uploaded to cloud storage',
              );
              return true;
            }
          }
        }
      } catch (_) {
        // Fall back gracefully to direct database string storage below
      }
    }

    try {
      final updated = await client.player.updateProfile(
        playerId: PlayerSession.currentId,
        avatarSeed: clean,
      );
      state = state.copyWith(
        profile: updated,
        avatarSeed: updated.avatarSeed,
        successMessage: 'Profile picture updated',
      );
      return true;
    } catch (_) {
      // Local fallback for guest sessions
      state = state.copyWith(
        successMessage: 'Profile picture updated',
      );
      return true;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authSuccess = await client.emailIdp.login(
        email: email.trim(),
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      PlayerSession.setDisplayName(email.trim().split('@').first);
      await refreshProfile();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Welcome back, ${PlayerSession.displayName}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Login failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<UuidValue?> startRegistration({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final requestId = await client.emailIdp.startRegistration(
        email: email.trim(),
      );
      state = state.copyWith(
        isLoading: false,
        successMessage:
            'Verification code sent to $email (logged in console for dev).',
      );
      return requestId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Registration failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return null;
    }
  }

  Future<bool> completeRegistration({
    required UuidValue accountRequestId,
    required String verificationCode,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final regToken = await client.emailIdp.verifyRegistrationCode(
        accountRequestId: accountRequestId,
        verificationCode: verificationCode.trim(),
      );
      final authSuccess = await client.emailIdp.finishRegistration(
        registrationToken: regToken,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      if (displayName != null && displayName.trim().isNotEmpty) {
        PlayerSession.setDisplayName(displayName.trim());
        await client.player.getOrCreateProfile(
          playerId: authSuccess.authUserId.toString(),
          displayName: displayName.trim(),
        );
      }
      await refreshProfile();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Account successfully registered and logged in!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Verification failed: ${e.toString().replaceAll('Exception: ', '')}',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await client.auth.signOutDevice();
      PlayerSession.clear();
      state = PlayerProfileState(
        profile: null,
        isAuthenticated: false,
        playerId: PlayerSession.currentId,
        displayName: PlayerSession.displayName,
        avatarSeed: 'avatar_1',
        isLoading: false,
        successMessage: 'Signed out successfully.',
      );
      await refreshProfile();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign out failed: $e',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfileState>(
      (ref) => PlayerProfileNotifier(),
    );
