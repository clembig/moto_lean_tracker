import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ride_session.dart';
import '../services/lean_tracker.dart';
import '../services/ride_recorder.dart';
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
  final RideRecorder _rideRecorder = RideRecorder();
  late final DateTime _startedAt;

  double _lean = 0;
  double _maxLeft = 0;
  double _maxRight = 0;
  String _gpsStatus = 'GPS: checking...';

  @override
  void initState() {
    super.initState();

    _startedAt = DateTime.now();
    _initLocationPermission();

    _leanSubscription = widget.tracker.leanStream.listen((value) {
      _rideRecorder.capturePoint(value);

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

  Future<void> _initLocationPermission() async {
    final hasPermission = await _rideRecorder.requestPermission();
    if (!mounted) return;

    setState(() {
      _gpsStatus = hasPermission ? 'GPS: permission granted' : 'GPS: permission denied';
    });
  }

  void _stopRide(BuildContext context) {
    widget.tracker.stop();
    final session = RideSession(
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      maxLeft: _maxLeft.abs().round(),
      maxRight: _maxRight.abs().round(),
      ridePoints: _rideRecorder.ridePoints,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RideStatsScreen(session: session),
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
            const SizedBox(height: 12),
            Text(
              _gpsStatus,
              style: const TextStyle(fontSize: 16),
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
