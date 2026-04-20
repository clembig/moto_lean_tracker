import 'dart:async';
import 'package:flutter/material.dart';
import '../services/lean_tracker.dart';
import 'ride_session_screen.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  late LeanTracker _tracker;
  StreamSubscription<double>? _leanSubscription;

  double _lean = 0;

  @override
  void initState() {
    super.initState();

    _tracker = LeanTracker();
    _tracker.start();

    _leanSubscription = _tracker.leanStream.listen((value) {
      if (!mounted) return;

      setState(() {
        _lean = value;
      });
    });
  }

  void _calibrate(BuildContext context) {
    _tracker.calibrate();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calibration terminee'),
      ),
    );
  }

  void _startRide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideSessionScreen(tracker: _tracker),
      ),
    );
  }

  @override
  void dispose() {
    _leanSubscription?.cancel();
    super.dispose();
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
              'Angle : ${_lean.round()}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Place la moto droite avant de calibrer',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _calibrate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text(
                'Calibrer',
                style: TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startRide(context),
              child: const Text(
                'Demarrer la ride',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
