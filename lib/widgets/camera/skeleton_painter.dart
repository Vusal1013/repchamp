import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/constants/pose_landmarks.dart';
import '../../core/theme/app_colors.dart';

class SkeletonPainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize;

  SkeletonPainter({required this.pose, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null) return;

    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final haloPaint = Paint()
      ..color = AppColors.accent.withAlpha(80)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final scale = min(scaleX, scaleY);

    final offsetX = (size.width - imageSize.width * scale) / 2;
    final offsetY = (size.height - imageSize.height * scale) / 2;

    Offset transform(PoseLandmark lm) {
      return Offset(lm.x * scale + offsetX, lm.y * scale + offsetY);
    }

    for (final connection in PoseLandmarks.boneConnections) {
      final start = pose!.landmarks[connection[0]];
      final end = pose!.landmarks[connection[1]];
      if (start != null && end != null) {
        canvas.drawLine(transform(start), transform(end), paint);
      }
    }

    for (final entry in pose!.landmarks.entries) {
      final lm = entry.value;
      final pos = transform(lm);

      canvas.drawCircle(pos, 8.0, haloPaint);
      canvas.drawCircle(pos, 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.imageSize != imageSize;
  }
}
