enum AchievementId {
  firstRep,
  club100,
  club1000,
  streak7,
  streak30,
  firstWin,
  noPainNoGain,
  earlyBird,
  nightOwl,
  comebackKing,
  perfectForm,
  speedDemon,
  duelist,
  veteran,
}

class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final String iconAsset;
  final bool isSecret;
  bool unlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.iconAsset = '',
    this.isSecret = false,
    this.unlocked = false,
    this.unlockedAt,
  });

  String get iconName {
    switch (id) {
      case AchievementId.firstRep:
        return 'first_rep';
      case AchievementId.club100:
        return 'club_100';
      case AchievementId.club1000:
        return 'club_1000';
      case AchievementId.streak7:
        return 'streak_7';
      case AchievementId.streak30:
        return 'streak_30';
      case AchievementId.firstWin:
        return 'first_win';
      case AchievementId.noPainNoGain:
        return 'no_pain';
      case AchievementId.earlyBird:
        return 'early_bird';
      case AchievementId.nightOwl:
        return 'night_owl';
      case AchievementId.comebackKing:
        return 'comeback';
      case AchievementId.perfectForm:
        return 'perfect_form';
      case AchievementId.speedDemon:
        return 'speed_demon';
      case AchievementId.duelist:
        return 'duelist';
      case AchievementId.veteran:
        return 'veteran';
    }
  }

  static List<Achievement> get all => [
    Achievement(id: AchievementId.firstRep, title: 'First Rep', description: 'Complete your first workout'),
    Achievement(id: AchievementId.club100, title: '100 Club', description: 'Reach 100 total reps'),
    Achievement(id: AchievementId.club1000, title: '1,000 Club', description: 'Reach 1,000 total reps'),
    Achievement(id: AchievementId.streak7, title: 'Week Warrior', description: '7-day workout streak'),
    Achievement(id: AchievementId.streak30, title: 'Iron Will', description: '30-day workout streak'),
    Achievement(id: AchievementId.firstWin, title: 'First Blood', description: 'Win your first duel'),
    Achievement(id: AchievementId.noPainNoGain, title: 'No Pain No Gain', description: '7 workouts in one week'),
    Achievement(id: AchievementId.earlyBird, title: 'Early Bird', description: 'Workout before 7 AM'),
    Achievement(id: AchievementId.nightOwl, title: 'Night Owl', description: 'Workout after 10 PM'),
    Achievement(id: AchievementId.comebackKing, title: 'Comeback King', description: 'Win a duel from behind', isSecret: true),
    Achievement(id: AchievementId.perfectForm, title: 'Perfect Form', description: '100 reps with 0 form warnings'),
    Achievement(id: AchievementId.speedDemon, title: 'Speed Demon', description: '50 reps in under 2 minutes'),
    Achievement(id: AchievementId.duelist, title: 'Duelist', description: 'Win 10 duels'),
    Achievement(id: AchievementId.veteran, title: 'Veteran', description: 'Complete 100 workouts'),
  ];
}
