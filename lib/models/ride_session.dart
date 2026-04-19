import 'ride_point.dart';

class RideSession {
  const RideSession({
    required this.startedAt,
    required this.endedAt,
    required this.maxLeft,
    required this.maxRight,
    required this.ridePoints,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final int maxLeft;
  final int maxRight;
  final List<RidePoint> ridePoints;
}
