class RidePoint {
  const RidePoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.lean,
    required this.accuracy,
  });

  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double lean;
  final double accuracy;
}
