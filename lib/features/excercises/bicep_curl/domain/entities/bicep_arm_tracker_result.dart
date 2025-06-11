import '../../../../common_exercise/domain/entities/body_tracker_result.dart';
import '../../../../common_exercise/domain/entities/feedback_event.dart';

class BicepArmTrackerResult extends BodyTrackerResult {
  final bool isCorrectForm;
  final bool isVisible;
  final FeedbackEvent? feedbackEvent;

  const BicepArmTrackerResult({
    required super.status,
    required this.isVisible,
    this.feedbackEvent,
    this.isCorrectForm = false,
  });
}
