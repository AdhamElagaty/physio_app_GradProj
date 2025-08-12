import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/exercise_repository.dart';

class AddExerciseFavoriteUseCase implements UseCase<void, String> {
  final ExerciseRepository _repository;
  AddExerciseFavoriteUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String exerciseId) {
    return _repository.addExerciseFavorite(exerciseId);
  }
}