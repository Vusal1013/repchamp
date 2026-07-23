import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/duel_provider.dart';
import '../services/supabase/profile_stats_service.dart';

final profileStatsServiceProvider = Provider<ProfileStatsService>((ref) => ProfileStatsService());

final duelStatsProvider = FutureProvider.autoDispose<DuelStats?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.read(profileStatsServiceProvider).getDuelStats(userId);
});

final totalRepsProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;
  return ref.read(profileStatsServiceProvider).getTotalReps(userId);
});

final recentDuelsProvider = FutureProvider.autoDispose<List<RecentDuelItem>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.read(profileStatsServiceProvider).getRecentDuels(userId);
});

final achievementsProvider = FutureProvider.autoDispose<List<AchievementInfo>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.read(profileStatsServiceProvider).getAchievements(userId);
});
