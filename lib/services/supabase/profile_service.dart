import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile_model.dart';
import 'supabase_client.dart';

class ProfileService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromMap(data as Map<String, dynamic>);
  }

  Future<UserProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return getProfile(user.id);
  }

  Future<void> updateProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    int? level,
    int? xp,
    int? streak,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (level != null) data['level'] = level;
    if (xp != null) data['xp'] = xp;
    if (streak != null) data['streak'] = streak;

    await _client.from('profiles').update(data).eq('id', userId);
  }

  Future<List<UserProfile>> searchProfiles(String query) async {
    final data = await _client
        .from('profiles')
        .select()
        .ilike('username', '%$query%')
        .limit(20);

    return (data as List<dynamic>)
        .map((e) => UserProfile.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
