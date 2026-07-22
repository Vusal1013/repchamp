import '../models/weekly_challenge_model.dart';

class ChallengeService {
  List<WeeklyChallenge> _challenges = WeeklyChallenge.currentWeekChallenges;

  List<WeeklyChallenge> get activeChallenges =>
      _challenges.where((c) => c.isActive).toList();

  List<WeeklyChallenge> get upcomingChallenges =>
      _challenges.where((c) => c.isUpcoming).toList();

  List<WeeklyChallenge> get allChallenges => _challenges;

  void updateProgress(String challengeId, String userId, int amount) {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    final current = challenge.progress[userId] ?? 0;
    challenge.progress[userId] = current + amount;

    if ((challenge.progress[userId] ?? 0) >= challenge.targetValue) {
      challenge.completed = true;
      challenge.completedAt = DateTime.now();
    }
  }

  void addParticipant(String challengeId, String userId) {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    if (!challenge.participantIds.contains(userId)) {
      challenge.participantIds = [...challenge.participantIds, userId];
    }
  }

  void refreshWeekly() {
    _challenges = WeeklyChallenge.currentWeekChallenges;
  }
}
