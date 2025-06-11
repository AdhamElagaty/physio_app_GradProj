import '../../../../common_exercise/domain/entities/exercise_state.dart';

enum PlankState implements ExerciseState {
  neutral,
  notPlanking,
  correct,
  highHips,
  lowHips,
  adjusting,
}
