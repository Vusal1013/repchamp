import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/constants/exercise_thresholds.dart';
import '../core/utils/angle_calculator.dart';
import '../core/utils/smoothing_buffer.dart';
import '../models/exercise_type.dart';

enum RepState {
  unknown,
  up,
  down,
}

class RepCounterEngine {
  final ExerciseType exerciseType;
  RepState _currentState = RepState.unknown;
  int _repCount = 0;
  bool _hasBeenDown = false;

  late final SmoothingBuffer<double> _angleBuffer;

  RepCounterEngine({required this.exerciseType}) {
    _angleBuffer = SmoothingBuffer<double>(
      ExerciseThresholds.smoothingBufferSize,
    );
  }

  int get repCount => _repCount;
  RepState get currentState => _currentState;

  void reset() {
    _repCount = 0;
    _currentState = RepState.unknown;
    _hasBeenDown = false;
    _angleBuffer.clear();
  }

  int processPose(Pose pose) {
    if (exerciseType == ExerciseType.plank) {
      return _repCount;
    }

    final angle = _calculateExerciseAngle(pose);
    if (angle == null) return _repCount;

    _angleBuffer.add(angle);
    if (!_angleBuffer.isFull) return _repCount;

    final smoothedAngle = _angleBuffer.average;
    final upThreshold = ExerciseThresholds.getUpAngle(exerciseType.databaseValue);
    final downThreshold = ExerciseThresholds.getDownAngle(exerciseType.databaseValue);

    switch (_currentState) {
      case RepState.unknown:
        if (smoothedAngle >= upThreshold) {
          _currentState = RepState.up;
        } else if (smoothedAngle <= downThreshold) {
          _currentState = RepState.down;
          _hasBeenDown = true;
        }
        break;

      case RepState.up:
        if (smoothedAngle <= downThreshold) {
          _currentState = RepState.down;
          _hasBeenDown = true;
        }
        break;

      case RepState.down:
        if (smoothedAngle >= upThreshold && _hasBeenDown) {
          _currentState = RepState.up;
          _repCount++;
          _hasBeenDown = false;
        }
        break;
    }

    return _repCount;
  }

  double?_calculateExerciseAngle(Pose pose) {
    switch (exerciseType) {
      case ExerciseType.pushUp:
        return _calculatePushUpAngle(pose);
      case ExerciseType.squat:
        return _calculateSquatAngle(pose);
      case ExerciseType.crunch:
        return _calculateCrunchAngle(pose);
      case ExerciseType.pullUp:
        return _calculatePullUpAngle(pose);
      case ExerciseType.plank:
        return _calculatePlankAngle(pose);
      case ExerciseType.lunge:
        return _calculateLungeAngle(pose);
      case ExerciseType.shoulderPress:
        return _calculateShoulderPressAngle(pose);
    }
  }

  // ─── Exercise Angle Calculations ─────────────────

