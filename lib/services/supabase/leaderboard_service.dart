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

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalReps,
    required this.totalSessions,
    required this.level,
    required this.streak,
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
    );
  }
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
}
