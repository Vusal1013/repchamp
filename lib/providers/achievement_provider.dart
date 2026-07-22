import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../services/streak_service.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) => AchievementService());

final streakServiceProvider = Provider<StreakService>((ref) => StreakService());

final achievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementServiceProvider).all;
});

final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementServiceProvider).unlocked;
});

final achievementProgressProvider = Provider<double>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return service.unlockedCount / service.totalCount;
});
