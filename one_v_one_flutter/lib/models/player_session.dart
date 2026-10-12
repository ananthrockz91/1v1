import 'dart:math';
import '../client.dart';

class PlayerSession {
  static String? _guestId;
  static String? _customName;

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

  static String get displayName {
    if (_customName != null && _customName!.trim().isNotEmpty) {
      return _customName!;
    }
    try {
      if (client.auth.isAuthenticated) {
        return 'Player_${currentId.substring(0, min(6, currentId.length))}';
      }
    } catch (_) {}
    return 'Guest_${currentId.split('_').last}';
  }

  static void setDisplayName(String name) {
    _customName = name.trim();
  }

  static void setCustomId(String id, [String? name]) {
    _guestId = id;
    if (name != null) _customName = name.trim();
  }

  static void clear() {
    _guestId = null;
    _customName = null;
  }
}
