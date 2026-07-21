enum ExerciseType {
  pushUp,
  squat,
  crunch,
  pullUp,
  plank,
  lunge,
  shoulderPress;

  String get databaseValue {
    switch (this) {
      case ExerciseType.pushUp:
        return 'push_up';
      case ExerciseType.squat:
        return 'squat';
      case ExerciseType.crunch:
        return 'crunch';
      case ExerciseType.pullUp:
        return 'pull_up';
      case ExerciseType.plank:
        return 'plank';
      case ExerciseType.lunge:
        return 'lunge';
      case ExerciseType.shoulderPress:
        return 'shoulder_press';
    }
  }

  String get displayName {
    switch (this) {
      case ExerciseType.pushUp:
        return 'Push-up';
      case ExerciseType.squat:
        return 'Squat';
      case ExerciseType.crunch:
        return 'Crunch';
      case ExerciseType.pullUp:
        return 'Pull-up';
      case ExerciseType.plank:
        return 'Plank';
      case ExerciseType.lunge:
        return 'Lunge';
      case ExerciseType.shoulderPress:
        return 'Shoulder Press';
    }
  }

  bool get isTimeBased => this == ExerciseType.plank;

  static ExerciseType fromDatabase(String value) {
    switch (value) {
      case 'push_up':
        return ExerciseType.pushUp;
      case 'squat':
        return ExerciseType.squat;
      case 'crunch':
        return ExerciseType.crunch;
      case 'pull_up':
        return ExerciseType.pullUp;
      case 'plank':
        return ExerciseType.plank;
      case 'lunge':
        return ExerciseType.lunge;
      case 'shoulder_press':
        return ExerciseType.shoulderPress;
      default:
        return ExerciseType.pushUp;
    }
  }
}
