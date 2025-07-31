import '../../../../core/entities/paginated_result.dart';
import 'exercise_history.dart';

class PaginatedExerciseHistoriesResult extends PaginatedResult<ExerciseHistory> {
  PaginatedExerciseHistoriesResult({
    required super.items,
    required super.hasNextPage,
    super.hasPreviousPage,
  });
}
