import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/exercise_repository.dart';

class RemoveExerciseFavoriteUseCase implements UseCase<void, String> {
  final ExerciseRepository _repository;
  RemoveExerciseFavoriteUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String exerciseId) {
    return _repository.removeExerciseFavorite(exerciseId);
  }
}