import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

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

class OneVOneApp extends StatelessWidget {
  const OneVOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1v1 — Play. Compete. Win.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.player1,
          secondary: AppColors.player2,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
