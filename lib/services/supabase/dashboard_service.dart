import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class DailyStats {
  final int totalReps;
  final int totalXp;

  const DailyStats({required this.totalReps, required this.totalXp});
}

class WeeklyBreakdown {
  final List<int> dailyXp; // index 0=Sun, 1=Mon, ..., 6=Sat

  const WeeklyBreakdown({required this.dailyXp});

  int get totalXp => dailyXp.fold(0, (a, b) => a + b);
}

class RecentActivityItem {
  final String exerciseType;
  final int repCount;
  final int xpEarned;
  final int? durationSeconds;
  final DateTime createdAt;

  const RecentActivityItem({
    required this.exerciseType,
    required this.repCount,
    required this.xpEarned,
    this.durationSeconds,
    required this.createdAt,
  });
}

class DashboardService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<DailyStats?> getDailyStats(String userId) async {
    final data = await _client.rpc('get_daily_stats', params: {'target_user_id': userId});
    final list = data as List<dynamic>;
    if (list.isEmpty) return null;
    final row = list.first as Map<String, dynamic>;
    return DailyStats(
      totalReps: (row['total_reps'] as num).toInt(),
      totalXp: (row['total_xp'] as num).toInt(),
    );
  }

  Future<WeeklyBreakdown> getWeeklyBreakdown(String userId) async {
    final data = await _client.rpc('get_weekly_breakdown', params: {'target_user_id': userId});
    final list = data as List<dynamic>;
    final dailyXp = List.filled(7, 0);
    for (final item in list) {
      final row = item as Map<String, dynamic>;
      final dayIndex = (row['day_index'] as num).toInt();
      final totalXp = (row['total_xp'] as num).toInt();
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyXp[dayIndex] = totalXp;
      }
    }
    return WeeklyBreakdown(dailyXp: dailyXp);
  }

  Future<List<RecentActivityItem>> getRecentActivity(String userId, {int limit = 10}) async {
    final data = await _client.rpc('get_recent_activity', params: {
      'target_user_id': userId,
      'limit_count': limit,
    });
    return (data as List<dynamic>).map((item) {
      final row = item as Map<String, dynamic>;
      return RecentActivityItem(
        exerciseType: row['exercise_type'] as String,
        repCount: (row['rep_count'] as num).toInt(),
        xpEarned: (row['xp_earned'] as num?)?.toInt() ?? 0,
        durationSeconds: (row['duration_seconds'] as num?)?.toInt(),
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }
}