  double? _calculatePushUpAngle(Pose pose) {
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftLikelihood = min(
      leftShoulder?.likelihood ?? 0,
      min(leftElbow?.likelihood ?? 0, leftWrist?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightShoulder?.likelihood ?? 0,
      min(rightElbow?.likelihood ?? 0, rightWrist?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftElbow != null && leftShoulder != null && leftWrist != null) {
      return calculateAngle(
        Offset(leftShoulder.x, leftShoulder.y),
        Offset(leftElbow.x, leftElbow.y),
        Offset(leftWrist.x, leftWrist.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightElbow != null && rightShoulder != null && rightWrist != null) {
      return calculateAngle(
        Offset(rightShoulder.x, rightShoulder.y),
        Offset(rightElbow.x, rightElbow.y),
        Offset(rightWrist.x, rightWrist.y),
      );
    }

    return null;
  }

  double? _calculateSquatAngle(Pose pose) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftLikelihood = min(
      leftHip?.likelihood ?? 0,
      min(leftKnee?.likelihood ?? 0, leftAnkle?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightHip?.likelihood ?? 0,
      min(rightKnee?.likelihood ?? 0, rightAnkle?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftKnee != null && leftHip != null && leftAnkle != null) {
      return calculateAngle(
        Offset(leftHip.x, leftHip.y),
        Offset(leftKnee.x, leftKnee.y),
        Offset(leftAnkle.x, leftAnkle.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightKnee != null && rightHip != null && rightAnkle != null) {
      return calculateAngle(
        Offset(rightHip.x, rightHip.y),
        Offset(rightKnee.x, rightKnee.y),
        Offset(rightAnkle.x, rightAnkle.y),
      );
    }

    return null;
  }

  double? _calculateCrunchAngle(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    final leftLikelihood = min(
      leftShoulder?.likelihood ?? 0,
      min(leftHip?.likelihood ?? 0, leftKnee?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightShoulder?.likelihood ?? 0,
      min(rightHip?.likelihood ?? 0, rightKnee?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftShoulder != null && leftHip != null && leftKnee != null) {
      return calculateAngle(
        Offset(leftShoulder.x, leftShoulder.y),
        Offset(leftHip.x, leftHip.y),
        Offset(leftKnee.x, leftKnee.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightShoulder != null && rightHip != null && rightKnee != null) {
      return calculateAngle(
        Offset(rightShoulder.x, rightShoulder.y),
        Offset(rightHip.x, rightHip.y),
        Offset(rightKnee.x, rightKnee.y),
      );
    }

    return null;
  }

  double? _calculatePullUpAngle(Pose pose) {
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftLikelihood = min(
      leftShoulder?.likelihood ?? 0,
      min(leftElbow?.likelihood ?? 0, leftWrist?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightShoulder?.likelihood ?? 0,
      min(rightElbow?.likelihood ?? 0, rightWrist?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftShoulder != null && leftElbow != null && leftWrist != null) {
        return calculateAngle(
          Offset(leftShoulder.x, leftShoulder.y),
          Offset(leftElbow.x, leftElbow.y),
          Offset(leftWrist.x, leftWrist.y),
        );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightShoulder != null && rightElbow != null && rightWrist != null) {
      return calculateAngle(
        Offset(rightShoulder.x, rightShoulder.y),
        Offset(rightElbow.x, rightElbow.y),
        Offset(rightWrist.x, rightWrist.y),
      );
    }

    return null;
  }

  double? _calculatePlankAngle(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftLikelihood = min(
      leftShoulder?.likelihood ?? 0,
      min(leftHip?.likelihood ?? 0, leftAnkle?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightShoulder?.likelihood ?? 0,
      min(rightHip?.likelihood ?? 0, rightAnkle?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftShoulder != null && leftHip != null && leftAnkle != null) {
      return calculateAngle(
        Offset(leftShoulder.x, leftShoulder.y),
        Offset(leftHip.x, leftHip.y),
        Offset(leftAnkle.x, leftAnkle.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightShoulder != null && rightHip != null && rightAnkle != null) {
      return calculateAngle(
        Offset(rightShoulder.x, rightShoulder.y),
        Offset(rightHip.x, rightHip.y),
        Offset(rightAnkle.x, rightAnkle.y),
      );
    }

    return null;
  }

  double? _calculateLungeAngle(Pose pose) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    final leftLikelihood = min(
      leftHip?.likelihood ?? 0,
      min(leftKnee?.likelihood ?? 0, leftAnkle?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightHip?.likelihood ?? 0,
      min(rightKnee?.likelihood ?? 0, rightAnkle?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftKnee != null && leftHip != null && leftAnkle != null) {
      return calculateAngle(
        Offset(leftHip.x, leftHip.y),
        Offset(leftKnee.x, leftKnee.y),
        Offset(leftAnkle.x, leftAnkle.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightKnee != null && rightHip != null && rightAnkle != null) {
      return calculateAngle(
        Offset(rightHip.x, rightHip.y),
        Offset(rightKnee.x, rightKnee.y),
        Offset(rightAnkle.x, rightAnkle.y),
      );
    }

    return null;
  }

  double? _calculateShoulderPressAngle(Pose pose) {
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    final leftLikelihood = min(
      leftShoulder?.likelihood ?? 0,
      min(leftElbow?.likelihood ?? 0, leftWrist?.likelihood ?? 0),
    );

    final rightLikelihood = min(
      rightShoulder?.likelihood ?? 0,
      min(rightElbow?.likelihood ?? 0, rightWrist?.likelihood ?? 0),
    );

    if (leftLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        leftShoulder != null && leftElbow != null && leftWrist != null) {
      return 180.0 - calculateAngle(
        Offset(leftShoulder.x, leftShoulder.y),
        Offset(leftElbow.x, leftElbow.y),
        Offset(leftWrist.x, leftWrist.y),
      );
    }

    if (rightLikelihood >= ExerciseThresholds.minLandmarkLikelihood &&
        rightShoulder != null && rightElbow != null && rightWrist != null) {
      return 180.0 - calculateAngle(
        Offset(rightShoulder.x, rightShoulder.y),
        Offset(rightElbow.x, rightElbow.y),
        Offset(rightWrist.x, rightWrist.y),
      );
    }

    return null;
  }

  // ─── Form Analysis ──────────────────────────────

  String? checkForm(Pose pose) {
    switch (exerciseType) {
      case ExerciseType.pushUp:
        return _checkPushUpForm(pose);
      case ExerciseType.squat:
        return _checkSquatForm(pose);
      case ExerciseType.plank:
        return _checkPlankForm(pose);
      case ExerciseType.lunge:
        return _checkLungeForm(pose);
      default:
        return null;
    }
  }

  String? _checkPushUpForm(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (leftHip == null || leftShoulder == null || leftAnkle == null) return null;

    final bodyAngle = calculateAngle(
      Offset(leftShoulder.x, leftShoulder.y),
      Offset(leftHip.x, leftHip.y),
      Offset(leftAnkle.x, leftAnkle.y),
    );

    if (bodyAngle < 160) return 'Hips too low';
    if (bodyAngle > 200) return 'Hips too high';
    return null;
  }

  String? _checkSquatForm(Pose pose) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    if (leftKnee == null || leftAnkle == null || leftHip == null) return null;

    final kneeOverToe = (leftKnee.x - leftAnkle.x).abs();
    if (kneeOverToe > 0.15) return 'Knees past toes';

    final backAngle = calculateAngle(
      Offset(leftHip.x, leftHip.y),
      Offset(leftKnee.x, leftKnee.y),
      Offset(leftAnkle.x, leftAnkle.y),
    );
    if (backAngle < 70) return 'Too deep';
    return null;
  }

  String? _checkPlankForm(Pose pose) {
    final angle = _calculatePlankAngle(pose);
    if (angle == null) return null;

    if (angle < ExerciseThresholds.plankWarning) return 'Hips dropping';
    if (angle > 190) return 'Hips too high';
    return null;
  }

  String? _checkLungeForm(Pose pose) {
    final frontKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final frontAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final backKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    if (frontKnee == null || frontAnkle == null || backKnee == null) return null;

    final kneePastToe = (frontKnee.x - frontAnkle.x).abs();
    if (kneePastToe > 0.15) return 'Front knee past toe';

    if (backKnee.y < frontKnee.y - 0.05) return 'Back knee not low enough';
    return null;
  }
}
