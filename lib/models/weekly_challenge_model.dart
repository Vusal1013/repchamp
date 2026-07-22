import 'exercise_type.dart';

enum ChallengeType { repGoal, timeTrial, streakDays }

class WeeklyChallenge {
  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final ExerciseType? exerciseType;
  final int targetValue;
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  List<String> participantIds;
  Map<String, int> progress;
  bool completed;
  DateTime? completedAt;

  WeeklyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.exerciseType,
    required this.targetValue,
    this.xpReward = 500,
    required this.startDate,
    required this.endDate,
    this.participantIds = const [],
    this.progress = const {},
    this.completed = false,
    this.completedAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  Duration get timeRemaining => endDate.difference(DateTime.now());

  double progressFor(String userId) => (progress[userId] ?? 0) / targetValue;

  static List<WeeklyChallenge> get currentWeekChallenges {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return [
      WeeklyChallenge(
        id: 'ch_weekly_reps',
        type: ChallengeType.repGoal,
        title: 'Rep Machine',
        description: 'Complete 500 total reps this week',
        targetValue: 500,
        xpReward: 500,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      WeeklyChallenge(
        id: 'ch_daily_streak',
        type: ChallengeType.streakDays,
        title: 'Daily Grind',
        description: 'Work out 5 days this week',
        targetValue: 5,
        xpReward: 300,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      WeeklyChallenge(
        id: 'ch_pushup_king',
        type: ChallengeType.repGoal,
        title: 'Push-Up King',
        description: 'Do 200 push-ups this week',
        exerciseType: ExerciseType.pushUp,
        targetValue: 200,
        xpReward: 400,
        startDate: weekStart,
        endDate: weekEnd,
      ),
    ];
  }
}
