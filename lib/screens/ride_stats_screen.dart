import 'package:flutter/material.dart';
import '../models/ride_point.dart';
import 'ride_replay_screen.dart';

class RideStatsScreen extends StatelessWidget {
  const RideStatsScreen({
    super.key,
    required this.maxLeft,
    required this.maxRight,
    required this.ridePoints,
  });

  final int maxLeft;
  final int maxRight;
  final List<RidePoint> ridePoints;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride stats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Max gauche : ${maxLeft} deg',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Max droite : ${maxRight} deg',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Points GPS : ${ridePoints.length}',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: ridePoints.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideReplayScreen(
                            ridePoints: ridePoints,
                          ),
                        ),
                      );
                    },
              child: const Text(
                'Open Replay',
                style: TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Back Home',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
