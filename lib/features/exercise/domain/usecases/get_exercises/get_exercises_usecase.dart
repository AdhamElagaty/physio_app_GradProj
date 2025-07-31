import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/paginated_exercises_result.dart';
import '../../repositories/exercise_repository.dart';
import 'get_exercises_params.dart';

class GetExercisesUseCase implements UseCase<PaginatedExercisesResult, GetExercisesParams> {
  final ExerciseRepository _repository;
  GetExercisesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedExercisesResult>> call(
      GetExercisesParams params) {
    return _repository.getExercises(params);
  }
}