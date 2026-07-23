import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_type.dart';
import '../../providers/duel_matchmaking_provider.dart';
import '../../providers/duel_provider.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';
import '../../widgets/common/streak_badge.dart';

class DuelLobbyScreen extends ConsumerStatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  ConsumerState<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends ConsumerState<DuelLobbyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarAnim;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _radarAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarAnim.dispose();
    _countdownTimer?.cancel();
    ref.read(duelMatchmakingProvider.notifier).reset();
    super.dispose();
  }

  void _startMatchmaking() {
    ref.read(duelMatchmakingProvider.notifier).startSearching(ExerciseType.pushUp);
  }

  void _startCountdown() {
    ref.read(duelMatchmakingProvider.notifier).startCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(duelMatchmakingProvider);
      if (state.state == MatchmakingState.ready) {
        _countdownTimer?.cancel();
        context.push('/duel/active');
        return;
      }
      ref.read(duelMatchmakingProvider.notifier).tickCountdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(duelMatchmakingProvider);
    final opponent = ref.watch(opponentPlayerProvider);

    // Auto-detect opponent found
    if (matchState.state == MatchmakingState.searching && opponent != null) {
      ref.read(duelMatchmakingProvider.notifier).onOpponentFound(opponent);
    }

    // Auto-start countdown when both found
    if (matchState.state == MatchmakingState.found && matchState.opponent != null) {
      Future.microtask(() {
        if (ref.read(duelMatchmakingProvider).state == MatchmakingState.found) {
          _startCountdown();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Stack(
        children: [
          // HUD ambient effects
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
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
                  const Positioned.fill(child: _ScanlineOverlay()),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                if (matchState.state == MatchmakingState.idle)
                  _buildIdleState(),
                if (matchState.state == MatchmakingState.searching)
                  _buildSearchingState(),
                if (matchState.state == MatchmakingState.found ||
                    matchState.state == MatchmakingState.countdown)
                  _buildMatchFoundState(matchState),
                if (matchState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      matchState.error!,
                      style: const TextStyle(color: Color(0xFFFFB4AB)),
                    ),
                  ),
                const Spacer(),
                if (matchState.state == MatchmakingState.idle)
                  _buildStartButton(),
                if (matchState.state == MatchmakingState.idle)
                  _buildSoloButton(),
                if (matchState.state == MatchmakingState.searching)
                  _buildCancelButton(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: FitDuelBottomNav(activeTab: NavTab.duel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(bottom: BorderSide(color: Color(0xFF353534))),
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
          const StreakBadge(),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FIND A DUEL',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
            color: const Color(0xFFE5E2E1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Challenge another player\nto a real-time fitness duel',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 1.2,
            color: const Color(0xFFBACBB6),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: 120,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF353534)),
              color: const Color(0xFF1C1B1B),
            ),
            child: const Icon(
              Icons.sports_kabaddi_rounded,
              color: Color(0xFF6CFF80),
              size: 56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        SizedBox(
          width: 256,
          height: 256,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _pulsingRing(1.0, const Color(0xFF568DFF).withAlpha(40)),
              _pulsingRing(0.85, const Color(0xFF39FF6A).withAlpha(30)),
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
              Container(
                width: 256, height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534)),
                ),
              ),
              Container(
                width: 192, height: 192,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534).withAlpha(128)),
                ),
              ),
              Container(
                width: 128, height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF353534).withAlpha(80)),
                ),
              ),
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

  Widget _buildMatchFoundState(DuelMatchmakingState matchState) {
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
        _buildOpponentCard(matchState),
      ],
    );
  }

  Widget _buildOpponentCard(DuelMatchmakingState matchState) {
    final opponent = matchState.opponent;
    final opponentName = opponent?.username ?? 'NeonRival';

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
                      opponentName,
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
            Row(
              children: [
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
                      bottom: -4, right: -4,
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
                    '${matchState.countdown}s',
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

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startMatchmaking,
          icon: const Icon(Icons.search_rounded, size: 20),
          label: Text(
            'FIND MATCH',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6CFF80),
            foregroundColor: const Color(0xFF00390F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSoloButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.push('/duel/active', extra: {'soloMode': true}),
          icon: const Icon(Icons.person_outline_rounded, size: 20),
          label: Text(
            'SOLO TEST',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFBACBB6),
            side: BorderSide(color: const Color(0xFF353534)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => ref.read(duelMatchmakingProvider.notifier).reset(),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFFB4AB),
            side: BorderSide(color: const Color(0xFFFFB4AB).withAlpha(128)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
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
    return CustomPaint(painter: _ScanlinePainter());
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
