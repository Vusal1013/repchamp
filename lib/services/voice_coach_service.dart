import 'dart:async';
import 'package:flutter/foundation.dart';

enum CoachMood { neutral, encourage, warning, celebrate }

class VoiceCoachService extends ChangeNotifier {
  String? _lastMessage;
  CoachMood _lastMood = CoachMood.neutral;
  bool _muted = false;
  Timer? _debounce;

  String? get lastMessage => _lastMessage;
  CoachMood get lastMood => _lastMood;
  bool get muted => _muted;

  void toggleMute() {
    _muted = !_muted;
    notifyListeners();
  }

  void say(String message, {CoachMood mood = CoachMood.neutral}) {
    if (_muted) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      if (message == _lastMessage) return;
      _lastMessage = message;
      _lastMood = mood;
      notifyListeners();
      debugPrint('[VoiceCoach]: $message ($mood)');
    });
  }

  void onRep(int count, int target) {
    if (_muted) return;

    if (count == target) {
      say('Target reached! $count reps! Great job!', mood: CoachMood.celebrate);
    } else if (count % 5 == 0 && count > 0) {
      say('$count reps! Keep going!', mood: CoachMood.encourage);
    } else if (count == 1) {
      say('First rep! Let us go!', mood: CoachMood.encourage);
    }
  }

  void onFormWarning(String warning) {
    say(warning, mood: CoachMood.warning);
  }

  void onDuelResult(bool won) {
    if (won) {
      say('Victory! You are the champion!', mood: CoachMood.celebrate);
    } else {
      say('Good effort! Next time you will win!', mood: CoachMood.encourage);
    }
  }

  void onCountdown(int seconds) {
    if (seconds <= 3 && seconds > 0) {
      say('$seconds', mood: CoachMood.encourage);
    } else if (seconds == 0) {
      say('Go!', mood: CoachMood.celebrate);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
