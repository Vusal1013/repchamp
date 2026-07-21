import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_type.dart';
import '../services/rep_counter_engine.dart';

class RepCounterState {
  final int repCount;
  final RepState currentState;
  final String? formWarning;

  const RepCounterState({
    this.repCount = 0,
    this.currentState = RepState.unknown,
    this.formWarning,
  });

  RepCounterState copyWith({
    int? repCount,
    RepState? currentState,
    String? formWarning,
  }) {
    return RepCounterState(
      repCount: repCount ?? this.repCount,
      currentState: currentState ?? this.currentState,
      formWarning: formWarning ?? this.formWarning,
    );
  }
}

class RepCounterNotifier extends StateNotifier<RepCounterState> {
  RepCounterEngine? _engine;

  RepCounterNotifier() : super(const RepCounterState());

  void initialize(ExerciseType type) {
    _engine = RepCounterEngine(exerciseType: type);
    state = const RepCounterState();
  }

  void processPose(Pose pose) {
    if (_engine == null) return;
    final reps = _engine!.processPose(pose);
    final formWarning = _engine!.checkForm(pose);
    if (reps != state.repCount ||
        _engine!.currentState != state.currentState ||
        formWarning != state.formWarning) {
      state = RepCounterState(
        repCount: reps,
        currentState: _engine!.currentState,
        formWarning: formWarning,
      );
    }
  }

  void reset() {
    _engine?.reset();
    state = const RepCounterState();
  }

  int get repCount => state.repCount;
  ExerciseType? get exerciseType => _engine?.exerciseType;
}

final repCounterProvider = StateNotifierProvider<RepCounterNotifier, RepCounterState>((ref) {
  return RepCounterNotifier();
});
