import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class LeanTracker {
  double _lean = 0;
  double _rawAngle = 0;
  double _reference = 0;

  double _lastDisplayedLean = 0;
  DateTime _lastUpdate = DateTime.now();

  final _controller = StreamController<double>.broadcast();

  Stream<double> get leanStream => _controller.stream;

  StreamSubscription<AccelerometerEvent>? _subscription;

  void start() {
    _subscription = accelerometerEvents.listen((event) {
      final double x = event.x;
      final double z = event.z;

      if (z.abs() < 0.1) return;

      final double angle = atan(x / z) * 57.2958;
      final double corrected = angle - _reference;
      final double smoothed = (_lean * 0.8) + (corrected * 0.2);

      final now = DateTime.now();
      final elapsed = now.difference(_lastUpdate).inMilliseconds;
      final diff = (smoothed - _lastDisplayedLean).abs();

      _rawAngle = angle;

      if (elapsed > 200 && diff > 1) {
        _lean = smoothed;
        _lastDisplayedLean = smoothed;
        _lastUpdate = now;

        _controller.add(_lean);
      }
    });
  }

  void calibrate() {
    _reference = _rawAngle;
    _lean = 0;
    _lastDisplayedLean = 0;
    _lastUpdate = DateTime.now();
    _controller.add(0);
  }

  void stop() {
    _subscription?.cancel();
  }
}