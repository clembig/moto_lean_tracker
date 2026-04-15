import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const MotoLeanTrackerApp());
}

class MotoLeanTrackerApp extends StatelessWidget {
  const MotoLeanTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moto Lean Tracker',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}