import 'package:flutter/material.dart';

class RideStatsScreen extends StatelessWidget {
  const RideStatsScreen({
    super.key,
    required this.maxLeft,
    required this.maxRight,
  });

  final int maxLeft;
  final int maxRight;

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
              'Max gauche : ${maxLeft}°',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Max droite : ${maxRight}°',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 40),
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