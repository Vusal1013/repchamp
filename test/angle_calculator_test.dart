import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repchamp/core/utils/angle_calculator.dart';

void main() {
  group('calculateAngle', () {
    test('should return 90 degrees for a right angle', () {
      final a = Offset(0, 0);
      final b = Offset(0, 0);
      final c = Offset(0, 1);
      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(90.0, 0.01));
    });

    test('should return 180 degrees for a straight line', () {
      final a = Offset(0, 1);
      final b = Offset(0, 0);
      final c = Offset(0, -1);
      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(180.0, 0.01));
    });

    test('should return 0 degrees for overlapping points', () {
      final a = Offset(1, 0);
      final b = Offset(0, 0);
      final c = Offset(0, 0);
      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(0.0, 0.01));
    });

    test('should return ~45 degrees', () {
      final a = Offset(1, 0);
      final b = Offset(0, 0);
      final c = Offset(1, -1);
      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(45.0, 0.01));
    });

    test('should handle acute angle correctly', () {
      final a = Offset(0, 2);
      final b = Offset(0, 0);
      final c = Offset(1, 0);
      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(90.0, 0.01));
    });
  });
}
