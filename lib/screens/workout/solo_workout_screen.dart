import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../models/exercise_type.dart';
import '../../providers/pose_detection_provider.dart';
import '../../providers/rep_counter_provider.dart';
import '../../services/form_analyzer.dart';
import '../../services/voice_coach_service.dart';
import '../../widgets/camera/camera_preview_widget.dart';


class SoloWorkoutScreen extends ConsumerStatefulWidget {
  const SoloWorkoutScreen({super.key});

  @override
  ConsumerState<SoloWorkoutScreen> createState() => _SoloWorkoutScreenState();
}

class _SoloWorkoutScreenState extends ConsumerState<SoloWorkoutScreen> {
  final VoiceCoachService _coach = VoiceCoachService();
  final FormAnalyzer _formAnalyzer = FormAnalyzer();
  int _remainingSeconds = 120;
  Timer? _timer;
  ExerciseType _exerciseType = ExerciseType.pushUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      final exerciseStr = extra?['exercise'] as String? ?? 'push_up';
      _exerciseType = ExerciseType.fromDatabase(exerciseStr);
      _startWorkout();
    });
  }

  Future<void> _startWorkout() async {
    final service = ref.read(poseDetectionServiceProvider);
    final repNotifier = ref.read(repCounterProvider.notifier);

    await service.initializeCamera(
      resolution: ResolutionPreset.medium,
      lens: CameraLensDirection.front,
    );

    ref.read(cameraInitializedProvider.notifier).state = true;
    repNotifier.initialize(_exerciseType);

    service.startProcessing(
      onPoseDetected: (Pose? pose) {
        if (pose == null) return;
        ref.read(poseProvider.notifier).state = pose;
        repNotifier.processPose(pose);

        final state = ref.read(repCounterProvider);
        if (state.repCount > 0) {
          _coach.onRep(state.repCount, 50);
        }

        final warning = _formAnalyzer.analyze(pose, _exerciseType);
        if (warning != null) {
          _coach.onFormWarning(warning);
          if (mounted) setState(() {});
        }
      },
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _endWorkout();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _endWorkout() {
    final repCount = ref.read(repCounterProvider).repCount;
    ref.read(poseDetectionServiceProvider).dispose();
    ref.read(poseProvider.notifier).state = null;
    ref.read(cameraInitializedProvider.notifier).state = false;
    ref.read(repCounterProvider.notifier).reset();

    if (mounted) {
      context.push('/workout/summary', extra: {
        'rep_count': repCount,
        'exercise_type': _exerciseType.databaseValue,
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coach.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repState = ref.watch(repCounterProvider);
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Camera feed
          const CameraPreviewWidget(),
          // Gradient vignette
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x990A0A0A),
                      Colors.transparent,
                      const Color(0x990A0A0A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Skeleton overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SkeletonPainter()),
            ),
          ),
          // HUD
          SafeArea(
            child: Column(
              children: [
                // Top: Timer + Exercise + Close
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimer(timeStr),
                      Column(
                        children: [
                          Text(
                            _exerciseType.displayName.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6CFF80),
                            ),
                          ),
                        ],
                      ),
                      _CloseButton(onPressed: _endWorkout),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Center: Rep counter
                _buildRepCounter(repState),
                // Form warning
                if (repState.formWarning != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB4AB).withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFB4AB).withAlpha(77)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: const Color(0xFFFFB4AB), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            repState.formWarning!,
                            style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(flex: 1),
                // Bottom: Stats
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _StatsGrid(),
                ),
                SizedBox(height: isDesktop ? 24 : 80),
              ],
            ),
          ),
          // Coach sidebar
          if (isDesktop)
            Positioned(
              left: 24, top: 0, bottom: 0,
              child: Center(
                child: _buildCoachSidebar(repState),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimer(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x990A0A0A),
        border: Border.all(color: Colors.white.withAlpha(26)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: const Color(0xFF6CFF80)),
              const SizedBox(width: 6),
              Text(
                'DURATION',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(150),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
              color: _remainingSeconds <= 10 ? const Color(0xFFFFB4AB) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepCounter(RepCounterState repState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'REP COUNT',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6CFF80),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${repState.repCount}',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: MediaQuery.of(context).size.width > 768 ? 180 : 120,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.04,
            color: const Color(0xFF6CFF80),
            shadows: [
              Shadow(color: const Color(0xFF39FF6A).withAlpha(200), blurRadius: 10),
              Shadow(color: const Color(0xFF39FF6A).withAlpha(100), blurRadius: 20),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF6CFF80), width: 2),
            ),
          ),
          child: Text(
            _exerciseType.displayName.toUpperCase(),
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachSidebar(RepCounterState repState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 192,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x990A0A0A),
            border: const Border(
              left: BorderSide(color: Color(0xFF6CFF80), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COACH AI',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6CFF80),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                repState.formWarning ?? 'Keep going! Looking good!',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 192,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x990A0A0A),
            border: const Border(
              left: BorderSide(color: Color(0x330A0A0A), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEXT GOAL',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(100),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${50 - (repState.repCount % 50)} Reps to Next Milestone',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Close Button ─────────────────────────────────────
class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0x990A0A0A),
        border: Border.all(color: Colors.white.withAlpha(26)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
    );
  }
}

// ─── Stats Grid (Bottom HUD) ──────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFC70018),
            label: 'HEART RATE',
            value: '164',
            unit: 'BPM',
            barFraction: 0.75,
            barColor: const Color(0xFFC70018),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatTile(
            icon: Icons.center_focus_strong_rounded,
            iconColor: const Color(0xFF568DFF),
            label: 'FORM ACCURACY',
            value: '98',
            unit: '%',
            barFraction: 0.98,
            barColor: const Color(0xFF568DFF),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final double barFraction;
  final Color barColor;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.barFraction,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x990A0A0A),
        border: Border.all(color: Colors.white.withAlpha(13)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: barFraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Overlay Painter ────────────────────────
class _SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = const Color(0xFF6CFF80)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF6CFF80)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 1000;
    final scaleY = size.height / 1000;
    Offset s(double x, double y) => Offset(x * scaleX, y * scaleY);

    canvas.drawLine(s(500, 300), s(500, 550), greenPaint);
    canvas.drawLine(s(420, 350), s(580, 350), greenPaint);
    canvas.drawLine(s(440, 550), s(560, 550), greenPaint);

    _drawPolyline(canvas, [s(420, 350), s(350, 450), s(380, 550)], greenPaint);
    _drawPolyline(canvas, [s(580, 350), s(650, 450), s(620, 550)], greenPaint);
    _drawPolyline(canvas, [s(440, 550), s(350, 680), s(440, 850)], greenPaint);
    _drawPolyline(canvas, [s(560, 550), s(650, 680), s(560, 850)], greenPaint);

    canvas.drawCircle(s(500, 300), 6, dotPaint);
    canvas.drawCircle(s(420, 350), 4, dotPaint);
    canvas.drawCircle(s(580, 350), 4, dotPaint);
    canvas.drawCircle(s(350, 450), 4, dotPaint);
    canvas.drawCircle(s(650, 450), 4, dotPaint);
    canvas.drawCircle(s(350, 680), 8, dotPaint);
    canvas.drawCircle(s(650, 680), 8, dotPaint);
    canvas.drawCircle(s(440, 850), 4, dotPaint);
    canvas.drawCircle(s(560, 850), 4, dotPaint);
  }

  void _drawPolyline(Canvas canvas, List<Offset> points, Paint paint) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
