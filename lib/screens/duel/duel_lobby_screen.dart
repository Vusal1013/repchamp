import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class DuelLobbyScreen extends StatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  State<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends State<DuelLobbyScreen>
    with SingleTickerProviderStateMixin {
  bool _matchFound = false;
  int _countdown = 4;
  Timer? _matchTimer;
  Timer? _countdownTimer;
  late AnimationController _radarAnim;

  @override
  void initState() {
    super.initState();
    _radarAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Simulate match found after 3.5s
    _matchTimer = Timer(const Duration(milliseconds: 3500), () {
      setState(() => _matchFound = true);
      _startCountdown();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        // GO! transition would happen here
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    _countdownTimer?.cancel();
    _radarAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Stack(
        children: [
          // HUD ambient effects
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // Pulse aura
                  Center(
                    child: AnimatedBuilder(
                      animation: _radarAnim,
                      builder: (_, child) {
                        return Container(
                          width: 600,
                          height: 600,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF568DFF).withAlpha(30),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Scanline
                  const Positioned.fill(
                    child: _ScanlineOverlay(),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const Spacer(),
                // Matchmaking header + radar
                if (!_matchFound) _buildSearchingState(),
                if (_matchFound) _buildMatchFoundState(),
                const Spacer(),
                // Bottom button
                if (!_matchFound) _buildInviteButton(),
                if (_matchFound) const SizedBox(height: 300),
              ],
            ),
          ),

          // Bottom nav
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
          // Avatar + username
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80), width: 2),
                ),
                child: const Icon(Icons.person, size: 18, color: Color(0xFF6CFF80)),
              ),
              const SizedBox(width: 8),
              Text(
                'PLAYER_01',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Title
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
          const Spacer(),
          // Streak
          Text(
            '12🔥',
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
    );
  }

  // ─── Searching State ──────────────────────────────
  Widget _buildSearchingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status text
        Text(
          'MATCHMAKING ACTIVE',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF568DFF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'FINDING OPPONENT',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
            color: const Color(0xFFE5E2E1),
          ),
        ),
        const SizedBox(height: 48),
        // Radar animation
        SizedBox(
          width: 256,
          height: 256,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer rings
              _pulsingRing(1.0, const Color(0xFF568DFF).withAlpha(40)),
              _pulsingRing(0.85, const Color(0xFF39FF6A).withAlpha(30)),
              // Rotating sweep (conic gradient)
              AnimatedBuilder(
                animation: _radarAnim,
                builder: (_, __) {
                  return Transform.rotate(
                    angle: _radarAnim.value * 2 * 3.14159,
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          startAngle: 0,
                          endAngle: 0.25,
                          colors: [
                            Colors.transparent,
                            Color(0x6639FF6A),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Static rings
              Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534)),
                ),
              ),
              Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534).withAlpha(128)),
                ),
              ),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534).withAlpha(80)),
                ),
              ),
              // Center icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF353534),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF39FF6A).withAlpha(128),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF6CFF80),
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pulsingRing(double scaleFactor, Color color) {
    return AnimatedBuilder(
      animation: _radarAnim,
      builder: (_, __) {
        final pulse = 1.0 + 0.05 * (_radarAnim.value * 4 % 1.0);
        return Transform.scale(
          scale: scaleFactor * pulse,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        );
      },
    );
  }

  // ─── Match Found State ───────────────────────────
  Widget _buildMatchFoundState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'OPPONENT FOUND!',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00E556),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MATCH READY',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
            color: const Color(0xFF6CFF80),
          ),
        ),
        const SizedBox(height: 24),
        // Opponent card
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 600),
          curve: const Cubic(0.16, 1.0, 0.3, 1.0),
          builder: (_, value, child) {
            return Transform.translate(
              offset: Offset(0, value * 200),
              child: Opacity(opacity: 1.0 - value, child: child),
            );
          },
          child: _buildOpponentCard(),
        ),
      ],
    );
  }

  Widget _buildOpponentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E556).withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: name + level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPPONENT FOUND!',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00E556),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NeonRival',
                      style: TextStyle(
                        fontFamily: 'ArchivoNarrow',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353534),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LVL 15',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE5E2E1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Opponent avatar + stats
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF353534)),
                        color: const Color(0xFF1C1B1B),
                      ),
                      child: const Icon(Icons.person, size: 40, color: Color(0xFF568DFF)),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF39FF6A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00390F),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'WIN RATE',
                            style: TextStyle(
                              fontFamily: 'SpaceMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBACBB6),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '64%',
                            style: TextStyle(
                              fontFamily: 'ArchivoNarrow',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF39FF6A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF353534),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.64,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF39FF6A),
                              borderRadius: BorderRadius.circular(2),
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
                      const SizedBox(height: 4),
                      Text(
                        'TOTAL DUELS: 142',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFBACBB6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preparing match status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1B1B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6CFF80),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6CFF80).withAlpha(128),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PREPARING MATCH...',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE5E2E1),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_countdown}s',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFBACBB6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Invite Button ────────────────────────────────
  Widget _buildInviteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: Text(
          'INVITE A FRIEND',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF568DFF),
          side: const BorderSide(color: Color(0xFF568DFF), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
