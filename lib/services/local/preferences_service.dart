import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getLastExerciseType() => _prefs?.getString('last_exercise_type');

  Future<void> setLastExerciseType(String type) async {
    await _prefs?.setString('last_exercise_type', type);
  }

  int getTotalLifetimeReps() => _prefs?.getInt('lifetime_reps') ?? 0;

  Future<void> setTotalLifetimeReps(int reps) async {
    await _prefs?.setInt('lifetime_reps', reps);
  }
}
