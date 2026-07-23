import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../services/supabase/profile_service.dart';
import 'auth_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final service = ref.watch(profileServiceProvider);

  try {
    final profile = await service.getProfile(user.id);
    if (profile != null) return profile;
  } catch (_) {}

  final email = user.email;
  final metadata = user.userMetadata;
  final username = metadata?['username'] as String? ?? email?.split('@').first ?? 'Player';

  return UserProfile(
    id: user.id,
    username: username,
    avatarUrl: metadata?['avatar_url'] as String?,
    level: 1,
    xp: 0,
    streak: 0,
    createdAt: DateTime.now(),
  );
});
