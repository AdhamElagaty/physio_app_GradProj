import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/exercise_repository.dart';
import 'add_exercise_history_params.dart';

class AddExerciseHistoryUseCase
    implements UseCase<void, AddExerciseHistoryParams> {
  final ExerciseRepository _repository;
  AddExerciseHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(AddExerciseHistoryParams params) {
    return _repository.addExerciseHistory(params);
  }
}