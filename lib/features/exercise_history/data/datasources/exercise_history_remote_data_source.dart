import '../../domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../model/paginated_exercise_histories_response_model.dart';

abstract class ExerciseHistoryRemoteDataSource {
  Future<PaginatedExerciseHistoriesResponseModel> getExerciseHistories(GetExerciseHistoriesParams params);
}