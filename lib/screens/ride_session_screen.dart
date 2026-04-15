import 'dart:async';
import 'package:flutter/material.dart';
import '../services/lean_tracker.dart';
import 'ride_stats_screen.dart';

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