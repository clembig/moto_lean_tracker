import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class LeanTracker {
  double _lean = 0;
  double _rawAngle = 0;
  double _maxLeft = 0.0;
  double _maxRight = 0.0;
  double _debugRaw = 0;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  double _referenceAngleXZ = 0;

  double get maxLeft => _maxLeft;
  double get maxRight => _maxRight;
  double get debugRaw => _debugRaw;
  double get debugLastX => _lastX;
  double get debugLastY => _lastY;
  double get debugLastZ => _lastZ;

  double _lastDisplayedLean = 0;
  DateTime _lastUpdate = DateTime.now();

  final _controller = StreamController<double>.broadcast();
  Stream<double> get leanStream => _controller.stream;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  double smooth(double previous, double current) {
    return (previous * 0.1) + (current * 0.9);
  }

  void _updateMaxima(double lean) {
    if (lean > _maxRight) {
      _maxRight = lean;
    }
    if (lean < _maxLeft) {
      _maxLeft = lean;
    }
  }

  double computeLean(double x, double y, double z) {
    final rawAngle = computeRawAngle(x, y, z);
    if (rawAngle.isNaN) return double.nan;

    _debugRaw = rawAngle;

    _lean = smooth(_lean, rawAngle);

    if (_lean.abs() < 2) {
      _lean = 0;
    }

    _updateMaxima(_lean);

    return _lean;
  }

  void resetMaxima() {
    _maxLeft = 0.0;
    _maxRight = 0.0;
  }

  void start() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;

      final smoothed = computeLean(event.x, event.y, event.z);
      if (smoothed.isNaN) return;

      final now = DateTime.now();
      final elapsed = now.difference(_lastUpdate).inMilliseconds;
      final diff = (smoothed - _lastDisplayedLean).abs();

      _rawAngle = computeRawAngle(event.x, event.y, event.z);

      if (elapsed > 200 && diff > 1) {
        _lean = smoothed;
        _lastDisplayedLean = smoothed;
        _lastUpdate = now;

        _controller.add(_lean);
      }
    });
  }

  double computeRawAngle(double x, double y, double z) {
    return (atan2(x, z) * 57.2958) - _referenceAngleXZ;
  }

  void calibrate() {
    _referenceAngleXZ = atan2(_lastX, _lastZ) * 57.2958;
    _lean = 0;
    _lastDisplayedLean = 0;
    _lastUpdate = DateTime.now();
    _debugRaw = 0;
    _controller.add(0);
  }

  void stop() {
    _accelerometerSubscription?.cancel();
  }
}
