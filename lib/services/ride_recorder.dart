import '../models/ride_point.dart';
import 'location_service.dart';

class RideRecorder {
  RideRecorder({
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  static const double _maxAcceptedAccuracy = 20;
  static const int _minPointIntervalMs = 1000;

  final LocationService _locationService;
  final List<RidePoint> _ridePoints = [];

  DateTime? _lastPointTime;
  bool _isCapturingPoint = false;

  List<RidePoint> get ridePoints => List.unmodifiable(_ridePoints);

  Future<bool> requestPermission() {
    return _locationService.requestPermission();
  }

  Future<void> capturePoint(double lean) async {
    final now = DateTime.now();

    if (_isCapturingPoint) {
      return;
    }

    if (_lastPointTime != null &&
        now.difference(_lastPointTime!).inMilliseconds < _minPointIntervalMs) {
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
}
