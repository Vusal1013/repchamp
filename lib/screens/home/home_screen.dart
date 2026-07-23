import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/streak_provider.dart';
import '../../services/supabase/dashboard_service.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';
import '../../widgets/common/streak_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyStats = ref.watch(dailyStatsProvider);
    final weeklyBreakdown = ref.watch(weeklyBreakdownProvider);
    final recentActivity = ref.watch(recentActivityProvider);
    final authUser = ref.watch(currentUserProvider);

    final username = authUser?.userMetadata?['username'] as String? ?? 'PLAYER_01';

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(username),
                    const SizedBox(height: 24),
                    _buildStatsRow(dailyStats, ref),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(weeklyBreakdown),
                    const SizedBox(height: 24),
                    _buildRecentActivity(recentActivity),
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

  Widget _buildHeader(BuildContext context) {
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
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/friends'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF201F1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF353534)),
              ),
              child: const Icon(Icons.people_rounded, color: Color(0xFF6CFF80), size: 20),
            ),
          ),
          const SizedBox(width: 8),
          const StreakBadge(),
        ],
      ),
    );
  }

  Widget _buildGreeting(String username) {
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
          username.toUpperCase(),
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

  Widget _buildStatsRow(AsyncValue<DailyStats?> dailyStatsAsync, WidgetRef ref) {
    final dailyStats = dailyStatsAsync.valueOrNull;
    final dailyReps = dailyStats?.totalReps ?? 0;
    final dailyXp = dailyStats?.totalXp ?? 0;

    return Row(
      children: [
        Expanded(child: _statCard('DAILY REPS', '$dailyReps', const Color(0xFF6CFF80))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('XP TODAY', '$dailyXp', const Color(0xFF568DFF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('STREAK', '${ref.watch(streakProvider)}🔥', const Color(0xFFFFB4AB))),
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

  Widget _buildQuickActions(BuildContext context) {
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
            Expanded(child: _actionCard('SOLO\nWORKOUT', Icons.person_rounded, 'Start training', () => context.push('/workout/select'))),
            const SizedBox(width: 12),
            Expanded(child: _actionCard('QUICK\nDUEL', Icons.sports_kabaddi_rounded, 'Challenge', () => context.push('/duel/lobby'))),
            const SizedBox(width: 12),
            Expanded(child: _actionCard('CHALLENGES', Icons.emoji_events_rounded, 'Weekly', () => context.push('/challenges'))),
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

  Widget _buildWeeklyProgress(AsyncValue<WeeklyBreakdown> weeklyAsync) {
    final weekly = weeklyAsync.valueOrNull;
    final totalXp = weekly?.totalXp ?? 0;
    final dailyXp = weekly?.dailyXp ?? List.filled(7, 0);
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

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
                '+${_formatXp(totalXp)} XP',
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
            children: List.generate(7, (i) => _dayBar(labels[i], dailyXp[i])),
          ),
        ],
      ),
    );
  }

  String _formatXp(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  Widget _dayBar(String label, int xp) {
    final fill = (xp / 1000).clamp(0.0, 1.0);
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

  Widget _buildRecentActivity(AsyncValue<List<RecentActivityItem>> activityAsync) {
    final activity = activityAsync.valueOrNull ?? [];

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
        if (activity.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No activity yet. Start your first workout!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFFBACBB6),
              ),
            ),
          )
        else
          ...activity.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _activityItem(item),
          )),
      ],
    );
  }

  Widget _activityItem(RecentActivityItem item) {
    final icon = _iconForExercise(item.exerciseType);
    final title = _titleForExercise(item.exerciseType);
    final timeStr = _timeAgo(item.createdAt);
    final subtitle = '${item.repCount} reps · ${item.xpEarned} XP';

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
            timeStr,
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

  IconData _iconForExercise(String type) {
    switch (type) {
      case 'push_up':
        return Icons.self_improvement_rounded;
      case 'squat':
        return Icons.accessibility_new_rounded;
      case 'crunch':
        return Icons.fitness_center_rounded;
      case 'pull_up':
        return Icons.arrow_upward_rounded;
      case 'plank':
        return Icons.air_rounded;
      case 'lunge':
        return Icons.directions_walk_rounded;
      case 'shoulder_press':
        return Icons.pan_tool_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  String _titleForExercise(String type) {
    switch (type) {
      case 'push_up':
        return 'Push-up';
      case 'squat':
        return 'Squat';
      case 'crunch':
        return 'Crunch';
      case 'pull_up':
        return 'Pull-up';
      case 'plank':
        return 'Plank';
      case 'lunge':
        return 'Lunge';
      case 'shoulder_press':
        return 'Shoulder Press';
      default:
        return type;
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
