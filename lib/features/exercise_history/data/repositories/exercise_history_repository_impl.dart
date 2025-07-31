import 'package:dartz/dartz.dart';

import '../../../../core/error/error_context.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../exercise_history/domain/entities/paginated_exercise_histories_result.dart';
import '../../../exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../../domain/repositories/exercise_history_repository.dart';
import '../datasources/exercise_history_remote_data_source.dart';

class ExerciseHistoryRepositoryImpl extends BaseRepository
    implements ExerciseHistoryRepository {
  final ExerciseHistoryRemoteDataSource _remoteDataSource;

  ExerciseHistoryRepositoryImpl(
    this._remoteDataSource,
    NetworkInfo networkInfo,
  ) : super(networkInfo);

  @override
  Future<Either<Failure, PaginatedExerciseHistoriesResult>>
      getExerciseHistories(GetExerciseHistoriesParams params) {
    return handleRequest(() async {
      final response = await _remoteDataSource.getExerciseHistories(params);
      return PaginatedExerciseHistoriesResult(
          items: response.histories, hasNextPage: response.hasNextPage);
    }, context: ErrorContext.exerciseGetExerciseHistory);
  }
}
