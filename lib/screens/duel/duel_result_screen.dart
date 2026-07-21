import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DuelResultScreen extends StatefulWidget {
  const DuelResultScreen({super.key});

  @override
  State<DuelResultScreen> createState() => _DuelResultScreenState();
}

class _DuelResultScreenState extends State<DuelResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatAnim;
  late Animation<double> _floatCurve;
  double _xpProgress = 0.0;
  bool _showLevelAlert = false;

  @override
  void initState() {
    super.initState();
    _floatAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatCurve = CurvedAnimation(parent: _floatAnim, curve: Curves.easeInOut);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _xpProgress = 1.0);
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() => _showLevelAlert = true);
      });
    });
  }

  @override
  void dispose() {
    _floatAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Stack(
        children: [
          // Background particles + gradient
          const Positioned.fill(child: _VictoryBackground()),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      Color(0x2639FF6A),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildVictoryTitle(),
                          const SizedBox(height: 32),
                          _buildRepsComparison(),
                          const SizedBox(height: 16),
                          _buildXpCard(),
                          const SizedBox(height: 16),
                          _buildDetailRow(),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _buildBottomNav(),
              ],
            ),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(Icons.person, size: 22, color: Color(0xFF6CFF80)),
              ),
              const SizedBox(width: 12),
              Text(
                'FITDUEL',
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
              '12🔥',
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

  // ─── Victory Title ───────────────────────────────
  Widget _buildVictoryTitle() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatCurve,
          builder: (_, child) {
            return Transform.translate(
              offset: Offset(0, -8 * _floatCurve.value),
              child: child,
            );
          },
          child: Text(
            'VICTORY',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 64,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.04,
              color: const Color(0xFF6CFF80),
              shadows: [
                Shadow(
                  color: const Color(0xFF39FF6A).withAlpha(153),
                  blurRadius: 20,
                ),
                Shadow(
                  color: const Color(0xFF39FF6A).withAlpha(77),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CHALLENGE COMPLETE',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFBACBB6),
          ),
        ),
      ],
    );
  }

  // ─── Reps Comparison ─────────────────────────────
  Widget _buildRepsComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF6A).withAlpha(51),
            blurRadius: 15,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Green accent bar
          Positioned(
            top: 0, left: 0,
            child: Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6CFF80),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF6A).withAlpha(128),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR SCORE',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '54',
                          style: TextStyle(
                            fontFamily: 'ArchivoNarrow',
                            fontSize: 64,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.04,
                            color: const Color(0xFF6CFF80),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'REPS',
                          style: TextStyle(
                            fontFamily: 'ArchivoNarrow',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6CFF80),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'OPPONENT',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFBACBB6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '48',
                          style: TextStyle(
                            fontFamily: 'ArchivoNarrow',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF568DFF),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'REPS',
                          style: TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF568DFF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── XP & Level Card ─────────────────────────────
  Widget _buildXpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.military_tech_rounded,
                      color: const Color(0xFF6CFF80), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'LEVEL 24',
                    style: TextStyle(
                      fontFamily: 'ArchivoNarrow',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE5E2E1),
                    ),
                  ),
                ],
              ),
              Text(
                '+250 XP EARNED',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF353534),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _xpProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6CFF80), Color(0xFF00E556)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF6A).withAlpha(128),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Level alert
          AnimatedOpacity(
            opacity: _showLevelAlert ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6CFF80).withAlpha(26),
                  border: Border.all(
                    color: const Color(0xFF6CFF80).withAlpha(77),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: const Color(0xFF6CFF80), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'NEW LEVEL REACHED!',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6CFF80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Detail Row ──────────────────────────────────
  Widget _buildDetailRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEART RATE',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '164',
                      style: TextStyle(
                        fontFamily: 'ArchivoNarrow',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'BPM',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFBACBB6),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DURATION',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '10:00',
                      style: TextStyle(
                        fontFamily: 'ArchivoNarrow',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MIN',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFBACBB6),
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

  // ─── Action Buttons ──────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.restart_alt_rounded, size: 20),
            label: Text(
              'REMATCH',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6CFF80),
              foregroundColor: const Color(0xFF00390F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded, size: 20),
            label: Text(
              'SHARE RESULT',
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6CFF80),
              side: const BorderSide(color: Color(0xFF6CFF80), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav ──────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        border: const Border(
          top: BorderSide(color: Color(0xFF353534)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF6A).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, false, () {}),
              _navItem(Icons.leaderboard_rounded, true, () {}),
              _navItem(Icons.fitness_center_rounded, false, () {}),
              _navItem(Icons.person_rounded, false, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF39FF6A).withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF39FF6A).withAlpha(100),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: active
              ? const Color(0xFF39FF6A)
              : const Color(0xFFBACBB6),
          size: 28,
        ),
      ),
    );
  }
}

// ─── Background Particles ─────────────────────────────
class _VictoryBackground extends StatefulWidget {
  const _VictoryBackground();

  @override
  State<_VictoryBackground> createState() => _VictoryBackgroundState();
}

class _VictoryBackgroundState extends State<_VictoryBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(_rng));
    }
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    setState(() {
      for (final p in _particles) {
        p.update();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(_particles),
      size: Size.infinite,
    );
  }
}

class _Particle {
  late double x, y, size, speedY, opacity;

  _Particle(Random rng) {
    x = rng.nextDouble() * 1000;
    y = rng.nextDouble() * 1000;
    size = rng.nextDouble() * 2 + 1;
    speedY = rng.nextDouble() * 0.5 + 0.2;
    opacity = rng.nextDouble() * 0.5 + 0.2;
  }

  void update() {
    y -= speedY;
    if (y < -10) {
      y = 1000;
      x = Random().nextDouble() * 1000;
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF39FF6A);
    for (final p in particles) {
      paint.color = paint.color.withAlpha((p.opacity * 255).round());
      canvas.drawCircle(Offset(p.x * size.width / 1000, p.y * size.height / 1000), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
