import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client.dart';
import 'screens/home_screen.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeClient();
  } catch (e) {
    debugPrint('Serverpod client initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: OneVOneApp(),
    ),
  );
}

class OneVOneApp extends ConsumerWidget {
  const OneVOneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    return MaterialApp(
      title: '1v1 — Play. Compete. Win.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: theme.background,
        colorScheme: ColorScheme.dark(
          primary: theme.accent,
          secondary: theme.accentSecondary,
          surface: theme.surface,
          error: theme.statusError,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.surface,
          elevation: 0,
          centerTitle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: theme.surface,
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: const WidgetStatePropertyAll(false),
          trackVisibility: const WidgetStatePropertyAll(false),
          thickness: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.dragged)) {
              return 6.0;
            }
            return 4.0;
          }),
          radius: const Radius.circular(8),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return theme.accent.withValues(alpha: 0.8);
            }
            if (states.contains(WidgetState.hovered)) {
              return theme.accent.withValues(alpha: 0.6);
            }
            return theme.textSecondary.withValues(alpha: 0.25);
          }),
          crossAxisMargin: 2.0,
          mainAxisMargin: 4.0,
        ),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      home: const HomeScreen(),
    );
  }
}
