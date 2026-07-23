import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/rep_session_model.dart';
import 'supabase_client.dart';

class WorkoutService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<void> saveSession(RepSession session) async {
    await _client.from('workout_sessions').insert(session.toMap());
  }

  Future<List<RepSession>> getUserSessions(String userId, {int limit = 20}) async {
    final data = await _client
        .from('workout_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>).map((e) {
      final m = e as Map<String, dynamic>;
      return RepSession(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        exerciseType: m['exercise_type'] as String,
        repCount: m['rep_count'] as int,
        durationSeconds: m['duration_seconds'] as int?,
        xpEarned: (m['xp_earned'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();
  }
}
