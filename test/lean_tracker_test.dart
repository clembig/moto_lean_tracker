import 'package:flutter_test/flutter_test.dart';
import 'package:moto_lean_tracker/services/lean_tracker.dart';

void main() {
  group('LeanTracker computeRawAngle', () {
    late LeanTracker tracker;

    setUp(() {
      tracker = LeanTracker();
    });

    test('retourne 0 quand x = 0 et z = 1', () {
      expect(tracker.computeRawAngle(0, 1), closeTo(0, 0.001));
    });

    test('retourne environ 45° quand x = 1 et z = 1', () {
      expect(tracker.computeRawAngle(1, 1), closeTo(45, 0.5));
    });

    test('retourne environ -45° quand x = -1 et z = 1', () {
      expect(tracker.computeRawAngle(-1, 1), closeTo(-45, 0.5));
    });

    test('retourne NaN si z est trop proche de 0', () {
      expect(tracker.computeRawAngle(1, 0.05).isNaN, true);
    });
  });

  group('smoothing', () {
    late LeanTracker tracker;

    setUp(() {
      tracker = LeanTracker();
    });

    test('rapproche progressivement vers la cible', () {
      double value = 0;

      value = tracker.smooth(value, 10);
      expect(value, closeTo(2, 0.01));

      value = tracker.smooth(value, 10);
      expect(value, closeTo(3.6, 0.01));
    });

    test('applyCalibration enlève la référence', () {
      tracker.calibrate();

      final result = tracker.applyCalibration(10);

      expect(result, closeTo(10, 0.001));
    });

    test('applyCalibration retourne rawAngle moins la référence', () {
      final result = tracker.applyCalibration(5);

      expect(result, closeTo(5, 0.001));
    });
  });

  group('computeLean', () {
    late LeanTracker tracker;

    setUp(() {
      tracker = LeanTracker();
    });

    test('retourne NaN si z est trop faible', () {
      final result = tracker.computeLean(1, 0.01);

      expect(result.isNaN, true);
    });

    test('retourne une valeur cohérente', () {
      final result = tracker.computeLean(1, 1);

      expect(result, greaterThan(0));
      expect(result, lessThan(50));
    });
  });
}