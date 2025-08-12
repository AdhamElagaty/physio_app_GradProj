import '../cubit/exercise_category/exercise_category_cubit.dart';

class ExerciseFilterScreenArgs {
  final List<String> allCategoryTitles;
  final String? selectedCategory;
  final bool isOffline;
  final ExerciseCategoryCubit exerciseCategoryCubit;

  const ExerciseFilterScreenArgs({
    required this.allCategoryTitles,
    this.selectedCategory,
    required this.isOffline,
    required this.exerciseCategoryCubit,
  });
}