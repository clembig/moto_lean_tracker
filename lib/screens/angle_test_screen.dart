import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/lean_tracker.dart';

class AngleTestScreen extends StatefulWidget {
  const AngleTestScreen({super.key});

  @override
  State<AngleTestScreen> createState() => _AngleTestScreenState();
}

class _AngleTestScreenState extends State<AngleTestScreen> {
  late final LeanTracker _tracker;
  StreamSubscription<double>? _leanSubscription;
  Timer? _refreshTimer;

  double _lean = 0;

  @override
  void initState() {
    super.initState();
    _tracker = LeanTracker();
    _tracker.start();

    _leanSubscription = _tracker.leanStream.listen((value) {
      if (!mounted) return;
      setState(() {
        _lean = value;
      });
    });

    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _leanSubscription?.cancel();
    _refreshTimer?.cancel();
    _tracker.stop();
    super.dispose();
  }

  void _calibrate() {
    _tracker.calibrate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reference prise a 0'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final correctedRaw = _tracker.debugRaw;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test angle'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      _lean.round().toString(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'angle affiche',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _AngleBenchGauge(angle: _lean),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ValueCard(
                      title: 'Angle brut corrige',
                      value: correctedRaw.round().toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ValueCard(
                      title: 'Angle filtre',
                      value: _lean.round().toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug capteurs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accel x ${_tracker.debugLastX.toStringAsFixed(2)}  y ${_tracker.debugLastY.toStringAsFixed(2)}  z ${_tracker.debugLastZ.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Angle brut corrige XZ ${_tracker.debugRaw.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Procedure de test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Place le telephone dans la position de reference.'),
                    Text('2. Appuie sur "Calibrer a 0".'),
                    Text('3. Incline progressivement a gauche ou a droite.'),
                    Text('4. Verifie si 0, 45 et 90 paraissent coherents.'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _calibrate,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Calibrer a 0',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _AngleBenchGauge extends StatelessWidget {
  const _AngleBenchGauge({
    required this.angle,
  });

  final double angle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _AngleBenchGaugePainter(angle: angle),
      ),
    );
  }
}

class _AngleBenchGaugePainter extends CustomPainter {
  const _AngleBenchGaugePainter({
    required this.angle,
  });

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = math.min(size.width * 0.38, size.height * 0.72);
    final arcPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final tickPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final needlePaint = Paint()
      ..color = Colors.red.shade600
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    for (final marker in [0, 15, 30, 45, 60, 75, 90]) {
      final leftAngle = math.pi + (marker / 90) * (math.pi / 2);
      final rightAngle = 2 * math.pi - (marker / 90) * (math.pi / 2);

      if (marker == 0) {
        _drawLabel(canvas, center, radius + 18, 3 * math.pi / 2, '0', textStyle);
      } else {
        _drawTick(canvas, center, radius, leftAngle, tickPaint);
        _drawTick(canvas, center, radius, rightAngle, tickPaint);
        _drawLabel(canvas, center, radius + 18, leftAngle, '$marker', textStyle);
        _drawLabel(canvas, center, radius + 18, rightAngle, '$marker', textStyle);
      }
    }

    final clamped = angle.clamp(-90, 90).toDouble();
    final needleAngle = (3 * math.pi / 2) + (clamped / 90) * (math.pi / 2);
    final needleEnd = Offset(
      center.dx + (radius - 14) * math.cos(needleAngle),
      center.dy + (radius - 14) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = Colors.red.shade600);
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
      center.dx + (radius - 12) * math.cos(angle),
      center.dy + (radius - 12) * math.sin(angle),
    );
    canvas.drawLine(inner, outer, paint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
    TextStyle style,
  ) {
    final offset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        offset.dx - painter.width / 2,
        offset.dy - painter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AngleBenchGaugePainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
