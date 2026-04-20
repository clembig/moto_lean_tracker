import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MotoLeanTrackerApp());
}

class MotoLeanTrackerApp extends StatelessWidget {
  const MotoLeanTrackerApp({super.key});

  static const Color _teal = Color(0xFF2EB7B0);
  static const Color _brick = Color(0xFFC53B18);
  static const Color _indigo = Color(0xFF3A3D69);
  static const Color _orange = Color(0xFFF7941D);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.light(
      primary: _indigo,
      secondary: _orange,
      tertiary: _teal,
      surface: const Color(0xFFF7F4EF),
      error: _brick,
      onPrimary: Colors.white,
      onSecondary: _indigo,
      onSurface: _indigo,
      onError: Colors.white,
    );

    return MaterialApp(
      title: 'Wirolo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F4EF),
          foregroundColor: _indigo,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _indigo,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: _teal,
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _indigo,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _indigo.withValues(alpha: 0.25),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _orange,
          inactiveTrackColor: _orange.withValues(alpha: 0.18),
          thumbColor: _orange,
          overlayColor: _orange.withValues(alpha: 0.16),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0x1A3A3D69),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
