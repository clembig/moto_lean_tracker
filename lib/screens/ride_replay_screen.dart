import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ride_point.dart';
import '../models/ride_session.dart';
import '../widgets/rider_lean_indicator.dart';

class RideReplayScreen extends StatefulWidget {
  const RideReplayScreen({
    super.key,
    required this.session,
  });

  final RideSession session;

  @override
  State<RideReplayScreen> createState() => _RideReplayScreenState();
}

class _RideReplayScreenState extends State<RideReplayScreen> {
  final MapController _mapController = MapController();
  Timer? _playTimer;
  double _sliderValue = 0;
  static const Duration _minPlaybackStep = Duration(milliseconds: 80);
  static const Duration _maxPlaybackStep = Duration(milliseconds: 450);

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    final points = widget.session.ridePoints;
    if (points.length < 2) {
      return;
    }

    if (_playTimer != null) {
      _playTimer?.cancel();
      _playTimer = null;
      setState(() {});
      return;
    }

    if (_sliderValue >= points.length - 1) {
      _sliderValue = 0;
    }

    _scheduleNextPlaybackStep();
    setState(() {});
  }

  void _scheduleNextPlaybackStep() {
    final points = widget.session.ridePoints;
    final currentIndex = _sliderValue.round();
    final nextIndex = currentIndex + 1;

    if (nextIndex >= points.length) {
      _playTimer?.cancel();
      _playTimer = null;
      setState(() {});
      return;
    }

    final currentPoint = points[currentIndex];
    final nextPoint = points[nextIndex];
    final rawDelay = nextPoint.timestamp.difference(currentPoint.timestamp);
    final delay = _clampPlaybackDelay(rawDelay);

    _playTimer = Timer(delay, () {
      _playTimer = null;

      if (!mounted) {
        return;
      }

      _moveToPoint(nextPoint, nextIndex.toDouble());
      _scheduleNextPlaybackStep();
    });
  }

  Duration _clampPlaybackDelay(Duration delay) {
    if (delay < _minPlaybackStep) {
      return _minPlaybackStep;
    }

    if (delay > _maxPlaybackStep) {
      return _maxPlaybackStep;
    }

    return delay;
  }

  void _moveToPoint(RidePoint point, double sliderValue) {
    setState(() {
      _sliderValue = sliderValue;
    });

    _mapController.move(
      LatLng(point.latitude, point.longitude),
      _mapController.camera.zoom,
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.session.ridePoints;
    final pointCount = points.length;
    final currentIndex =
        pointCount == 0 ? 0 : _sliderValue.round().clamp(0, pointCount - 1);
    final currentPoint = pointCount == 0 ? null : points[currentIndex];
    final polylinePoints =
        points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    final isPlaying = _playTimer != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay'),
      ),
      body: SafeArea(
        child: currentPoint == null
            ? const Center(
                child: Text(
                  'Aucune donnee de replay disponible.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReplayLeanHeader(lean: currentPoint.lean),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              currentPoint.latitude,
                              currentPoint.longitude,
                            ),
                            initialZoom: 17,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.moto_lean_tracker',
                            ),
                            if (polylinePoints.length >= 2)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: polylinePoints,
                                    strokeWidth: 4,
                                    color: Colors.red.shade600,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    currentPoint.latitude,
                                    currentPoint.longitude,
                                  ),
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Point ${currentIndex + 1} sur $pointCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Angle ${currentPoint.lean.round()}  |  Precision ${currentPoint.accuracy.round()} m',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Temps ${_formatDuration(currentPoint.timestamp.difference(widget.session.startedAt))}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _togglePlayback,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: _sliderValue.clamp(
                              0,
                              pointCount > 0 ? (pointCount - 1).toDouble() : 0,
                            ),
                            min: 0,
                            max: pointCount > 1
                                ? (pointCount - 1).toDouble()
                                : 1,
                            onChanged: pointCount > 1
                                ? (value) {
                                    if (_playTimer != null) {
                                      _playTimer?.cancel();
                                      _playTimer = null;
                                    }

                                    final nextIndex = value
                                        .round()
                                        .clamp(0, pointCount - 1);
                                    _moveToPoint(points[nextIndex], value);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ReplayLeanHeader extends StatelessWidget {
  const _ReplayLeanHeader({
    required this.lean,
  });

  final double lean;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 248,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 0,
            child: Text(
              '0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Positioned(
            top: 34,
            left: 14,
            child: Text(
              '45',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Positioned(
            top: 34,
            right: 14,
            child: Text(
              '45',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Positioned(
            top: 94,
            left: 2,
            child: Text(
              '90',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Positioned(
            top: 94,
            right: 2,
            child: Text(
              '90',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LeanGuidePainter(),
            ),
          ),
          Positioned(
            top: 18,
            child: RiderLeanIndicator(
              lean: lean,
              width: 108,
              height: 162,
            ),
          ),
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                '${lean.round()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeanGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.78);
    final radius = size.width * 0.34;
    final arcPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final tickPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      5 * math.pi / 4,
      math.pi / 2,
      false,
      arcPaint,
    );

    for (final degrees in [15, 30, 45, 60, 75]) {
      final radiansLeft = (270 - degrees) * math.pi / 180;
      final radiansRight = (270 + degrees) * math.pi / 180;
      _drawTick(canvas, center, radius, radiansLeft, tickPaint);
      _drawTick(canvas, center, radius, radiansRight, tickPaint);
    }
  }

  void _drawTick(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint paint,
  ) {
    final outer = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final inner = Offset(
      center.dx + (radius - 14) * math.cos(angle),
      center.dy + (radius - 14) * math.sin(angle),
    );
    canvas.drawLine(inner, outer, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
