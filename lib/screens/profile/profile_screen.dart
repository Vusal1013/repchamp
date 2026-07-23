import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/profile_stats_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/supabase/profile_stats_service.dart';
import '../../services/supabase/dashboard_service.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';
import '../../widgets/common/streak_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(currentUserProvider);
    final duelStatsAsync = ref.watch(duelStatsProvider);
    final totalRepsAsync = ref.watch(totalRepsProvider);
    final recentDuelsAsync = ref.watch(recentDuelsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final weeklyAsync = ref.watch(weeklyBreakdownProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
                  return _buildBody(profile, authUser?.email ?? '',
                      duelStatsAsync, totalRepsAsync, recentDuelsAsync,
                      achievementsAsync, weeklyAsync);
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
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/profile/settings'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF201F1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF353534)),
              ),
              child: const Icon(Icons.settings_rounded, color: Color(0xFF6CFF80), size: 20),
            ),
          ),
          const SizedBox(width: 8),
          const StreakBadge(),
        ],
      ),
    );
  }

  Widget _buildBody(
    UserProfile profile,
    String email,
    AsyncValue<DuelStats?> duelStatsAsync,
    AsyncValue<int> totalRepsAsync,
    AsyncValue<List<RecentDuelItem>> recentDuelsAsync,
    AsyncValue<List<AchievementInfo>> achievementsAsync,
    AsyncValue<WeeklyBreakdown> weeklyAsync,
  ) {
    final duelStats = duelStatsAsync.asData?.value;
    final totalReps = totalRepsAsync.asData?.value ?? 0;
    final recentDuels = recentDuelsAsync.asData?.value ?? [];
    final achievements = achievementsAsync.asData?.value ?? [];
    final weekly = weeklyAsync.asData?.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          _buildHeroSection(profile, email),
          const SizedBox(height: 16),
          _buildStatsGrid(duelStats, totalReps),
          const SizedBox(height: 16),
          _buildXpChart(weekly),
          const SizedBox(height: 16),
          _buildAchievements(achievements),
          const SizedBox(height: 16),
          _buildRecentDuels(recentDuels),
        ],
      ),
    );
  }

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
                child: profile.avatarUrl != null
                    ? ClipOval(child: Image.network(profile.avatarUrl!, fit: BoxFit.cover))
                    : const Icon(Icons.person, size: 64, color: Color(0xFF6CFF80)),
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

  Widget _buildStatsGrid(DuelStats? duelStats, int totalReps) {
    final wins = duelStats?.wins ?? 0;
    final winRate = duelStats?.winRate ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildWinRateCard(winRate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDuelsWonCard(wins)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTotalRepsCard(totalReps),
      ],
    );
  }

  Widget _buildWinRateCard(double winRate) {
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
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${winRate.toStringAsFixed(0)}%',
            style: TextStyle(
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
                widthFactor: winRate / 100,
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

  Widget _buildDuelsWonCard(int wins) {
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
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFBACBB6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$wins',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRepsCard(int totalReps) {
    final display = totalReps >= 1000
        ? '${(totalReps / 1000).toStringAsFixed(1)}K'
        : '$totalReps';
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
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFBACBB6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                display,
                style: TextStyle(
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

  Widget _buildXpChart(WeeklyBreakdown? weekly) {
    final dailyXp = weekly?.dailyXp ?? [0, 0, 0, 0, 0, 0, 0];
    final totalWeekly = weekly?.totalXp ?? 0;
    final maxDay = dailyXp.reduce((a, b) => a > b ? a : b);

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
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
              Text(
                '+$totalWeekly XP',
                style: TextStyle(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final xp = dailyXp[i];
                final height = maxDay > 0 ? (xp / maxDay) * 100 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6CFF80),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF39FF6A).withAlpha(77),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((day) {
              return Text(
                day,
                style: TextStyle(
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

  Widget _buildAchievements(List<AchievementInfo> achievements) {
    if (achievements.isEmpty) return const SizedBox.shrink();
    final unlocked = achievements.where((a) => a.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                'ACHIEVEMENTS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
              const Spacer(),
              Text(
                '${unlocked.length}/${achievements.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6CFF80),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final a = achievements[index];
              return _achieveCard(a);
            },
          ),
        ),
      ],
    );
  }

  Widget _achieveCard(AchievementInfo a) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: a.unlocked
            ? Colors.white.withAlpha(8)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: a.unlocked
              ? const Color(0xFF6CFF80).withAlpha(76)
              : const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconFromString(a.icon),
            color: a.unlocked
                ? const Color(0xFF6CFF80)
                : const Color(0xFF555555),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            a.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: a.unlocked
                  ? const Color(0xFFE5E2E1)
                  : const Color(0xFF555555),
              height: 1.2,
            ),
          ),
          if (a.unlocked && a.unlockedAt != null) ...[
            const SizedBox(height: 2),
            Text(
              _formatDate(a.unlockedAt!),
              style: TextStyle(
                fontSize: 7,
                color: const Color(0xFF6CFF80).withAlpha(150),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentDuels(List<RecentDuelItem> duels) {
    if (duels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'RECENT DUELS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5E2E1),
            ),
          ),
        ),
        ...duels.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _duelItem(d),
        )),
      ],
    );
  }

  Widget _duelItem(RecentDuelItem duel) {
    final xpText = duel.won ? '+50 XP' : '-20 XP';
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
              color: duel.won
                  ? const Color(0xFF6CFF80).withAlpha(26)
                  : const Color(0xFF353534),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              duel.won ? Icons.emoji_events_rounded : Icons.close_rounded,
              color: duel.won ? const Color(0xFF6CFF80) : const Color(0xFFBACBB6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${duel.won ? 'Won' : 'Lost'} vs @${duel.opponentUsername}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE5E2E1),
                  ),
                ),
                Text(
                  '${_exerciseLabel(duel.exerciseType)} • ${duel.timeAgo}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBACBB6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            xpText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: duel.won ? const Color(0xFF6CFF80) : const Color(0xFFBACBB6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'fitness_center': return Icons.fitness_center;
      case 'stars': return Icons.stars;
      case 'military_tech': return Icons.military_tech;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'whatshot': return Icons.whatshot;
      case 'emoji_events': return Icons.emoji_events;
      case 'bolt': return Icons.bolt;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'dark_mode': return Icons.dark_mode;
      case 'autorenew': return Icons.autorenew;
      case 'handyman': return Icons.handyman;
      case 'flash_on': return Icons.flash_on;
      case 'sports_kabaddi': return Icons.sports_kabaddi;
      case 'workspace_premium': return Icons.workspace_premium;
      default: return Icons.emoji_events;
    }
  }

  String _exerciseLabel(String type) {
    switch (type) {
      case 'push_up': return 'Pushup Duel';
      case 'squat': return 'Squat Duel';
      case 'crunch': return 'Crunch Duel';
      case 'pull_up': return 'Pull-up Duel';
      case 'plank': return 'Plank Duel';
      case 'lunge': return 'Lunge Duel';
      case 'shoulder_press': return 'Shoulder Press Duel';
      default: return 'Duel';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}';
  }
}
