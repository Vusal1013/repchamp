import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Profile not found',
                              style: TextStyle(color: Color(0xFFFFB4AB))),
                          SizedBox(height: 8),
                          Text(authUser?.email ?? '',
                              style: TextStyle(color: Color(0xFFBACBB6), fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  return _buildBody(profile, authUser?.email ?? '');
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6CFF80)),
                ),
                error: (err, _) => Center(
                  child: Text('Failed to load profile',
                      style: TextStyle(color: Color(0xFFFFB4AB))),
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.profile),
          ],
        ),
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
        border: Border(bottom: BorderSide(color: Color(0xFF353534))),
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

  // ─── Body ────────────────────────────────────────
  Widget _buildBody(UserProfile profile, String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          _buildHeroSection(profile, email),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 16),
          _buildXpChart(),
          const SizedBox(height: 16),
          _buildAchievements(),
          const SizedBox(height: 16),
          _buildRecentDuels(),
        ],
      ),
    );
  }

  // ─── Hero Section ────────────────────────────────
  Widget _buildHeroSection(UserProfile profile, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6CFF80), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF39FF6A).withAlpha(77),
                      blurRadius: 30,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: const Icon(Icons.person, size: 64, color: Color(0xFF6CFF80)),
              ),
              Positioned(
                bottom: -2, right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CFF80),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFF131313), width: 2),
                  ),
                  child: Text(
                    'LVL ${profile.level}',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00390F),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '@${profile.username}',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6CFF80).withAlpha(51),
              border: Border.all(color: const Color(0xFF6CFF80).withAlpha(102)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'PRO MEMBER',
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

  // ─── Stats Grid ──────────────────────────────────
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWinRateCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildDuelsWonCard()),
          ],
        ),
        const SizedBox(height: 16),
        _buildTotalRepsCard(),
      ],
    );
  }

  Widget _buildWinRateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WIN RATE',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '58%',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.04,
              color: const Color(0xFF6CFF80),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 4,
              color: const Color(0xFF353534),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.58,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CFF80),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF6A).withAlpha(153),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuelsWonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DUELS WON',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '84',
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _stackedAvatar(const Color(0xFF568DFF)),
              _stackedAvatar(const Color(0xFFFFB3AC)),
              _stackedAvatar(const Color(0xFF00E556)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stackedAvatar(Color color) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(right: -8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF131313)),
      ),
    );
  }

  Widget _buildTotalRepsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL REPS',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFBACBB6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '12,400',
                style: TextStyle(
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
            ],
          ),
          Icon(Icons.fitness_center_rounded,
              color: const Color(0xFF6CFF80), size: 36),
        ],
      ),
    );
  }

  // ─── XP Chart ────────────────────────────────────
  Widget _buildXpChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY XP PROGRESS',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
              Text(
                '+2,450 XP',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 128,
            child: CustomPaint(
              size: const Size(double.infinity, 128),
              painter: _ChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['MON', 'WED', 'FRI', 'SUN'].map((day) {
              return Text(
                day,
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFBACBB6),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Achievements ────────────────────────────────
  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _achieveCard(Icons.local_fire_department_rounded, '7 DAY\nSTREAK')),
            const SizedBox(width: 16),
            Expanded(child: _achieveCard(Icons.workspace_premium_rounded, 'FIRST\nWIN')),
            const SizedBox(width: 16),
            Expanded(child: _achieveCard(Icons.military_tech_rounded, '1000\nCLUB')),
          ],
        ),
      ],
    );
  }

  Widget _achieveCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF353534)),
            ),
            child: Icon(icon, color: const Color(0xFF6CFF80), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Duels ────────────────────────────────
  Widget _buildRecentDuels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'RECENT DUELS',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
            ),
          ),
        ),
        _duelItem(true, '@ShadowFit', 'Squat Duel', '2h ago', '+50 RP'),
        const SizedBox(height: 4),
        _duelItem(false, '@IronWill', 'Pushup Duel', '1d ago', '-20 RP'),
      ],
    );
  }

  Widget _duelItem(bool won, String opponent, String type, String time, String rp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: won
                  ? const Color(0xFF6CFF80).withAlpha(26)
                  : const Color(0xFF353534),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              won ? Icons.emoji_events_rounded : Icons.close_rounded,
              color: won ? const Color(0xFF6CFF80) : const Color(0xFFBACBB6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${won ? 'Won' : 'Lost'} vs $opponent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE5E2E1),
                  ),
                ),
                Text(
                  '$type • $time',
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
          Text(
            rp,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: won ? const Color(0xFF6CFF80) : const Color(0xFFBACBB6),
            ),
          ),
        ],
      ),
    );
  }

}

// ─── Chart Painter ───────────────────────────────────
class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dataPoints = [0.8, 0.7, 0.85, 0.4, 0.55, 0.2, 0.35, 0.1, 0.15];
    final dx = size.width / (dataPoints.length - 1);

    final path = Path();
    path.moveTo(0, size.height * dataPoints[0]);

    for (int i = 1; i < dataPoints.length; i++) {
      path.lineTo(dx * i, size.height * dataPoints[i]);
    }

    // Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFF39FF6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF39FF6A).withAlpha(51),
          const Color(0xFF39FF6A).withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
