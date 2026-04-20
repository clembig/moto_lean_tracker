class RidePoint {
  const RidePoint({
    this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.lean,
    required this.accuracy,
  });

  final int? id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double lean;
  final double accuracy;

  RidePoint copyWith({
    int? id,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? lean,
    double? accuracy,
  }) {
    return RidePoint(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lean: lean ?? this.lean,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, Object?> toDatabaseMap(int sessionId) {
    return {
      'session_id': sessionId,
      'timestamp_ms': timestamp.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'lean': lean,
      'accuracy': accuracy,
    };
  }

  factory RidePoint.fromDatabaseMap(Map<String, Object?> map) {
    return RidePoint(
      id: map['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp_ms'] as int,
      ),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      lean: (map['lean'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
    );
  }
}
