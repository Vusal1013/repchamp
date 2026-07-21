enum ExerciseType {
  pushUp,
  squat;

  String get databaseValue {
    switch (this) {
      case ExerciseType.pushUp:
        return 'push_up';
      case ExerciseType.squat:
        return 'squat';
    }
  }

  static ExerciseType fromDatabase(String value) {
    switch (value) {
      case 'push_up':
        return ExerciseType.pushUp;
      case 'squat':
        return ExerciseType.squat;
      default:
        return ExerciseType.pushUp;
    }
  }
}
