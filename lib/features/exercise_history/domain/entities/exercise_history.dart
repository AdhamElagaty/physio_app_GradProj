import 'package:equatable/equatable.dart';
import '../../../exercise/domain/entities/exercise.dart';

class ExerciseHistory extends Equatable {
  final Exercise exercise;
  final DateTime date;
  final int repsCount;
  final double? maxHoldDuration;

  const ExerciseHistory({
    required this.exercise,
    required this.date,
    required this.repsCount,
    this.maxHoldDuration,
  });

  @override
  List<Object?> get props => [exercise, date, repsCount, maxHoldDuration];
}
