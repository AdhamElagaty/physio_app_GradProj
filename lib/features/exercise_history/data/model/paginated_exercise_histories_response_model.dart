import 'exercise_history_model.dart';

class PaginatedExerciseHistoriesResponseModel {
  final List<ExerciseHistoryModel> histories;
  final bool hasNextPage;

  PaginatedExerciseHistoriesResponseModel(
      {required this.histories, required this.hasNextPage});

  factory PaginatedExerciseHistoriesResponseModel.fromJson(
      Map<String, dynamic> json) {
    final paginatedData = json['data'];
    final List<dynamic> historyList = paginatedData['data'];
    return PaginatedExerciseHistoriesResponseModel(
      histories: historyList.map((i) => ExerciseHistoryModel.fromJson(i)).toList(),
      hasNextPage: paginatedData['hasNextPage'],
    );
  }
}
