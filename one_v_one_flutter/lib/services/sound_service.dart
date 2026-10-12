import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sound_service_stub.dart'
    if (dart.library.js_interop) 'sound_service_web.dart'
    as platform_audio;

final soundEnabledProvider = StateProvider<bool>((ref) => true);

class SoundService {
  static bool enabled = true;

  static void playMove() {
    if (!enabled) return;
    if (kIsWeb) {
      platform_audio.playMove();
    } else {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void playCapture() {
    if (!enabled) return;
    if (kIsWeb) {
      platform_audio.playCapture();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  static void playVictory() {
    if (!enabled) return;
    if (kIsWeb) {
      platform_audio.playVictory();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  static void playDefeat() {
    if (!enabled) return;
    if (kIsWeb) {
      platform_audio.playDefeat();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  static void playTick() {
    if (!enabled) return;
    if (kIsWeb) {
      platform_audio.playTick();
    } else {
      HapticFeedback.selectionClick();
    }
  }
}
