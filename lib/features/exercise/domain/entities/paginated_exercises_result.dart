import '../../../../core/entities/paginated_result.dart';
import 'exercise.dart';

class PaginatedExercisesResult extends PaginatedResult<Exercise> {
  PaginatedExercisesResult({
    required super.items,
    required super.hasNextPage,
    super.hasPreviousPage,
  });
}
