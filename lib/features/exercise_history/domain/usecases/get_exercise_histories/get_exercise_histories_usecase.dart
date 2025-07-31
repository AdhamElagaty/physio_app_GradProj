import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/paginated_exercise_histories_result.dart';
import '../../../../exercise/domain/repositories/exercise_repository.dart';
import 'get_exercise_histories_params.dart';

class GetExerciseHistoriesUseCase implements UseCase<PaginatedExerciseHistoriesResult, GetExerciseHistoriesParams> {
  final ExerciseRepository _repository;
  GetExerciseHistoriesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedExerciseHistoriesResult>> call(
      GetExerciseHistoriesParams params) {
    return _repository.getExerciseHistories(params);
  }
}