import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class LeanTracker {
  double _lean = 0;
  double _rawAngle = 0;
  double _mountPitchRad = 0;

  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;

  double _lastGyroX = 0;
  double _lastGyroY = 0;
  double _lastGyroZ = 0;

  double _maxLeft = 0.0;
  double _maxRight = 0.0;
  double _debugRaw = 0;

  double get maxLeft => _maxLeft;
  double get maxRight => _maxRight;
  double get debugRaw => _debugRaw;

  double _lastDisplayedLean = 0;
  DateTime _lastUpdate = DateTime.now();
  DateTime? _lastSensorTime;

  final _controller = StreamController<double>.broadcast();
  Stream<double> get leanStream => _controller.stream;

  StreamSubscription<AccelerometerEvent>? _subscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  double smooth(double previous, double current) {
    return (previous * 0.8) + (current * 0.2);
  }

  void _updateMaxima(double lean) {
    if (lean > _maxRight) {
      _maxRight = lean;
    }
    if (lean < _maxLeft) {
      _maxLeft = lean;
    }
  }

  double applyCalibration(double rawAngle) {
    return rawAngle;
  }

  double computeLean(double x, double y, double z, double dt) {
    final rawAngle = computeRawAngle(x, y, z);
    if (rawAngle.isNaN) return double.nan;

    final corrected = applyCalibration(rawAngle);
    final accelLean = -corrected;

    _debugRaw = accelLean;

    _lean = smooth(_lean, accelLean);

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
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      _lastGyroX = event.x;
      _lastGyroY = event.y;
      _lastGyroZ = event.z;
    });

    _subscription = accelerometerEvents.listen((event) {
      final nowSensor = DateTime.now();

      double dt = 0;
      if (_lastSensorTime != null) {
        dt = nowSensor.difference(_lastSensorTime!).inMilliseconds / 1000.0;
      }
      _lastSensorTime = nowSensor;

      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;

      final smoothed = computeLean(event.x, event.y, event.z, dt);
      if (smoothed.isNaN) return;

      final now = DateTime.now();
      final elapsed = now.difference(_lastUpdate).inMilliseconds;

      _rawAngle = computeRawAngle(event.x, event.y, event.z);

      if (elapsed > 50) {
        _lean = smoothed;
        _lastDisplayedLean = smoothed;
        _lastUpdate = now;
        _controller.add(_lean);
      }
    });
  }

  double computeRawAngle(double x, double y, double z) {
    final zAligned = (y * sin(_mountPitchRad)) + (z * cos(_mountPitchRad));

    if (zAligned.abs() < 0.1) return double.nan;

    return atan2(x, zAligned) * 57.2958;
  }

  void calibrate() {
    _mountPitchRad = atan2(_lastY, _lastZ);

    _lean = 0;
    _lastDisplayedLean = 0;
    _lastUpdate = DateTime.now();
    _lastSensorTime = null;
    _controller.add(0);
  }

  void stop() {
    _subscription?.cancel();
    _gyroscopeSubscription?.cancel();
  }
}