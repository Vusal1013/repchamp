import '../models/achievement_model.dart';

class AchievementService {
  final Map<AchievementId, Achievement> _achievements = {
    for (final a in Achievement.all) a.id: a,
  };

  List<Achievement> get all => _achievements.values.toList();
  List<Achievement> get unlocked => _achievements.values.where((a) => a.unlocked).toList();
  List<Achievement> get locked => _achievements.values.where((a) => !a.unlocked).toList();
  int get unlockedCount => unlocked.length;
  int get totalCount => _achievements.length;

  Achievement? get(AchievementId id) => _achievements[id];

  List<Achievement> check({
    required int totalReps,
    required int totalWorkouts,
    required int currentStreak,
    required int duelsWon,
    required int weeklyWorkoutCount,
    required int totalFormWarnings,
    required bool justWonDuel,
    required bool wasBehindBeforeWin,
    required int repsLastWorkout,
    required int durationLastWorkout,
    required int workoutHour,
  }) {
    final newlyUnlocked = <Achievement>[];

    if (_tryUnlock(AchievementId.firstRep, totalWorkouts >= 1)) {
      newlyUnlocked.add(_achievements[AchievementId.firstRep]!);
    }
    if (_tryUnlock(AchievementId.club100, totalReps >= 100)) {
      newlyUnlocked.add(_achievements[AchievementId.club100]!);
    }
    if (_tryUnlock(AchievementId.club1000, totalReps >= 1000)) {
      newlyUnlocked.add(_achievements[AchievementId.club1000]!);
    }
    if (_tryUnlock(AchievementId.streak7, currentStreak >= 7)) {
      newlyUnlocked.add(_achievements[AchievementId.streak7]!);
    }
    if (_tryUnlock(AchievementId.streak30, currentStreak >= 30)) {
      newlyUnlocked.add(_achievements[AchievementId.streak30]!);
    }
    if (_tryUnlock(AchievementId.firstWin, duelsWon >= 1)) {
      newlyUnlocked.add(_achievements[AchievementId.firstWin]!);
    }
    if (_tryUnlock(AchievementId.noPainNoGain, weeklyWorkoutCount >= 7)) {
      newlyUnlocked.add(_achievements[AchievementId.noPainNoGain]!);
    }
    if (_tryUnlock(AchievementId.earlyBird, workoutHour > 0 && workoutHour < 7)) {
      newlyUnlocked.add(_achievements[AchievementId.earlyBird]!);
    }
    if (_tryUnlock(AchievementId.nightOwl, workoutHour >= 22 || workoutHour < 2)) {
      newlyUnlocked.add(_achievements[AchievementId.nightOwl]!);
    }
    if (_tryUnlock(AchievementId.comebackKing, justWonDuel && wasBehindBeforeWin)) {
      newlyUnlocked.add(_achievements[AchievementId.comebackKing]!);
    }
    if (_tryUnlock(AchievementId.perfectForm, totalFormWarnings == 0 && totalReps >= 100)) {
      newlyUnlocked.add(_achievements[AchievementId.perfectForm]!);
    }
    if (_tryUnlock(AchievementId.speedDemon, repsLastWorkout >= 50 && durationLastWorkout <= 120)) {
      newlyUnlocked.add(_achievements[AchievementId.speedDemon]!);
    }
    if (_tryUnlock(AchievementId.duelist, duelsWon >= 10)) {
      newlyUnlocked.add(_achievements[AchievementId.duelist]!);
    }
    if (_tryUnlock(AchievementId.veteran, totalWorkouts >= 100)) {
      newlyUnlocked.add(_achievements[AchievementId.veteran]!);
    }

    return newlyUnlocked;
  }

  bool _tryUnlock(AchievementId id, bool condition) {
    final achievement = _achievements[id];
    if (achievement == null || achievement.unlocked) return false;
    if (!condition) return false;

    achievement.unlocked = true;
    achievement.unlockedAt = DateTime.now();
    return true;
  }
}
