import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../providers/pose_detection_provider.dart';
import 'skeleton_painter.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(poseDetectionServiceProvider);
    final pose = ref.watch(poseProvider);
    final isInitialized = ref.watch(cameraInitializedProvider);
    final controller = service.cameraController;

    if (!isInitialized || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final imageSize = Size(
      controller.value.previewSize!.width,
      controller.value.previewSize!.height,
    );

    return ClipRRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          if (pose != null)
            CustomPaint(
              painter: SkeletonPainter(
                pose: pose,
                imageSize: imageSize,
              ),
              size: Size.infinite,
            ),
        ],
      ),
    );
  }
}
