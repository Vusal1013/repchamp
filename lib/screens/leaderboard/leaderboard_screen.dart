import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/duel_provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/local/translations_ext.dart';
import '../../services/supabase/leaderboard_service.dart';
import '../../services/supabase/dashboard_service.dart';
import '../../services/supabase/supabase_client.dart';
import '../../widgets/common/fit_duel_bottom_nav.dart';
import '../../widgets/common/streak_badge.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = LeaderboardService();
  return service.getLeaderboard(limit: 20);
});

final userRankProvider = FutureProvider<UserRankInfo?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final service = LeaderboardService();
  return service.getUserRank(userId);
});

final friendLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final data = await SupabaseClientManager.client
      .rpc('get_friend_leaderboard', params: {'user_id': userId, 'limit_count': 20});
  return (data as List<dynamic>).map((e) {
    final row = e as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: row['friend_id'] as String,
      username: row['username'] as String,
      avatarUrl: null,
      totalReps: (row['total_reps'] as num).toInt(),
      totalSessions: 0,
      level: (row['level'] as num).toInt(),
      streak: (row['streak'] as num?)?.toInt() ?? 0,
      xp: 0,
    );
  }).toList();
});

final weeklyBreakdownLeaderboardProvider = FutureProvider<WeeklyBreakdown>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const WeeklyBreakdown(dailyXp: [0, 0, 0, 0, 0, 0, 0]);
  final service = DashboardService();
  return service.getWeeklyBreakdown(userId);
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(leaderboardProvider);
    final userRank = ref.watch(userRankProvider);
    final friendLeaderboard = ref.watch(friendLeaderboardProvider);
    final weeklyBreakdown = ref.watch(weeklyBreakdownLeaderboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: leaderboard.when(
                data: (entries) => _buildBody(entries, userRank.valueOrNull, ref,
                    friendLeaderboard, weeklyBreakdown),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6CFF80)),
                ),
                error: (_, __) => Center(
                  child: Text(
                    ref.tr('failed_to_load'),
                    style: const TextStyle(color: Color(0xFFFFB4AB)),
                  ),
                ),
              ),
            ),
            const FitDuelBottomNav(activeTab: NavTab.leaderboard),
          ],
        ),
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
          const Spacer(),
          const StreakBadge(),
        ],
      ),
    );
  }

  Widget _buildBody(List<LeaderboardEntry> entries, UserRankInfo? rankInfo, WidgetRef ref,
      AsyncValue<List<LeaderboardEntry>> friendLeaderboard,
      AsyncValue<WeeklyBreakdown> weeklyBreakdown) {
    if (_selectedTab == 0) {
      return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            child: Column(
              children: [
                _buildTabs(ref),
                const SizedBox(height: 32),
                _buildPodium(entries),
                const SizedBox(height: 32),
                _buildRankedList(entries, ref),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildUserFooter(rankInfo, ref),
          ),
        ],
      );
    } else if (_selectedTab == 1) {
      return _buildFriendsContent(friendLeaderboard, ref);
    } else {
      return _buildWeeklyContent(weeklyBreakdown, ref);
    }
  }

  Widget _buildTabs(WidgetRef ref) {
    final labels = [ref.tr('global'), ref.tr('friends'), ref.tr('weekly')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: selected ? BoxDecoration(
                  color: const Color(0xFF6CFF80).withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6CFF80).withAlpha(77)),
                ) : null,
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF007226) : const Color(0xFFBACBB6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFriendsContent(AsyncValue<List<LeaderboardEntry>> friendLeaderboard, WidgetRef ref) {
    return friendLeaderboard.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: const Color(0xFF353534)),
                const SizedBox(height: 16),
                Text(ref.tr('no_friends_yet'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6))),
                const SizedBox(height: 8),
                Text(ref.tr('add_friends_hint'), style: TextStyle(fontSize: 12, color: const Color(0xFF859581))),
              ],
            ),
          );
        }
        return _buildFriendList(entries);
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF80))),
      error: (_, __) => Text(ref.tr('failed_to_load'), style: const TextStyle(color: Color(0xFFFFB4AB))),
    );
  }

  Widget _buildWeeklyContent(AsyncValue<WeeklyBreakdown> weeklyBreakdown, WidgetRef ref) {
    return weeklyBreakdown.when(
      data: (weekly) {
        final dailyXp = weekly.dailyXp;
        final total = weekly.totalXp;
        final maxDay = dailyXp.reduce((a, b) => a > b ? a : b);
        final labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(ref.tr('weekly_xp'), style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6))),
                  const SizedBox(height: 4),
                  Text('+$total', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: const Color(0xFF6CFF80))),
                  Text(ref.tr('xp_this_week'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final xp = dailyXp[i];
                  final height = maxDay > 0 ? (xp / maxDay) * 140 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$xp', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6))),
                          const SizedBox(height: 4),
                          Container(
                            height: height.clamp(4.0, 140.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CFF80),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(labels[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF859581))),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6CFF80))),
      error: (_, __) => Text(ref.tr('failed_to_load'), style: const TextStyle(color: Color(0xFFFFB4AB))),
    );
  }

  Widget _buildFriendList(List<LeaderboardEntry> entries) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: List.generate(entries.length, (i) {
          final entry = entries[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '${i + 1}',
                  style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6)),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF353534))),
                  child: const Icon(Icons.person, size: 22, color: Color(0xFFBACBB6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFE5E2E1))),
                      const SizedBox(height: 2),
                      Text('LEVEL ${entry.level}', style: TextStyle(fontSize: 10, color: const Color(0xFFBACBB6))),
                    ],
                  ),
                ),
                Text(_formatReps(entry.totalReps), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6CFF80))),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final top3 = <LeaderboardEntry?>[
      entries.length > 1 ? entries[1] : null,
      entries.isNotEmpty ? entries[0] : null,
      entries.length > 2 ? entries[2] : null,
    ];

    final colors = [const Color(0xFFC0C0C0), const Color(0xFF6CFF80), const Color(0xFFCD7F32)];
    final labels = ['2ND', '1ST', '3RD'];
    final sizes = [16.0, 24.0, 16.0];
    final borderWidth = [2.0, 4.0, 2.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final entry = top3[i];
        if (entry == null) return const Expanded(child: SizedBox.shrink());

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: i == 1 ? 0 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sizes[i] * 4,
                  height: sizes[i] * 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[i], width: borderWidth[i]),
                    boxShadow: i == 1
                        ? [BoxShadow(color: const Color(0xFF39FF6A).withAlpha(77), blurRadius: 30)]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.avatarUrl != null
                      ? null
                      : Icon(Icons.person, size: sizes[i] * 1.5, color: colors[i]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(9999)),
                  child: Text(labels[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF0E0E0E))),
                ),
                const SizedBox(height: 8),
                Text(entry.username, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == 1 ? const Color(0xFF6CFF80) : const Color(0xFFE5E2E1))),
                const SizedBox(height: 4),
                Text(_formatXp(entry.xp), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colors[i])),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRankedList(List<LeaderboardEntry> entries, WidgetRef ref) {
    final listEntries = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    return Column(
      children: List.generate(listEntries.length, (i) {
        final entry = listEntries[i];
        final rank = i + 4;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(width: 24, child: Text('$rank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFBACBB6)))),
              const SizedBox(width: 16),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF353534))),
                child: const Icon(Icons.person, size: 22, color: Color(0xFFBACBB6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.username, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFE5E2E1))),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatReps(entry.totalReps)} ${ref.tr('reps_label')}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFBACBB6)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatXp(entry.xp), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1))),
                  Text('XP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF6CFF80))),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserFooter(UserRankInfo? rankInfo, WidgetRef ref) {
    final rank = rankInfo?.rank ?? 0;
    final totalCount = rankInfo?.totalCount ?? 1;
    final totalXp = rankInfo?.totalXp ?? 0;
    final weeklyXp = rankInfo?.weeklyXp ?? 0;
    final topPercent = totalCount > 0 ? ((rank / totalCount) * 100).round() : 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6CFF80),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color(0xFF39FF6A).withAlpha(128), blurRadius: 25)],
          border: Border.all(color: const Color(0xFF00E556)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF00390F), borderRadius: BorderRadius.circular(4)),
              child: Text('#$rank', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF6CFF80))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('you_label'),
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00390F),
                  ),
                ),
                Text(
                  '${ref.tr('top_percent').replaceAll('{percent}', '$topPercent')} | ${ref.tr('this_week_xp').replaceAll('{xp}', '$weeklyXp')}',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00390F).withAlpha(204),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatXp(totalXp),
                  style: TextStyle(
                    fontFamily: 'ArchivoNarrow',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00390F),
                  ),
                ),
                Text(
                  ref.tr('total_xp_label'),
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xCC00390F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatXp(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toString();
  }

  String _formatReps(int reps) {
    if (reps >= 1000) {
      final parts = reps.toString().split('');
      final result = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
        result.write(parts[i]);
      }
      return result.toString();
    }
    return reps.toString();
  }
}
