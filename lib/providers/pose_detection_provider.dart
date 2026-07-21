import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detection_service.dart';

final poseDetectionServiceProvider = Provider<PoseDetectionService>((ref) {
  final service = PoseDetectionService();
  ref.onDispose(() => service.dispose());
  return service;
});

final poseProvider = StateProvider<Pose?>((ref) => null);

final cameraInitializedProvider = StateProvider<bool>((ref) => false);

final isProcessingProvider = StateProvider<bool>((ref) => false);
