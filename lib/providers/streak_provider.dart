import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local/preferences_service.dart';
import 'auth_provider.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) => PreferencesService());

final streakProvider = StateNotifierProvider<StreakNotifier, int>((ref) {
  return StreakNotifier(ref);
});

class StreakNotifier extends StateNotifier<int> {
  final Ref _ref;
  PreferencesService get _prefs => _ref.read(preferencesServiceProvider);

  StreakNotifier(this._ref) : super(0) {
    _load();
  }

  void _load() {
    state = _prefs.streak;
  }

  Future<void> checkAndUpdate() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDateStr = _prefs.lastWorkoutDate;

    if (lastDateStr == todayStr) return;

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = now.difference(lastDate).inDays;

      if (diff == 1) {
        final newStreak = _prefs.streak + 1;
        await _prefs.setStreak(newStreak);
        if (newStreak > _prefs.longestStreak) {
          await _prefs.setLongestStreak(newStreak);
        }
        state = newStreak;
      } else if (diff > 1) {
        await _prefs.setStreak(0);
        state = 0;
      }
    } else {
      await _prefs.setStreak(1);
      state = 1;
    }

    await _prefs.setLastWorkoutDate(todayStr);
  }
}
