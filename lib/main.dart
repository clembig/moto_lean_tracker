import 'dart:async';
import 'package:flutter/material.dart';
import 'services/lean_tracker.dart';

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
        content: Text('Calibration OK'),
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
              'Lean: ${_lean.round()}°',
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _calibrate(context),
              child: const Text(
                'Calibrer',
                style: TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startRide(context),
              child: const Text(
                'Start Ride',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideSessionScreen extends StatefulWidget {
  const RideSessionScreen({
    super.key,
    required this.tracker,
  });

  final LeanTracker tracker;

  @override
  State<RideSessionScreen> createState() => _RideSessionScreenState();
}

class _RideSessionScreenState extends State<RideSessionScreen> {
  StreamSubscription<double>? _leanSubscription;

  double _lean = 0;
  double _maxLeft = 0;
  double _maxRight = 0;

  @override
  void initState() {
    super.initState();

    _leanSubscription = widget.tracker.leanStream.listen((value) {
      if (!mounted) return;

      setState(() {
        _lean = value;

        if (value < _maxLeft) {
          _maxLeft = value;
        }

        if (value > _maxRight) {
          _maxRight = value;
        }
      });
    });
  }

  void _stopRide(BuildContext context) {
    widget.tracker.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RideStatsScreen(
          maxLeft: _maxLeft.abs().round(),
          maxRight: _maxRight.abs().round(),
        ),
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
        title: const Text('Ride in progress'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lean: ${_lean.round()}°',
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
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _stopRide(context),
              child: const Text(
                'Stop Ride',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideStatsScreen extends StatelessWidget {
  const RideStatsScreen({
    super.key,
    required this.maxLeft,
    required this.maxRight,
  });

  final int maxLeft;
  final int maxRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride stats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Max gauche : ${maxLeft}°',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Max droite : ${maxRight}°',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Back Home',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}