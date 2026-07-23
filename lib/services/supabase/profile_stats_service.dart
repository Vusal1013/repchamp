import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class DuelStats {
  final int totalDuels;
  final int wins;
  final int losses;
  final double winRate;

  const DuelStats({
    required this.totalDuels,
    required this.wins,
    required this.losses,
    required this.winRate,
  });
}

class RecentDuelItem {
  final String roomId;
  final String exerciseType;
  final String opponentUsername;
  final String? opponentAvatarUrl;
  final bool won;
  final DateTime createdAt;

  const RecentDuelItem({
    required this.roomId,
    required this.exerciseType,
    required this.opponentUsername,
    this.opponentAvatarUrl,
    required this.won,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class AchievementInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.unlocked,
    this.unlockedAt,
  });
}

class ProfileStatsService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<DuelStats?> getDuelStats(String userId) async {
    final data = await _client.rpc('get_profile_duel_stats', params: {'target_user_id': userId});
    final list = data as List<dynamic>;
    if (list.isEmpty) return null;
    final row = list.first as Map<String, dynamic>;
    return DuelStats(
      totalDuels: (row['total_duels'] as num).toInt(),
      wins: (row['wins'] as num).toInt(),
      losses: (row['losses'] as num).toInt(),
      winRate: (row['win_rate'] as num).toDouble(),
    );
  }

  Future<int> getTotalReps(String userId) async {
    final data = await _client.rpc('get_total_reps', params: {'target_user_id': userId});
    final list = data as List<dynamic>;
    if (list.isEmpty) return 0;
    return ((list.first as Map<String, dynamic>)['total_reps'] as num).toInt();
  }

  Future<List<RecentDuelItem>> getRecentDuels(String userId, {int limit = 20}) async {
    final data = await _client.rpc('get_recent_duels', params: {
      'target_user_id': userId,
      'limit_count': limit,
    });
    return (data as List<dynamic>).map((item) {
      final row = item as Map<String, dynamic>;
      return RecentDuelItem(
        roomId: row['room_id'] as String,
        exerciseType: row['exercise_type'] as String,
        opponentUsername: (row['opponent_username'] as String?) ?? 'Unknown',
        opponentAvatarUrl: row['opponent_avatar_url'] as String?,
        won: row['won'] as bool,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  Future<List<AchievementInfo>> getAchievements(String userId) async {
    final data = await _client.rpc('get_user_achievements', params: {'target_user_id': userId});
    final rows = data as List<dynamic>;
    return rows.map((item) {
      final row = item as Map<String, dynamic>;
      final id = row['achievement_id'] as String;
      final meta = _achievementMeta[id]!;
      return AchievementInfo(
        id: id,
        name: meta.$1,
        description: meta.$2,
        icon: meta.$3,
        category: meta.$4,
        unlocked: row['unlocked'] as bool,
        unlockedAt: row['unlocked_at'] != null ? DateTime.parse(row['unlocked_at'] as String) : null,
      );
    }).toList();
  }

  static const Map<String, (String, String, String, String)> _achievementMeta = {
    'first_rep': ('First Rep', 'Complete your first workout', 'fitness_center', 'milestone'),
    'club_100': ('Club 100', 'Complete 100 total reps', 'stars', 'milestone'),
    'club_1000': ('Club 1000', 'Complete 1,000 total reps', 'military_tech', 'milestone'),
    'streak_7': ('Week Warrior', 'Maintain a 7-day streak', 'local_fire_department', 'streak'),
    'streak_30': ('Iron Will', 'Maintain a 30-day streak', 'whatshot', 'streak'),
    'first_win': ('First Blood', 'Win your first duel', 'emoji_events', 'duel'),
    'no_pain_no_gain': ('No Pain No Gain', 'Complete a workout with 100+ reps', 'bolt', 'workout'),
    'early_bird': ('Early Bird', 'Work out before 7 AM', 'wb_sunny', 'lifestyle'),
    'night_owl': ('Night Owl', 'Work out after 10 PM', 'dark_mode', 'lifestyle'),
    'comeback_king': ('Comeback King', 'Win a duel after being behind', 'autorenew', 'duel'),
    'perfect_form': ('Perfect Form', 'Complete 50 reps without stopping', 'handyman', 'workout'),
    'speed_demon': ('Speed Demon', 'Complete 30 reps in 30 seconds', 'flash_on', 'workout'),
    'duelist': ('Duelist', 'Complete 10 duels', 'sports_kabaddi', 'duel'),
    'veteran': ('Veteran', 'Reach level 10', 'workspace_premium', 'milestone'),
  };
}
