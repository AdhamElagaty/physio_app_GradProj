import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/exercise_category.dart';
import '../../../exercise_history/domain/entities/paginated_exercise_histories_result.dart';
import '../entities/paginated_exercises_result.dart';
import '../usecases/add_exercise_history/add_exercise_history_params.dart';
import '../../../exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../usecases/get_exercises/get_exercises_params.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, PaginatedExercisesResult>> getExercises(
      GetExercisesParams params);

  Future<Either<Failure, List<ExerciseCategory>>> getExerciseCategories();

  Future<Either<Failure, PaginatedExerciseHistoriesResult>>
      getExerciseHistories(GetExerciseHistoriesParams params);

  Future<Either<Failure, void>> addExerciseHistory(
      AddExerciseHistoryParams params);

  Future<Either<Failure, void>> addExerciseFavorite(String exerciseId);

  Future<Either<Failure, void>> removeExerciseFavorite(String exerciseId);
}