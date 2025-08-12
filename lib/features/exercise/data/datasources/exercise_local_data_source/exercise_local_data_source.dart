import '../../model/exercise_category_model.dart';
import '../../model/exercise_model.dart';

abstract class ExerciseLocalDataSource {
  Future<List<ExerciseModel>> getExercises();
  Future<void> cacheExercises(List<ExerciseModel> exercises);
  Future<List<ExerciseCategoryModel>> getCategories();
  Future<void> cacheCategories(List<ExerciseCategoryModel> categories);
}
