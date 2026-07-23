import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalReps;
  final int totalSessions;
  final int level;
  final int streak;
  final int xp;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalReps,
    required this.totalSessions,
    required this.level,
    required this.streak,
    required this.xp,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['user_id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      totalReps: (map['total_reps'] as num).toInt(),
      totalSessions: (map['total_sessions'] as num).toInt(),
      level: map['level'] as int? ?? 1,
      streak: map['streak'] as int? ?? 0,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserRankInfo {
  final int rank;
  final int totalCount;
  final int totalXp;
  final int weeklyXp;

  const UserRankInfo({
    required this.rank,
    required this.totalCount,
    required this.totalXp,
    required this.weeklyXp,
  });
}

class LeaderboardService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 20}) async {
    final data = await _client
        .rpc('get_leaderboard', params: {'limit_count': limit});

    return (data as List<dynamic>)
        .map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserRankInfo?> getUserRank(String userId) async {
    final rankData = await _client
        .rpc('get_user_rank', params: {'target_user_id': userId});

    final rankList = rankData as List<dynamic>;
    if (rankList.isEmpty) return null;
    final row = rankList.first as Map<String, dynamic>;

    final weeklyData = await _client
        .rpc('get_weekly_xp', params: {'target_user_id': userId});
    final weeklyXp = (weeklyData as int?) ?? 0;

    return UserRankInfo(
      rank: (row['rank'] as num).toInt(),
      totalCount: (row['total_count'] as num).toInt(),
      totalXp: (row['total_xp'] as num?)?.toInt() ?? 0,
      weeklyXp: weeklyXp,
    );
  }
}
