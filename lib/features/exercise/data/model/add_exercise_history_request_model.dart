import '../../domain/usecases/add_exercise_history/add_exercise_history_params.dart';

class AddExerciseHistoryRequestModel {
  final String exerciseId;
  final int repsCount;
  final double? maxHoldingTime;

  AddExerciseHistoryRequestModel({
    required this.exerciseId,
    required this.repsCount,
    this.maxHoldingTime,
  });

  factory AddExerciseHistoryRequestModel.fromParams(
      AddExerciseHistoryParams params) {
    return AddExerciseHistoryRequestModel(
      exerciseId: params.exerciseId,
      repsCount: params.repsCount,
      maxHoldingTime: params.maxHoldingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'repsCount': repsCount,
      if (maxHoldingTime != null) 'maxHoldingTime': maxHoldingTime,
    };
  }
}
