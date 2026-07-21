import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/utils/angle_calculator.dart';
import '../models/exercise_type.dart';

class FormFeedback {
  final String message;
  final double severity;

  const FormFeedback({required this.message, required this.severity});
}

class FormAnalyzer {
  String? analyze(Pose pose, ExerciseType type) {
    switch (type) {
      case ExerciseType.pushUp:
        return _checkPushUp(pose);
      case ExerciseType.squat:
        return _checkSquat(pose);
      case ExerciseType.crunch:
        return _checkCrunch(pose);
      case ExerciseType.pullUp:
        return _checkPullUp(pose);
      case ExerciseType.plank:
        return _checkPlank(pose);
      case ExerciseType.lunge:
        return _checkLunge(pose);
      case ExerciseType.shoulderPress:
        return _checkShoulderPress(pose);
    }
  }

  String? _checkPushUp(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (leftHip == null || leftShoulder == null || leftAnkle == null) return null;

    final bodyAngle = calculateAngle(
      Offset(leftShoulder.x, leftShoulder.y),
      Offset(leftHip.x, leftHip.y),
      Offset(leftAnkle.x, leftAnkle.y),
    );

    if (bodyAngle < 155) return 'Hips too low';
    if (bodyAngle > 200) return 'Hips too high';
    if (bodyAngle > 185) return 'Hips sagging';

    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    if (leftElbow != null && leftWrist != null) {
      final elbowSpread = (leftElbow.x - leftWrist.x).abs();
      if (elbowSpread > 0.2) return 'Elbows flaring out';
    }

    return null;
  }

  String? _checkSquat(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (leftKnee == null || leftAnkle == null || leftHip == null) return null;

    final kneeOverToe = (leftKnee.x - leftAnkle.x).abs();
    if (kneeOverToe > 0.15) return 'Knees past toes';

    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    if (leftShoulder != null) {
      final torsoLean = (leftShoulder.x - leftHip.x).abs();
      if (torsoLean > 0.12) return 'Leaning forward too much';
    }

    return null;
  }

  String? _checkCrunch(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    if (leftHip == null || leftShoulder == null) return null;

    final headUp = leftShoulder.y < leftHip.y - 0.05;
    if (!headUp) return 'Lift shoulders off ground';

    return null;
  }

  String? _checkPullUp(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (leftShoulder == null || rightShoulder == null) return null;

    final shoulderDiff = (leftShoulder.y - rightShoulder.y).abs();
    if (shoulderDiff > 0.08) return 'Body swinging';

    return null;
  }

  String? _checkPlank(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (leftHip == null || leftShoulder == null || leftAnkle == null) return null;

    final angle = calculateAngle(
      Offset(leftShoulder.x, leftShoulder.y),
      Offset(leftHip.x, leftHip.y),
      Offset(leftAnkle.x, leftAnkle.y),
    );

    if (angle < 160) return 'Hips dropping';
    if (angle > 190) return 'Hips too high';

    return null;
  }

  String? _checkLunge(Pose pose) {
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    if (leftKnee == null || leftAnkle == null || rightKnee == null) return null;

    final kneePastToe = (leftKnee.x - leftAnkle.x).abs();
    if (kneePastToe > 0.15) return 'Front knee past toe';

    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (rHip != null && rightKnee.y > rHip.y - 0.02) return 'Back knee not bent enough';

    return null;
  }

  String? _checkShoulderPress(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    if (leftShoulder == null || leftElbow == null) return null;

    if (leftElbow.y > leftShoulder.y - 0.1) return 'Elbows too low at bottom';
    if (rightShoulder != null && rightElbow != null) {
      final asymmetry = (leftElbow.y - rightElbow.y).abs();
      if (asymmetry > 0.08) return 'Arms uneven';
    }

    return null;
  }
}
