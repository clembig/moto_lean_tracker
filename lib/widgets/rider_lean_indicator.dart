import 'dart:math' as math;
import 'package:flutter/material.dart';

class RiderLeanIndicator extends StatelessWidget {
  const RiderLeanIndicator({
    super.key,
    required this.lean,
    this.width = 120,
    this.height = 180,
  });

  final double lean;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalizedLean = lean.clamp(-45, 45).toDouble();
    final rotation = normalizedLean * math.pi / 180;

    return SizedBox(
      width: width,
      height: height,
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
