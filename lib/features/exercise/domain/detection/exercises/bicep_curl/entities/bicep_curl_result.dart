import '../../../core/entities/exercise_feedback.dart';
import '../../../core/entities/exercise_result.dart';
import 'bicep_arm_tracker_result.dart';

class BicepCurlResult extends ExerciseResult {
  final int leftReps;
  final int rightReps;
  final BicepArmTrackerResult? leftArm;
  final BicepArmTrackerResult? rightArm;
  final int? currentRepGoal;
  final ExerciseFeedback? goalFeedback;
  final ExerciseFeedback? leftArmTrainerFeedback;
  final ExerciseFeedback? rightArmTrainerFeedback;
  final ExerciseFeedback? generalTrainerFeedback;

  const BicepCurlResult({
    required super.status,
    required this.leftReps,
    required this.rightReps,
    this.leftArm,
    this.rightArm,
    this.currentRepGoal,
    this.goalFeedback,
    this.leftArmTrainerFeedback,
    this.rightArmTrainerFeedback,
    this.generalTrainerFeedback,
  }) : super(feedback: goalFeedback);
}
