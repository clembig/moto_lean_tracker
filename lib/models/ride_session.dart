import 'ride_point.dart';

class RideSession {
  const RideSession({
    this.id,
    required this.startedAt,
    required this.endedAt,
    required this.maxLeft,
    required this.maxRight,
    required this.ridePoints,
  });

  final int? id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int maxLeft;
  final int maxRight;
  final List<RidePoint> ridePoints;

  RideSession copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? maxLeft,
    int? maxRight,
    List<RidePoint>? ridePoints,
  }) {
    return RideSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      maxLeft: maxLeft ?? this.maxLeft,
      maxRight: maxRight ?? this.maxRight,
      ridePoints: ridePoints ?? this.ridePoints,
    );
  }

  Map<String, Object?> toDatabaseMap() {
    return {
      'started_at_ms': startedAt.millisecondsSinceEpoch,
      'ended_at_ms': endedAt.millisecondsSinceEpoch,
      'max_left': maxLeft,
      'max_right': maxRight,
    };
  }

  factory RideSession.fromDatabaseMap({
    required Map<String, Object?> map,
    required List<RidePoint> ridePoints,
  }) {
    return RideSession(
      id: map['id'] as int?,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map['started_at_ms'] as int,
      ),
      endedAt: DateTime.fromMillisecondsSinceEpoch(map['ended_at_ms'] as int),
      maxLeft: map['max_left'] as int,
      maxRight: map['max_right'] as int,
      ridePoints: ridePoints,
    );
  }
}
