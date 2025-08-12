import '../../../../../core/api/api_consumer.dart';
import '../../../../../core/api/endpoints.dart';
import '../../domain/usecases/get_exercise_histories/get_exercise_histories_params.dart';
import '../model/paginated_exercise_histories_response_model.dart';
import 'exercise_history_remote_data_source.dart';

class ExerciseHistoryRemoteDataSourceImpl implements ExerciseHistoryRemoteDataSource {
  final ApiConsumer _apiConsumer;
  ExerciseHistoryRemoteDataSourceImpl(this._apiConsumer);

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
}
