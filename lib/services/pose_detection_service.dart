import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/constants/exercise_thresholds.dart';

class PoseDetectionService {
  PoseDetector? _poseDetector;
  CameraController? _cameraController;
  bool _isProcessing = false;
  int _frameCount = 0;

  PoseDetectionService() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
      ),
    );
  }

  CameraController? get cameraController => _cameraController;

  Future<CameraController> initializeCamera({
    required ResolutionPreset resolution,
    required CameraLensDirection lens,
  }) async {
    final cameras = await availableCameras();
    final selectedCamera = cameras.firstWhere(
      (c) => c.lensDirection == lens,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      selectedCamera,
      resolution,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    return _cameraController!;
  }

  void startProcessing({
    required void Function(Pose? pose) onPoseDetected,
  }) {
    _cameraController?.startImageStream((CameraImage image) {
      _frameCount++;
      if (_frameCount % ExerciseThresholds.frameThrottleInterval != 0) return;
      if (_isProcessing) return;

      _isProcessing = true;
      _processImage(image, onPoseDetected);
    });
  }

  Future<void> _processImage(
    CameraImage image,
    void Function(Pose? pose) onPoseDetected,
  ) async {
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector!.processImage(inputImage);
      onPoseDetected(poses.isNotEmpty ? poses.first : null);
    } catch (_) {
      onPoseDetected(null);
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      rotation = InputImageRotation.values.firstWhere(
        (r) => r.rawValue == sensorOrientation,
        orElse: () => InputImageRotation.rotation0deg,
      );
    } else {
      rotation = InputImageRotation.rotation0deg;
    }

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == image.format.group,
      orElse: () => InputImageFormat.nv21,
    );

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _poseDetector?.close();
    _poseDetector = null;
  }
}
