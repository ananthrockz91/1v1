import 'dart:math';
import '../client.dart';

class PlayerSession {
  static String? _guestId;
  static String? _customName;
  static String? _avatarSeed;

  static bool get isAuthenticated {
    try {
      return client.auth.isAuthenticated;
    } catch (_) {
      return false;
    }
  }

  static String get currentId {
    try {
      if (client.auth.isAuthenticated) {
        final authInfo = client.auth.authInfo;
        if (authInfo != null) {
          return authInfo.authUserId.toString();
        }
      }
    } catch (_) {}
    if (_guestId == null) {
      final rand = Random();
      _guestId =
          'player_${DateTime.now().millisecondsSinceEpoch % 100000}_${rand.nextInt(1000)}';
    }
    return _guestId!;
  }

  static bool get hasCustomName =>
      _customName != null &&
      _customName!.trim().isNotEmpty &&
      !_customName!.startsWith('Player_') &&
      !_customName!.startsWith('Guest_');

  static String get displayName {
    if (_customName != null && _customName!.trim().isNotEmpty) {
      return _customName!;
    }
    return 'Guest_${currentId.split('_').last}';
  }

  static bool get hasCustomAvatar =>
      _avatarSeed != null &&
      _avatarSeed!.trim().isNotEmpty &&
      _avatarSeed != 'avatar_1';

  static String get avatarSeed => _avatarSeed ?? 'avatar_1';

  static void setDisplayName(String name) {
    _customName = name.trim();
  }

  static void setAvatarSeed(String seed) {
    _avatarSeed = seed.trim();
  }

  static void setCustomId(String id, [String? name, String? avatar]) {
    _guestId = id;
    if (name != null) _customName = name.trim();
    if (avatar != null) _avatarSeed = avatar.trim();
  }

  static void clear() {
    _guestId = null;
    _customName = null;
    _avatarSeed = null;
  }
}
