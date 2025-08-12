import '../../domain/entities/exercise.dart';
import '../cubit/exercise_filter/exercise_filter_cubit.dart';

class ExerciseDescriptionScreenArgs {
  final Exercise exercise;
  final ExerciseFilterCubit exerciseFilterCubit;

  const ExerciseDescriptionScreenArgs({
    required this.exercise,
    required this.exerciseFilterCubit,
  });
}