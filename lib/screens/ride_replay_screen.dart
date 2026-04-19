import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  double _sliderValue = 0;

  @override
  Widget build(BuildContext context) {
    final points = widget.session.ridePoints;
    final pointCount = points.length;
    final currentIndex =
        pointCount == 0 ? 0 : _sliderValue.round().clamp(0, pointCount - 1);
    final currentPoint = pointCount == 0 ? null : points[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride replay'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Points: $pointCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: currentPoint == null
                    ? const Center(
                        child: Text(
                          'No replay data available.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 20),
                          Text(
                            'Point ${currentIndex + 1} / $pointCount',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RiderLeanIndicator(lean: currentPoint.lean),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Lat: ${currentPoint.latitude}'),
                                    Text('Lng: ${currentPoint.longitude}'),
                                    Text(
                                      'Lean: ${currentPoint.lean.round()} deg',
                                    ),
                                    Text(
                                      'Accuracy: ${currentPoint.accuracy.round()} m',
                                    ),
                                    Text('Time: ${currentPoint.timestamp}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Slider(
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
                                    final nextIndex = value
                                        .round()
                                        .clamp(0, pointCount - 1);
                                    final nextPoint = points[nextIndex];

                                    setState(() {
                                      _sliderValue = value;
                                    });

                                    _mapController.move(
                                      LatLng(
                                        nextPoint.latitude,
                                        nextPoint.longitude,
                                      ),
                                      _mapController.camera.zoom,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
