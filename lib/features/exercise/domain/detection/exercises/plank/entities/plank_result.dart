import '../../../core/entities/exercise_feedback.dart';
import '../../../core/entities/exercise_result.dart';
import 'plank_tracker_result.dart';

class PlankResult extends ExerciseResult {
  final int successfulHoldsCount;
  final double currentHoldDuration;
  final PlankTrackerResult? trackerResult;
  final ExerciseFeedback? trainerFeedback;

  const PlankResult({
    required super.status,
    required this.successfulHoldsCount,
    required this.currentHoldDuration,
    this.trackerResult,
    this.trainerFeedback,
    super.feedback,
  });
}
