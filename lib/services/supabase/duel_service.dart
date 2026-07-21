import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/duel_model.dart';
import 'supabase_client.dart';

class DuelService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<String> createDuelRoom(String exerciseType) async {
    final data = await _client
        .from('duel_rooms')
        .insert({'exercise_type': exerciseType, 'status': 'waiting'})
        .select()
        .single();

    return (data as Map<String, dynamic>)['id'] as String;
  }

  Future<void> joinDuelRoom(String roomId, String userId) async {
    await _client.from('duel_players').insert({
      'room_id': roomId,
      'user_id': userId,
    });
  }

  Future<List<DuelRoom>> getAvailableRooms() async {
    final data = await _client
        .from('duel_rooms')
        .select()
        .eq('status', 'waiting')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => DuelRoom.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setPlayerReady(String roomId, String userId) async {
    await _client
        .from('duel_players')
        .update({'ready': true})
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  Future<void> startDuel(String roomId) async {
    await _client
        .from('duel_rooms')
        .update({
          'status': 'active',
          'start_time': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', roomId);
  }

  Future<void> updateRepCount(String roomId, String userId, int reps) async {
    await _client
        .from('duel_players')
        .update({'reps': reps})
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  Stream<List<DuelPlayer>> listenToDuelPlayers(String roomId) {
    return _client
        .from('duel_players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .map((data) {
          return data
              .map((e) => DuelPlayer.fromMap(e as Map<String, dynamic>))
              .toList();
        });
  }

  Stream<DuelRoom> listenToDuelRoom(String roomId) {
    return _client
        .from('duel_rooms')
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((data) => DuelRoom.fromMap(data.first as Map<String, dynamic>));
  }

  Future<String?> finishDuel(String roomId) async {
    final data = await _client
        .from('duel_players')
        .select()
        .eq('room_id', roomId)
        .order('reps', ascending: false);

    final players = data as List<dynamic>;
    if (players.length < 2) return null;

    final winnerId = (players.first as Map<String, dynamic>)['user_id'] as String;

    await _client
        .from('duel_rooms')
        .update({'status': 'finished', 'winner_id': winnerId})
        .eq('id', roomId);

    return winnerId;
  }

  Future<void> saveDuelResults(
    String roomId,
    String userId,
    int reps,
    int durationSeconds,
  ) async {
    await _client.from('workout_sessions').insert({
      'user_id': userId,
      'exercise_type': 'push_up',
      'rep_count': reps,
      'duration_seconds': durationSeconds,
    });
  }
}
