import 'package:flutter/material.dart';
import 'angle_test_screen.dart';
import 'calibration_screen.dart';
import 'ride_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goToCalibration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalibrationScreen(),
      ),
    );
  }

  void _goToAngleTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AngleTestScreen(),
      ),
    );
  }

  void _goToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RideHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wirolo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.10)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: Image.asset(
                        'assets/branding/wirolo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _goToCalibration(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text('Demarrer une session'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _goToAngleTest(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.secondary,
                  side: BorderSide(color: colors.secondary, width: 2),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Tester l angle'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _goToHistory(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.tertiary,
                  side: BorderSide(color: colors.tertiary, width: 2),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Voir l historique'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
