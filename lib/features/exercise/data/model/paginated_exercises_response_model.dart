import 'exercise_model.dart';

class PaginatedExercisesResponseModel {
  final List<ExerciseModel> exercises;
  final bool hasNextPage;
  final int totalCount;

  PaginatedExercisesResponseModel(
      {required this.exercises, required this.hasNextPage, required this.totalCount});

  factory PaginatedExercisesResponseModel.fromJson(Map<String, dynamic> json) {
    final paginatedData = json;
    final List<dynamic> exerciseList = json['data'];
    return PaginatedExercisesResponseModel(
      exercises: exerciseList
          .map((i) => ExerciseModel.fromRemoteJson(i, 
              localModelKey: i['modelKey'], 
              localCategoryTitle: '',
              localIconAsset: '',
              localImageAsset: '',
              localIsActive: true,
           ))
          .toList(),
      totalCount: paginatedData['totalCount'],
      hasNextPage: paginatedData['totalCount'] > paginatedData['pageSize'] * paginatedData['pageNumber'],
    );
  }
}
