import 'package:flutter/material.dart';
import 'calibration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToCalibration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalibrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto Lean Tracker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _goToCalibration(context),
          child: const Text(
            'Demarrer une session',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
