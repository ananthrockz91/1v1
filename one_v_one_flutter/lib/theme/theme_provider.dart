import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  tealCyber,
  monochromeMinimal,
}

class AppThemeData {
  final AppThemeMode mode;
  final String name;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceBorder;
  final Color accent;
  final Color accentSecondary;
  final Color accentDark;
  final Color accentSurface;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color logoPrimary;
  final Color logoSecondary;
  final Color logoVs;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cardBackground;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;

  const AppThemeData({
    required this.mode,
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceBorder,
    required this.accent,
    required this.accentSecondary,
    required this.accentDark,
    required this.accentSurface,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.logoPrimary,
    required this.logoSecondary,
    required this.logoVs,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cardBackground,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
  });

  bool get isMonochrome => mode == AppThemeMode.monochromeMinimal;

  static const tealCyber = AppThemeData(
    mode: AppThemeMode.tealCyber,
    name: 'Teal Cyber',
    background: Color(0xFF0B101E),
    surface: Color(0xFF131B2E),
    surfaceElevated: Color(0xFF1C273E),
    surfaceBorder: Color(0xFF263552),
    accent: Color(0xFF14B8A6), // Vibrant Teal
    accentSecondary: Color(0xFF2DD4BF), // Light Teal
    accentDark: Color(0xFF0F766E), // Deep Teal
    accentSurface: Color(0x2214B8A6), // Soft Teal Tint
    heroGradientStart: Color(0xFF0F2B2B), // Teal Tinted Surface
    heroGradientEnd: Color(0xFF131B2E),
    logoPrimary: Color(0xFF14B8A6), // Teal
    logoSecondary: Color(0xFF14B8A6), // Teal (unified teal branding)
    logoVs: Color(0xFF64748B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    cardBackground: Color(0xFF131B2E),
    buttonBackground: Color(0xFF14B8A6),
    buttonForeground: Colors.black,
    badgeBackground: Color(0x2214B8A6),
    badgeBorder: Color(0x5514B8A6),
    badgeText: Color(0xFF2DD4BF),
  );

  static const monochromeMinimal = AppThemeData(
    mode: AppThemeMode.monochromeMinimal,
    name: 'B&W Minimal',
    background: Color(0xFF000000), // OLED Pure Black
    surface: Color(0xFF0A0A0A), // Deep matte black
    surfaceElevated: Color(0xFF141414), // Subtle elevated surface
    surfaceBorder: Color(0xFF27272A), // Hairline zinc border
    accent: Color(0xFFFFFFFF), // Pure Crisp White
    accentSecondary: Color(0xFFD4D4D8), // Zinc-300
    accentDark: Color(0xFF52525B), // Zinc-600
    accentSurface: Color(0xFF18181B), // Soft Zinc Tint
    heroGradientStart: Color(0xFF18181B),
    heroGradientEnd: Color(0xFF0A0A0A),
    logoPrimary: Color(0xFFFFFFFF), // Pure White
    logoSecondary: Color(0xFFFFFFFF), // Pure White
    logoVs: Color(0xFF71717A), // Zinc-500
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    cardBackground: Color(0xFF0A0A0A),
    buttonBackground: Color(0xFFFFFFFF), // High-contrast White
    buttonForeground: Color(0xFF000000), // Black on White
    badgeBackground: Color(0xFF18181B),
    badgeBorder: Color(0xFF3F3F46),
    badgeText: Color(0xFFE4E4E7),
  );
}

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.tealCyber);

  void toggle() {
    state = state == AppThemeMode.tealCyber
        ? AppThemeMode.monochromeMinimal
        : AppThemeMode.tealCyber;
  }

  void setMode(AppThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
      return ThemeModeNotifier();
    });

final currentThemeProvider = Provider<AppThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == AppThemeMode.monochromeMinimal
      ? AppThemeData.monochromeMinimal
      : AppThemeData.tealCyber;
});
