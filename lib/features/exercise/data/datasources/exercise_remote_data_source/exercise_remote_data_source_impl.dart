import '../../../../../core/api/api_consumer.dart';
import '../../../../../core/api/endpoints.dart';
import '../../../../exercise_history/domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../../../domain/usecases/get_exercises/get_exercises_params.dart';
import '../../model/add_exercise_history_request_model.dart';
import '../../model/exercise_category_model.dart';
import '../../../../exercise_history/data/model/paginated_exercise_histories_response_model.dart';
import '../../model/paginated_exercises_response_model.dart';
import 'exercise_remote_data_source.dart';

class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  final ApiConsumer _apiConsumer;
  ExerciseRemoteDataSourceImpl(this._apiConsumer);

  @override
  Future<PaginatedExercisesResponseModel> getExercises(
      GetExercisesParams params) async {
    final response = await _apiConsumer.get(
      Endpoints.allExercisesGet,
      queryParameters: {
        'pageIndex': params.pageIndex,
        'pageSize': params.pageSize,
        if (params.searchExercise != null && params.searchExercise!.isNotEmpty)
          'searchExercise': params.searchExercise,
        if (params.searchCategoriesTitle != null && params.searchCategoriesTitle!.isNotEmpty)
          'searchCategoriesTitle': params.searchCategoriesTitle,
        if (params.isUserFavorite != null)
          'isUserFavorite': params.isUserFavorite,
      },
    );
    return PaginatedExercisesResponseModel.fromJson(response);
  }

  @override
  Future<List<ExerciseCategoryModel>> getExerciseCategories() async {
    final response = await _apiConsumer.get(Endpoints.exerciseCategoriesGet);
    final List<dynamic> categoryList = response['data']['exerciseCategories'];
    return categoryList.map((i) => ExerciseCategoryModel.fromRemoteJson(i)).toList();
  }

  @override
  Future<PaginatedExerciseHistoriesResponseModel> getExerciseHistories(
      GetExerciseHistoriesParams params) async {
    final response = await _apiConsumer.get(
      Endpoints.exerciseHistoryGet,
      queryParameters: {
        'pageIndex': params.pageIndex,
        'pageSize': params.pageSize,
        if (params.searchExercise != null && params.searchExercise!.isNotEmpty)
          'searchExercise': params.searchExercise,
        if (params.searchCategoriesTitle != null && params.searchCategoriesTitle!.isNotEmpty)
          'searchCategoriesTitle': params.searchCategoriesTitle,
        if (params.isUserFavorite != null)
          'isUserFavorite': params.isUserFavorite,
        if (params.dateFrom != null)
          'dateFrom': params.dateFrom!.toIso8601String(),
        if (params.dateTo != null)
          'dateTo': params.dateTo!.toIso8601String(),
      },
    );
    return PaginatedExerciseHistoriesResponseModel.fromJson(response);
  }
  
  @override
  Future<void> addExerciseHistory(AddExerciseHistoryRequestModel request) async {
    await _apiConsumer.post(
      Endpoints.exerciseHistoryPost,
      body: request.toJson(),
    );
  }

  @override
  Future<void> addExerciseFavorite(String exerciseId) async {
     await _apiConsumer.post(Endpoints.addexerciseFavoritePost(exerciseId));
  }
  
  @override
  Future<void> removeExerciseFavorite(String exerciseId) async {
    await _apiConsumer.delete(Endpoints.removeExerciseFavoriteDelete(exerciseId));
  }
}
