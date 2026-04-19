import 'dart:math' as math;
import 'package:flutter/material.dart';

class RiderLeanIndicator extends StatelessWidget {
  const RiderLeanIndicator({
    super.key,
    required this.lean,
  });

  final double lean;

  @override
  Widget build(BuildContext context) {
    final normalizedLean = lean.clamp(-45, 45).toDouble();
    final rotation = normalizedLean * math.pi / 180;

    return SizedBox(
      width: 120,
      height: 180,
      child: Transform.rotate(
        angle: rotation,
        alignment: const Alignment(0, 0.96),
        child: Image.asset(
          'assets/rider_bike.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
