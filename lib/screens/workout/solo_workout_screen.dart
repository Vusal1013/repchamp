import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SoloWorkoutScreen extends StatefulWidget {
  const SoloWorkoutScreen({super.key});

  @override
  State<SoloWorkoutScreen> createState() => _SoloWorkoutScreenState();
}

class _SoloWorkoutScreenState extends State<SoloWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Full screen background (camera placeholder)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF1A1A1A),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.videocam_rounded,
                  size: 64,
                  color: Colors.white.withAlpha(30),
                ),
              ),
            ),
          ),
          // Vignette gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x990A0A0A),
                    Colors.transparent,
                    Color(0x990A0A0A),
                  ],
                ),
              ),
            ),
          ),
          // Skeleton overlay (simplified SVG-like)
          Positioned.fill(
            child: CustomPaint(
              painter: _SkeletonPainter(),
            ),
          ),
          // HUD Layer
          SafeArea(
            child: Column(
              children: [
                // Top header: Timer + Close
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TimerWidget(),
                      _CloseButton(),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Center: Rep counter
                const _RepCounterHUD(),
                const Spacer(flex: 1),
                // Bottom: Stats grid
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _StatsGrid(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Left sidebar: Coach AI (desktop only)
          if (MediaQuery.of(context).size.width > 1024)
            const Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CoachSidebar(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Timer ────────────────────────────────────────────
class _TimerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.timer_outlined, size: 18, color: AppColors.accent),
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
          const Text(
            '01:45',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Close Button ─────────────────────────────────────
class _CloseButton extends StatelessWidget {
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
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
    );
  }
}

// ─── Rep Counter (Center HUD) ─────────────────────────
class _RepCounterHUD extends StatelessWidget {
  const _RepCounterHUD();

  @override
  Widget build(BuildContext context) {
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
          '42',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: MediaQuery.of(context).size.width > 768 ? 180 : 120,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.04,
            color: AppColors.accent,
            shadows: [
              Shadow(color: AppColors.accent.withAlpha(200), blurRadius: 10),
              Shadow(color: AppColors.accent.withAlpha(100), blurRadius: 20),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          child: Text(
            'SQUATS',
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
}

// ─── Stats Grid (Bottom HUD) ──────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.8,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _StatTile(
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFC70018),
          label: 'HEART RATE',
          value: '164',
          unit: 'BPM',
          barFraction: 0.75,
          barColor: const Color(0xFFC70018),
        ),
        _StatTile(
          icon: Icons.center_focus_strong_rounded,
          iconColor: const Color(0xFF568DFF),
          label: 'FORM ACCURACY',
          value: '98',
          unit: '%',
          barFraction: 0.98,
          barColor: const Color(0xFF568DFF),
        ),
        if (isDesktop)
          _StatTile(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFF6CFF80),
            label: 'CALORIES',
            value: '215',
            unit: 'KCAL',
            barFraction: 0.40,
            barColor: const Color(0xFF6CFF80),
          ),
        if (isDesktop)
          _StatTile(
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFFFB3AC),
            label: 'LIVE RANK',
            value: '#04',
            unit: 'GLOBAL',
            barFraction: 0.85,
            barColor: const Color(0xFFFFB3AC),
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

// ─── Coach Sidebar ────────────────────────────────────
class _CoachSidebar extends StatelessWidget {
  const _CoachSidebar();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 192,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x990A0A0A),
            border: const Border(
              left: BorderSide(color: AppColors.accent, width: 4),
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
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Keep your chest up. Looking good!',
                style: TextStyle(
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
              const Text(
                '50 Reps to Level Up',
                style: TextStyle(
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

// ─── Skeleton Overlay Painter ────────────────────────
class _SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Scale to viewBox 1000x1000
    final scaleX = size.width / 1000;
    final scaleY = size.height / 1000;
    final s = (a, b) => Offset(a * scaleX, b * scaleY);

    // Torso
    canvas.drawLine(s(500, 300), s(500, 550), greenPaint);
    canvas.drawLine(s(420, 350), s(580, 350), greenPaint);
    canvas.drawLine(s(440, 550), s(560, 550), greenPaint);

    // Arms
    _drawPolyline(canvas, [s(420, 350), s(350, 450), s(380, 550)], greenPaint);
    _drawPolyline(canvas, [s(580, 350), s(650, 450), s(620, 550)], greenPaint);

    // Legs (squat pose)
    _drawPolyline(canvas, [s(440, 550), s(350, 680), s(440, 850)], greenPaint);
    _drawPolyline(canvas, [s(560, 550), s(650, 680), s(560, 850)], greenPaint);

    // Joints
    _drawJoint(canvas, s(500, 300), 6, dotPaint); // Neck
    canvas.drawCircle(s(420, 350), 4, dotPaint); // L Shoulder
    canvas.drawCircle(s(580, 350), 4, dotPaint); // R Shoulder
    canvas.drawCircle(s(350, 450), 4, dotPaint); // L Elbow
    canvas.drawCircle(s(650, 450), 4, dotPaint); // R Elbow
    _drawJoint(canvas, s(350, 680), 8, dotPaint); // L Knee
    _drawJoint(canvas, s(650, 680), 8, dotPaint); // R Knee
    canvas.drawCircle(s(440, 850), 4, dotPaint); // L Ankle
    canvas.drawCircle(s(560, 850), 4, dotPaint); // R Ankle
  }

  void _drawPolyline(Canvas canvas, List<Offset> points, Paint paint) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  void _drawJoint(Canvas canvas, Offset center, double radius, Paint paint) {
    final glowPaint = Paint()
      ..color = AppColors.accent.withAlpha(80)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.5, glowPaint);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
