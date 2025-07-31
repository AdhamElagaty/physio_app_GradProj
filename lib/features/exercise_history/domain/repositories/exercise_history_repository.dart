import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/paginated_exercise_histories_result.dart';
import '../usecases/get_exercise_histories/get_exercise_histories_params.dart';

abstract class ExerciseHistoryRepository {
  Future<Either<Failure, PaginatedExerciseHistoriesResult>>
      getExerciseHistories(GetExerciseHistoriesParams params);
}
