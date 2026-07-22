import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekly_challenge_model.dart';
import '../services/challenge_service.dart';
import 'auth_provider.dart';

final challengeServiceProvider = Provider<ChallengeService>((ref) => ChallengeService());

final activeChallengesProvider = Provider<List<WeeklyChallenge>>((ref) {
  return ref.watch(challengeServiceProvider).activeChallenges;
});

final challengeProgressProvider = StateProvider<Map<String, int>>((ref) => {});

final challengeRefreshProvider = Provider<void>((ref) {
  ref.watch(challengeServiceProvider).refreshWeekly();
});

class ChallengeNotifier extends StateNotifier<AsyncValue<List<WeeklyChallenge>>> {
  final ChallengeService _service;
  final Ref _ref;

  ChallengeNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  void _load() {
    state = AsyncValue.data(_service.activeChallenges);
  }

  void updateProgress(String challengeId, int amount) {
    final userId = _ref.read(currentUserProvider)?.id ?? 'local';
    _service.updateProgress(challengeId, userId, amount);
    _service.addParticipant(challengeId, userId);
    _load();
  }

  void refresh() {
    _service.refreshWeekly();
    _load();
  }
}

final challengeProvider = StateNotifierProvider<ChallengeNotifier, AsyncValue<List<WeeklyChallenge>>>((ref) {
  return ChallengeNotifier(ref.watch(challengeServiceProvider), ref);
});
