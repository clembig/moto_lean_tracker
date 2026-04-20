import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/ride_point.dart';
import '../models/ride_session.dart';

class RideStorageService {
  RideStorageService._();

  static final RideStorageService instance = RideStorageService._();

  Database? _database;

  Future<Database> get database async {
    final db = _database;
    if (db != null) {
      return db;
    }

    final path = p.join(await getDatabasesPath(), 'wirolo_rides.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ride_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            started_at_ms INTEGER NOT NULL,
            ended_at_ms INTEGER NOT NULL,
            max_left INTEGER NOT NULL,
            max_right INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE ride_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            timestamp_ms INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            lean REAL NOT NULL,
            accuracy REAL NOT NULL,
            FOREIGN KEY (session_id) REFERENCES ride_sessions (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_ride_points_session_time ON ride_points(session_id, timestamp_ms)',
        );
        await db.execute(
          'CREATE INDEX idx_ride_sessions_started_at ON ride_sessions(started_at_ms)',
        );
        await db.execute(
          'CREATE INDEX idx_ride_points_lat_lng ON ride_points(latitude, longitude)',
        );
      },
    );

    return _database!;
  }

  Future<RideSession> saveSession(RideSession session) async {
    final db = await database;

    return db.transaction((txn) async {
      final sessionId = await txn.insert(
        'ride_sessions',
        session.toDatabaseMap(),
      );

      final storedPoints = <RidePoint>[];

      for (final point in session.ridePoints) {
        final pointId = await txn.insert(
          'ride_points',
          point.toDatabaseMap(sessionId),
        );
        storedPoints.add(point.copyWith(id: pointId));
      }

      return session.copyWith(
        id: sessionId,
        ridePoints: storedPoints,
      );
    });
  }

  Future<List<RideSession>> getSessions() async {
    final db = await database;
    final sessionMaps = await db.query(
      'ride_sessions',
      orderBy: 'started_at_ms DESC',
    );

    final sessions = <RideSession>[];

    for (final sessionMap in sessionMaps) {
      final sessionId = sessionMap['id'] as int;
      final pointMaps = await db.query(
        'ride_points',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp_ms ASC',
      );

      sessions.add(
        RideSession.fromDatabaseMap(
          map: sessionMap,
          ridePoints: pointMaps
              .map((pointMap) => RidePoint.fromDatabaseMap(pointMap))
              .toList(),
        ),
      );
    }

    return sessions;
  }
}
