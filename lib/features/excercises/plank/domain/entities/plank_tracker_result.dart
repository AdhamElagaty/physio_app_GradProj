import '../../../../common_exercise/domain/entities/body_tracker_result.dart';
import '../../../../common_exercise/domain/entities/feedback_event.dart';
import 'plank_state.dart';

class PlankTrackerResult extends BodyTrackerResult {
  final bool isVisible;
  final PlankState currentPoseState;
  final double holdProgress;
  final double currentHoldDuration;
  final double maxHoldDurationThisSet;
  final FeedbackEvent feedbackEvent;

  const PlankTrackerResult({
    required super.status,
    required this.feedbackEvent,
    required this.isVisible,
    this.currentPoseState = PlankState.neutral,
    this.holdProgress = 0.0,
    this.currentHoldDuration = 0.0,
    this.maxHoldDurationThisSet = 0.0,
  });
}
