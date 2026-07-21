import 'package:flutter/material.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.home),
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
              Stack(
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
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6CFF80),
                        border: Border.all(color: const Color(0xFF131313), width: 2),
                      ),
                    ),
                  ),
                ],
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

  // ─── Greeting ────────────────────────────────────
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK,',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFBACBB6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PLAYER_01',
          style: TextStyle(
            fontFamily: 'ArchivoNarrow',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
            color: const Color(0xFFE5E2E1),
          ),
        ),
      ],
    );
  }

  // ─── Stats Row ───────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('DAILY REPS', '247', const Color(0xFF6CFF80))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('XP TODAY', '890', const Color(0xFF568DFF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('STREAK', '7🔥', const Color(0xFFFFB4AB))),
      ],
    );
  }

  Widget _statCard(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'ArchivoNarrow',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions ───────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'QUICK ACTIONS',
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
            Expanded(child: _actionCard('SOLO\nWORKOUT', Icons.person_rounded, 'Start training', () {})),
            const SizedBox(width: 12),
            Expanded(child: _actionCard('QUICK\nDUEL', Icons.sports_kabaddi_rounded, 'Challenge', () {})),
            const SizedBox(width: 12),
            Expanded(child: _actionCard('LEADER-\nBOARD', Icons.leaderboard_rounded, 'Rankings', () {})),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF353534)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6CFF80), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE5E2E1),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFBACBB6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Weekly Progress ─────────────────────────────
  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY PROGRESS',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dayBar('M', 0.6),
              _dayBar('T', 0.8),
              _dayBar('W', 0.4),
              _dayBar('T', 0.9),
              _dayBar('F', 0.3),
              _dayBar('S', 1.0),
              _dayBar('S', 0.5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayBar(String label, double fill) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF353534),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 32,
              height: 64 * fill,
              decoration: BoxDecoration(
                color: const Color(0xFF6CFF80),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF39FF6A).withAlpha(77),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFBACBB6),
          ),
        ),
      ],
    );
  }

  // ─── Recent Activity ─────────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
            ),
          ),
        ),
        _activityItem(Icons.fitness_center_rounded, 'Solo Workout', '45 reps · 12 min', '2h ago'),
        const SizedBox(height: 8),
        _activityItem(Icons.sports_kabaddi_rounded, 'Duel vs NeonRival', 'Won by 6 reps', '5h ago'),
        const SizedBox(height: 8),
        _activityItem(Icons.emoji_events_rounded, 'League Up', 'Silver III → Gold I', '1d ago'),
      ],
    );
  }

  Widget _activityItem(IconData icon, String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6CFF80).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6CFF80), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE5E2E1),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 10,
              color: const Color(0xFF859581),
            ),
          ),
        ],
      ),
    );
  }
}
