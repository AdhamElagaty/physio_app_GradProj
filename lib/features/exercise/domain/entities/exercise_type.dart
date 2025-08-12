enum ExerciseType {
  repCount,
  durationHoldWithRepCount,
  unknown;

  static ExerciseType fromInt(int? type) {
    switch (type) {
      case 1:
        return ExerciseType.repCount;
      case 2:
        return ExerciseType.durationHoldWithRepCount;
      default:
        return ExerciseType.unknown;
    }
  }

  static ExerciseType fromString(String? type) {
    switch (type) {
      case 'RepCount':
        return ExerciseType.repCount;
      case 'DurationHoldWithRepCount':
        return ExerciseType.durationHoldWithRepCount;
      default:
        return ExerciseType.unknown;
    }
  }
}