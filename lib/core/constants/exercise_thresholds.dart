import 'package:flutter/material.dart';

abstract final class ExerciseThresholds {
  ExerciseThresholds._();

  static const double pushUpUp = 160.0;
  static const double pushUpDown = 90.0;
  static const double squatUp = 160.0;
  static const double squatDown = 100.0;

  static const double minLandmarkLikelihood = 0.6;
  static const int smoothingBufferSize = 5;
  static const int frameThrottleInterval = 3;

  static double getUpAngle(String exercise) {
    switch (exercise) {
      case 'squat':
        return squatUp;
      default:
        return pushUpUp;
    }
  }

  static double getDownAngle(String exercise) {
    switch (exercise) {
      case 'squat':
        return squatDown;
      default:
        return pushUpDown;
    }
  }
}
