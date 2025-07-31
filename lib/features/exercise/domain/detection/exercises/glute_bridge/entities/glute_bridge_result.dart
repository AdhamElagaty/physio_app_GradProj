import '../../../core/entities/exercise_feedback.dart';
import '../../../core/entities/exercise_result.dart';
import 'glute_bridge_tracker_result.dart';

class GluteBridgeResult extends ExerciseResult {
  final int reps;
  final double holdDurationNow;
  final GluteBridgeTrackerResult? trackerResult;
  final ExerciseFeedback? trainerFeedback;

  const GluteBridgeResult({
    required super.status,
    required this.reps,
    required this.holdDurationNow,
    this.trackerResult,
    this.trainerFeedback,
    super.feedback,
  });
}
