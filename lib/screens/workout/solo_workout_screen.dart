import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise_type.dart';
import '../../providers/pose_detection_provider.dart';
import '../../providers/rep_counter_provider.dart';
import '../../widgets/camera/camera_preview_widget.dart';
import '../../widgets/common/rep_counter_display.dart';

class SoloWorkoutScreen extends ConsumerStatefulWidget {
  const SoloWorkoutScreen({super.key});

  @override
  ConsumerState<SoloWorkoutScreen> createState() => _SoloWorkoutScreenState();
}

class _SoloWorkoutScreenState extends ConsumerState<SoloWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    _setupWorkout();
  }

  Future<void> _setupWorkout() async {
    final extra = GoRouterState.of(context).extra;
    final exerciseStr = extra is String ? extra : 'push_up';
    final exerciseType = ExerciseType.fromDatabase(exerciseStr);

    final service = ref.read(poseDetectionServiceProvider);
    final repNotifier = ref.read(repCounterProvider.notifier);

    await service.initializeCamera(
      resolution: ResolutionPreset.medium,
      lens: CameraLensDirection.front,
    );

    ref.read(cameraInitializedProvider.notifier).state = true;

    repNotifier.initialize(exerciseType);

    service.startProcessing(
      onPoseDetected: (Pose? pose) {
        if (pose == null) return;
        ref.read(poseProvider.notifier).state = pose;
        repNotifier.processPose(pose);
      },
    );
  }

  void _endWorkout() {
    final repCount = ref.read(repCounterProvider.notifier).repCount;
    final extra = GoRouterState.of(context).extra;
    final exerciseStr = extra is String ? extra : 'push_up';

    ref.read(poseDetectionServiceProvider).dispose();
    ref.read(poseProvider.notifier).state = null;
    ref.read(cameraInitializedProvider.notifier).state = false;
    ref.read(repCounterProvider.notifier).reset();

    context.push('/workout/summary', extra: {
      'exercise_type': exerciseStr,
      'rep_count': repCount,
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repState = ref.watch(repCounterProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CameraPreviewWidget(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(120),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              GoRouterState.of(context).extra is String
                  ? (GoRouterState.of(context).extra as String).replaceAll('_', ' ').toUpperCase()
                  : 'PUSH UP',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 3,
              ),
            ),
          ),
          Center(
            child: RepCounterDisplay(repCount: repState.repCount),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _endWorkout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'GIVE UP',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
