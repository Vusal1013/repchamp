import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise_type.dart';
import '../../providers/duel_provider.dart';
import '../../providers/pose_detection_provider.dart';
import '../../providers/rep_counter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/camera/camera_preview_widget.dart';
import '../../widgets/common/duel_progress_bar.dart';
import '../../widgets/common/countdown_timer_widget.dart';
import '../../widgets/common/rep_counter_display.dart';

class DuelScreen extends ConsumerStatefulWidget {
  const DuelScreen({super.key});

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  bool _duelActive = false;

  @override
  void initState() {
    super.initState();
    _setupDuel();
  }

  Future<void> _setupDuel() async {
    final service = ref.read(poseDetectionServiceProvider);
    final repNotifier = ref.read(repCounterProvider.notifier);

    await service.initializeCamera(
      resolution: ResolutionPreset.medium,
      lens: CameraLensDirection.front,
    );

    ref.read(cameraInitializedProvider.notifier).state = true;
    repNotifier.initialize(ExerciseType.pushUp);

    service.startProcessing(
      onPoseDetected: (Pose? pose) {
        if (pose == null) return;
        ref.read(poseProvider.notifier).state = pose;
        repNotifier.processPose(pose);
      },
    );
  }

  Future<void> _syncReps() async {
    if (!_duelActive) return;
    final duelService = ref.read(duelServiceProvider);
    final roomId = ref.read(duelRoomIdProvider);
    final userId = ref.read(currentUserIdProvider);
    final reps = ref.read(repCounterProvider.notifier).repCount;

    if (roomId != null && userId != null) {
      await duelService.updateRepCount(roomId, userId, reps);
    }
  }

  Future<void> _onTimerEnd() async {
    final duelService = ref.read(duelServiceProvider);
    final roomId = ref.read(duelRoomIdProvider);
    final userId = ref.read(currentUserIdProvider);
    final reps = ref.read(repCounterProvider.notifier).repCount;

    if (roomId == null || userId == null) return;

    await duelService.updateRepCount(roomId, userId, reps);
    await Future.delayed(const Duration(milliseconds: 500));

    final winnerId = await duelService.finishDuel(roomId);

    await duelService.saveDuelResults(roomId, userId, reps, 60);

    ref.read(poseDetectionServiceProvider).dispose();
    ref.read(poseProvider.notifier).state = null;
    ref.read(cameraInitializedProvider.notifier).state = false;
    ref.read(repCounterProvider.notifier).reset();

    if (mounted) {
      context.push('/duel/result', extra: {
        'winner_id': winnerId,
        'my_reps': reps,
        'room_id': roomId,
      });
    }
  }

  void _giveUp() {
    _onTimerEnd();
  }

  @override
  Widget build(BuildContext context) {
    final myPlayer = ref.watch(myDuelPlayerProvider);
    final opponentPlayer = ref.watch(opponentPlayerProvider);
    final repState = ref.watch(repCounterProvider);

    final myReps = repState.repCount;
    final opponentReps = opponentPlayer?.reps ?? 0;

    if (!_duelActive) {
      _duelActive = true;
    }

    _syncReps();

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
                  Colors.black.withAlpha(180),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(180),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: DuelProgressBar(
              myReps: myReps,
              opponentReps: opponentReps,
              myUsername: 'You',
              opponentUsername: opponentPlayer?.username ?? 'Opponent',
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CountdownTimerWidget(
                durationSeconds: 60,
                onTimerEnd: _onTimerEnd,
              ),
            ),
          ),
          Center(
            child: RepCounterDisplay(repCount: myReps),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _giveUp,
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
