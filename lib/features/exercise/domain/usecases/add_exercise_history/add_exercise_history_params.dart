import 'package:equatable/equatable.dart';

class AddExerciseHistoryParams extends Equatable {
  final String exerciseId;
  final int repsCount;
  final double? maxHoldingTime;

  const AddExerciseHistoryParams({
    required this.exerciseId,
    required this.repsCount,
    this.maxHoldingTime,
  });

  @override
  List<Object?> get props => [exerciseId, repsCount, maxHoldingTime];
}