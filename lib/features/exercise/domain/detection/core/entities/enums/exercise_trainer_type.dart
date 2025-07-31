enum ExerciseTrainerType {
  bicepCurl,
  gluteBridge,
  plank;

    static ExerciseTrainerType? getExerciseTypeFromModelKey(String modelKey) {
    switch (modelKey.toLowerCase()) {
      case 'bicep_curl':
        return ExerciseTrainerType.bicepCurl;
      case 'glute_bridges':
        return ExerciseTrainerType.gluteBridge;
      case 'plank':
        return ExerciseTrainerType.plank;
      default:
        return null;
    }
  }
}