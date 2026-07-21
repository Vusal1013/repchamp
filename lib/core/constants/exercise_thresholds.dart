abstract final class ExerciseThresholds {
  ExerciseThresholds._();

  // Push-up: elbow angle
  static const double pushUpUp = 160.0;
  static const double pushUpDown = 90.0;

  // Squat: knee angle
  static const double squatUp = 160.0;
  static const double squatDown = 100.0;

  // Crunch: hip-torso angle
  static const double crunchUp = 120.0;
  static const double crunchDown = 160.0;

  // Pull-up: elbow angle (vertical)
  static const double pullUpUp = 160.0;
  static const double pullUpDown = 60.0;

  // Plank: hip angle (hold detection)
  static const double plankIdeal = 175.0;
  static const double plankWarning = 160.0;

  // Lunge: front knee angle
  static const double lungeUp = 160.0;
  static const double lungeDown = 90.0;

  // Shoulder Press: elbow angle (overhead)
  static const double shoulderPressUp = 170.0;
  static const double shoulderPressDown = 90.0;

  static const double minLandmarkLikelihood = 0.6;
  static const int smoothingBufferSize = 5;
  static const int frameThrottleInterval = 3;

  static double getUpAngle(String exercise) {
    switch (exercise) {
      case 'squat':
        return squatUp;
      case 'crunch':
        return crunchUp;
      case 'pull_up':
        return pullUpUp;
      case 'lunge':
        return lungeUp;
      case 'shoulder_press':
        return shoulderPressUp;
      default:
        return pushUpUp;
    }
  }

  static double getDownAngle(String exercise) {
    switch (exercise) {
      case 'squat':
        return squatDown;
      case 'crunch':
        return crunchDown;
      case 'pull_up':
        return pullUpDown;
      case 'lunge':
        return lungeDown;
      case 'shoulder_press':
        return shoulderPressDown;
      default:
        return pushUpDown;
    }
  }
}
