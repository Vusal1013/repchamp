import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract final class PoseLandmarks {
  PoseLandmarks._();

  static const leftShoulder = PoseLandmarkType.leftShoulder;
  static const leftElbow = PoseLandmarkType.leftElbow;
  static const leftWrist = PoseLandmarkType.leftWrist;
  static const rightShoulder = PoseLandmarkType.rightShoulder;
  static const rightElbow = PoseLandmarkType.rightElbow;
  static const rightWrist = PoseLandmarkType.rightWrist;
  static const leftHip = PoseLandmarkType.leftHip;
  static const leftKnee = PoseLandmarkType.leftKnee;
  static const leftAnkle = PoseLandmarkType.leftAnkle;
  static const rightHip = PoseLandmarkType.rightHip;
  static const rightKnee = PoseLandmarkType.rightKnee;
  static const rightAnkle = PoseLandmarkType.rightAnkle;
  static const nose = PoseLandmarkType.nose;

  static const List<List<PoseLandmarkType>> boneConnections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];
}
