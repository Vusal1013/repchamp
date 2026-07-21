import 'dart:math' show atan2, pi;
import 'package:flutter/material.dart';

double calculateAngle(Offset a, Offset b, Offset c) {
  final radians = atan2(c.dy - b.dy, c.dx - b.dx) -
      atan2(a.dy - b.dy, a.dx - b.dx);
  double angle = (radians * 180.0 / pi).abs();
  if (angle > 180.0) {
    angle = 360.0 - angle;
  }
  return angle;
}
