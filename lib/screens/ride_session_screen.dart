import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ride_point.dart';
import '../services/location_service.dart';
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
  static const double _maxAcceptedAccuracy = 20;
  StreamSubscription<double>? _leanSubscription;
  final LocationService _locationService = LocationService();
  final List<RidePoint> _ridePoints = [];

  double _lean = 0;
  double _maxLeft = 0;
  double _maxRight = 0;
  DateTime? _lastPointTime;
  bool _isCapturingPoint = false;
  String _gpsStatus = 'GPS: checking...';

  @override
  void initState() {
    super.initState();

    _initLocationPermission();

    _leanSubscription = widget.tracker.leanStream.listen((value) {
      _captureRidePoint(value);

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
    final hasPermission = await _locationService.requestPermission();
    if (!mounted) return;

    setState(() {
      _gpsStatus = hasPermission ? 'GPS: permission granted' : 'GPS: permission denied';
    });
  }

  Future<void> _captureRidePoint(double lean) async {
    final now = DateTime.now();

    if (_isCapturingPoint) {
      return;
    }

    if (_lastPointTime != null &&
        now.difference(_lastPointTime!).inMilliseconds < 1000) {
      return;
    }

    _isCapturingPoint = true;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;
      if (position.accuracy > _maxAcceptedAccuracy) return;

      _ridePoints.add(
        RidePoint(
          timestamp: now,
          latitude: position.latitude,
          longitude: position.longitude,
          lean: lean,
          accuracy: position.accuracy,
        ),
      );

      _lastPointTime = now;
    } finally {
      _isCapturingPoint = false;
    }
  }

  void _stopRide(BuildContext context) {
    widget.tracker.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RideStatsScreen(
          maxLeft: _maxLeft.abs().round(),
          maxRight: _maxRight.abs().round(),
          ridePoints: List.unmodifiable(_ridePoints),
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
