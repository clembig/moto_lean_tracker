import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
    );j'ai mon main dart, ma console pc, 
  }
}

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
            'Start Session',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double _lean = 0;

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {
      final double x = event.x;
      final double z = event.z;

      if (z.abs() < 0.1) {
        return;
      }

      final double angle = atan(x / z) * 57.2958;

      setState(() {
        _lean = angle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lean: ${_lean.toStringAsFixed(1)}°',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Drive safe',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}