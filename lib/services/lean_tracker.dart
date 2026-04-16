import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class LeanTracker {
  double _lean = 0;
  double _rawAngle = 0;
  double _refX = 0;
  double _refY = 0;
  double _refZ = 0;
  double _sideX = 0;
  double _sideY = 0;
  double _sideZ = 0;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  double _maxLeft = 0.0;
  double _maxRight = 0.0;
  double _debugRaw = 0;

  double get maxLeft => _maxLeft;
  double get maxRight => _maxRight;
  double get debugRaw => _debugRaw;

  double _lastDisplayedLean = 0;
  DateTime _lastUpdate = DateTime.now();

  final _controller = StreamController<double>.broadcast();
  Stream<double> get leanStream => _controller.stream;

  StreamSubscription<AccelerometerEvent>? _subscription;

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

  double computeLean(double x, double y, double z) {
    final rawAngle = computeRawAngle(x, y, z);
    if (rawAngle.isNaN) return double.nan;

    final corrected = applyCalibration(rawAngle);
    _debugRaw = corrected;

    _lean = smooth(_lean, corrected);

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
    _subscription = accelerometerEvents.listen((event) {
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
    final gravityOnSide = (x * _sideX) + (y * _sideY) + (z * _sideZ);
    final gravityOnUp = (x * _refX) + (y * _refY) + (z * _refZ);

    final sideNorm = sqrt((_sideX * _sideX) + (_sideY * _sideY) + (_sideZ * _sideZ));
    final upNorm = sqrt((_refX * _refX) + (_refY * _refY) + (_refZ * _refZ));

    if (sideNorm < 0.1 || upNorm < 0.1) {
      return 0;
    }

    final side = gravityOnSide / sideNorm;
    final up = gravityOnUp / upNorm;

    return atan2(side, up) * 57.2958;
  }

  void calibrate() {
    _refX = _lastX;
    _refY = _lastY;
    _refZ = _lastZ;
    final refNorm = sqrt((_refX * _refX) + (_refY * _refY) + (_refZ * _refZ));

    if (refNorm > 0.1) {
      final upX = _refX / refNorm;
      final upY = _refY / refNorm;
      final upZ = _refZ / refNorm;

      // axe horizontal fixe dans "le monde"
      const worldForwardX = 0.0;
      const worldForwardY = 1.0;
      const worldForwardZ = 0.0;

      _sideX = upY * worldForwardZ - upZ * worldForwardY;
      _sideY = upZ * worldForwardX - upX * worldForwardZ;
      _sideZ = upX * worldForwardY - upY * worldForwardX;
    }

    _lean = 0;
    _lastDisplayedLean = 0;
    _lastUpdate = DateTime.now();
    _controller.add(0);
  }

  void stop() {
    _subscription?.cancel();
  }
}