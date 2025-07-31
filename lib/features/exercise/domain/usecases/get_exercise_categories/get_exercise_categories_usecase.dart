import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../entities/exercise_category.dart';
import '../../repositories/exercise_repository.dart';

class GetExerciseCategoriesUseCase
    implements UseCase<List<ExerciseCategory>, NoParams> {
  final ExerciseRepository _repository;
  GetExerciseCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, List<ExerciseCategory>>> call(NoParams params) {
    return _repository.getExerciseCategories();
  }
}