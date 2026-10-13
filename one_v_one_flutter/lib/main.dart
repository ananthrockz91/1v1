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
      ),
      home: const HomeScreen(),
    );
  }
}
