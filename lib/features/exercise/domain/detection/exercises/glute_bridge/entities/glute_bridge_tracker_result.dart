import '../../../core/entities/body_tracker_result.dart';
import '../../../core/entities/feedback_event.dart';
import 'glute_bridge_state.dart';

class GluteBridgeTrackerResult extends BodyTrackerResult {
  final bool isVisible;
  final bool isHorizontallyOriented;
  final bool isSupine;
  final GluteBridgeState currentPoseState;
  final double holdProgress;
  final double maxHoldDuration;
  final FeedbackEvent feedbackEvent;

  const GluteBridgeTrackerResult({
    required super.status,
    required this.feedbackEvent,
    required this.isVisible,
    this.isHorizontallyOriented = false,
    this.isSupine = false,
    this.currentPoseState = GluteBridgeState.neutral,
    this.holdProgress = 0.0,
    this.maxHoldDuration = 0.0,
  });
}
