import 'dart:math';

class PlayerSession {
  static String? _cachedId;
  static String? _cachedName;

  static String get currentId {
    if (_cachedId == null) {
      final rand = Random();
      _cachedId =
          'player_${DateTime.now().millisecondsSinceEpoch % 100000}_${rand.nextInt(1000)}';
    }
    return _cachedId!;
  }

  static String get displayName {
    _cachedName ??= 'Player_${currentId.split('_').last}';
    return _cachedName!;
  }

  static void setCustomId(String id, [String? name]) {
    _cachedId = id;
    if (name != null) _cachedName = name;
  }
}
