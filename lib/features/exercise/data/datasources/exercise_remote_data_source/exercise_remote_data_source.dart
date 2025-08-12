import '../../../../exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../../../domain/usecases/get_exercises/get_exercises_params.dart';
import '../../model/add_exercise_history_request_model.dart';
import '../../model/exercise_category_model.dart';
import '../../../../exercise_history/data/model/paginated_exercise_histories_response_model.dart';
import '../../model/paginated_exercises_response_model.dart';

abstract class ExerciseRemoteDataSource {
  Future<PaginatedExercisesResponseModel> getExercises(GetExercisesParams params);
  Future<List<ExerciseCategoryModel>> getExerciseCategories();
  Future<PaginatedExerciseHistoriesResponseModel> getExerciseHistories(GetExerciseHistoriesParams params);
  Future<void> addExerciseHistory(AddExerciseHistoryRequestModel request);
  Future<void> addExerciseFavorite(String exerciseId);
  Future<void> removeExerciseFavorite(String exerciseId);
}
