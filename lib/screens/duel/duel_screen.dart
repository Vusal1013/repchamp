import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../models/exercise_type.dart';
import '../../providers/duel_provider.dart';
import '../../providers/pose_detection_provider.dart';
import '../../providers/rep_counter_provider.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/camera/camera_preview_widget.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class DuelScreen extends ConsumerStatefulWidget {
  const DuelScreen({super.key});

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen>
    with SingleTickerProviderStateMixin {
  bool _duelActive = false;
  bool _isSoloMode = false;
  int _remainingSeconds = 60;
  Timer? _countdownTimer;
  late AnimationController _skeletonAnim;
  double _skeletonOpacity = 0.5;
  Timer? _skeletonTimer;

  @override
  void initState() {
    super.initState();
    _skeletonAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat();

    _skeletonTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      setState(() {
        _skeletonOpacity = 0.2 + 0.4 * (_skeletonAnim.value);
      });
    });

    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra['soloMode'] == true) {
      _isSoloMode = true;
    }

    _setupDuel();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 10) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _remainingSeconds--);
      }
      if (_remainingSeconds <= 0) {
        _countdownTimer?.cancel();
        _onTimerEnd();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _skeletonAnim.dispose();
    _skeletonTimer?.cancel();
    super.dispose();
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
    if (!_duelActive || _isSoloMode) return;
    final duelService = ref.read(duelServiceProvider);
    final roomId = ref.read(duelRoomIdProvider);
    final userId = ref.read(currentUserIdProvider);
    final reps = ref.read(repCounterProvider.notifier).repCount;

    if (roomId != null && userId != null) {
      await duelService.updateRepCount(roomId, userId, reps);
    }
  }

  Future<void> _onTimerEnd() async {
    final reps = ref.read(repCounterProvider.notifier).repCount;

    if (_isSoloMode) {
      ref.read(poseDetectionServiceProvider).dispose();
      ref.read(poseProvider.notifier).state = null;
      ref.read(cameraInitializedProvider.notifier).state = false;
      ref.read(repCounterProvider.notifier).reset();

      if (mounted) {
        context.push('/duel/result', extra: {
          'winner_id': ref.read(currentUserIdProvider),
          'my_reps': reps,
          'opponent_reps': 0,
          'opponent_name': 'BOT',
          'room_id': 'solo_test',
          'my_user_id': ref.read(currentUserIdProvider),
        });
      }
      return;
    }

    final duelService = ref.read(duelServiceProvider);
    final roomId = ref.read(duelRoomIdProvider);
    final userId = ref.read(currentUserIdProvider);

    if (roomId == null || userId == null) return;

    await duelService.updateRepCount(roomId, userId, reps);
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await duelService.finishDuel(roomId);
    final winnerId = result['winner'];

    final isWinner = userId == winnerId;
    await duelService.saveDuelResults(roomId, userId, reps, 60, xpEarned: isWinner ? 30 : 0);

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

  @override
  Widget build(BuildContext context) {
    final opponentPlayer = _isSoloMode ? null : ref.watch(opponentPlayerProvider);
    final repState = ref.watch(repCounterProvider);

    final myReps = repState.repCount;
    final opponentReps = opponentPlayer?.reps ?? 0;

    if (!_duelActive) {
      _duelActive = true;
    }

    _syncReps();

    final total = (myReps + opponentReps).toDouble();
    final myFraction = total > 0 ? myReps / total : 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed
          const CameraPreviewWidget(),

          // Skeleton overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SkeletonPainter(opacity: _skeletonOpacity),
              ),
            ),
          ),

          // Scanline
          const Positioned.fill(
            child: IgnorePointer(
              child: _ScanlineOverlay(),
            ),
          ),

          // Gradient vignette
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
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
            ),
          ),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildHeader(),
          ),

          // Battle bar
          Positioned(
            top: 72, left: 20, right: 20,
            child: _buildBattleBar(myFraction, opponentReps, opponentPlayer, _isSoloMode),
          ),

          // Middle stats
          Positioned(
            top: 136, left: 20, right: 20,
            child: _buildMiddleStats(myReps, opponentReps),
          ),

          // Bottom biometrics
          Positioned(
            bottom: 96, left: 20, right: 20,
            child: _buildBiometrics(),
          ),

          // Floating message
          Positioned(
            bottom: 168, left: 0, right: 0,
            child: _buildFloatingMessage(myReps, opponentReps),
          ),

          // Bottom nav
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: FitDuelBottomNav(activeTab: NavTab.duel),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(
          bottom: BorderSide(color: Color(0xFF353534)),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E556), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(Icons.person, size: 18, color: Color(0xFF00E556)),
              ),
              const SizedBox(width: 12),
              Text(
                'REPCHAMP',
                style: TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.01,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color(0xFF353534)),
            ),
          child: Text(
            '${ref.watch(streakProvider)}🔥',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6CFF80),
            ),
          ),
          ),
        ],
      ),
    );
  }

  // ─── Battle Bar ──────────────────────────────────
  Widget _buildBattleBar(double myFraction, int opponentReps, dynamic opponentPlayer, bool soloMode) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F).withAlpha(102),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Green bar (YOU)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: FractionallySizedBox(
                widthFactor: myFraction,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x3300E556), Color(0xFF6CFF80)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF6A).withAlpha(77),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Blue bar (OPPONENT)
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: FractionallySizedBox(
                widthFactor: 1.0 - myFraction,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF568DFF), Color(0x33568DFF)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF568DFF).withAlpha(77),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // VS indicator
            Positioned(
              left: myFraction * MediaQuery.of(context).size.width - 40,
              top: 0, bottom: 0,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(myFraction > 0.5 ? -24 : 24, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131313),
                        border: Border.all(color: const Color(0xFFC70018)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(128),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Labels
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOU',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007226),
                      ),
                    ),
                    Text(
                      soloMode ? 'BOT' : opponentPlayer?.username?.toUpperCase() ?? 'RIVAL',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF002661),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Middle Stats ────────────────────────────────
  Widget _buildMiddleStats(int myReps, int opponentReps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Your stats
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassLabel('MY REPS', const Color(0xFF6CFF80), false),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$myReps',
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.04,
                    color: const Color(0xFF6CFF80),
                    shadows: [
                      Shadow(
                        color: const Color(0xFF39FF6A).withAlpha(128),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ 50',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00E556),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Countdown center
        Column(
          children: [
            _buildTimer(),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < 2
                        ? const Color(0xFF6CFF80)
                        : const Color(0xFF353534),
                  ),
                );
              }),
            ),
          ],
        ),

        // Opponent stats
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildGlassLabel(_isSoloMode ? 'BOT' : 'OPPONENT', const Color(0xFF568DFF), true),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (!_isSoloMode)
                  Text(
                    'REPS',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB0C6FF),
                    ),
                  ),
                if (!_isSoloMode) const SizedBox(width: 4),
                Text(
                  _isSoloMode ? '--' : '$opponentReps',
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF568DFF).withAlpha(204),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassLabel(String text, Color color, bool right) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: right ? BorderSide.none : BorderSide(color: color, width: 4),
          right: right ? BorderSide(color: color, width: 4) : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ─── Timer ───────────────────────────────────────
  Widget _buildTimer() {
    final warning = _remainingSeconds <= 10;
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final display = '$mins:${secs.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: warning
            ? Colors.red.withAlpha(26)
            : const Color(0xFFC70018).withAlpha(26),
        border: Border.all(
          color: warning ? Colors.red : const Color(0xFFC70018),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontFamily: 'ArchivoNarrow',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
          color: warning ? Colors.red : const Color(0xFFC70018),
        ),
        child: Text(display),
      ),
    );
  }

  // ─── Biometrics ──────────────────────────────────
  Widget _buildBiometrics() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC70018).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFC70018),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HEART RATE',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '164',
                            style: TextStyle(
                              fontFamily: 'ArchivoNarrow',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC70018),
                            ),
                          ),
                          TextSpan(
                            text: '  BPM',
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBACBB6).withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CFF80).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.track_changes_rounded,
                    color: const Color(0xFF6CFF80),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FORM ACCURACY',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '98',
                            style: TextStyle(
                              fontFamily: 'ArchivoNarrow',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6CFF80),
                            ),
                          ),
                          TextSpan(
                            text: '  %',
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBACBB6).withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Floating Message ────────────────────────────
  Widget _buildFloatingMessage(int myReps, int opponentReps) {
    final diff = myReps - opponentReps;
    if (diff <= 0) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6CFF80).withAlpha(230),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          'KEEP PACE! YOU\'RE LEADING BY $diff',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002106),
          ),
        ),
      ),
    );
  }

}

// ─── Scanline Overlay ────────────────────────────────
class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanlinePainter(),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0xFF39FF6A).withAlpha(8)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Skeleton Painter ─────────────────────────────────
class _SkeletonPainter extends CustomPainter {
  final double opacity;

  _SkeletonPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF39FF6A).withAlpha((opacity * 128).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final sx = size.width / 100;
    final sy = size.height / 100;

    // Mock joint connectors
    final points = [
      Offset(50 * sx, 30 * sy),
      Offset(50 * sx, 50 * sy),
      Offset(40 * sx, 70 * sy),
      Offset(60 * sx, 70 * sy),
      Offset(40 * sx, 40 * sy),
      Offset(60 * sx, 40 * sy),
    ];

    // Center to hip
    canvas.drawLine(points[0], points[1], paint);
    // Hip to left leg
    canvas.drawLine(points[1], points[2], paint);
    // Hip to right leg
    canvas.drawLine(points[1], points[3], paint);
    // Shoulders
    canvas.drawLine(points[4], points[5], paint);

    // Dashed effect
    paint.color = const Color(0xFF39FF6A).withAlpha((opacity * 60).round());
    canvas.drawLine(points[4], points[0], paint);
    canvas.drawLine(points[5], points[0], paint);
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
