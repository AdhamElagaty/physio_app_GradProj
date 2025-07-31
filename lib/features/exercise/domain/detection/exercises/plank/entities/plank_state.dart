import '../../../core/entities/exercise_state.dart';

enum PlankState implements ExerciseState {
  neutral,
  notPlanking,
  correct,
  highHips,
  lowHips,
  adjusting,
}
