import '../../../../common_exercise/domain/entities/exercise_state.dart';

enum GluteBridgeState implements ExerciseState {
  neutral,
  down,
  up,
  holding,
}
