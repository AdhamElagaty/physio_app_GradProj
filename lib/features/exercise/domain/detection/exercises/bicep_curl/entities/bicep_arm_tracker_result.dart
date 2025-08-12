import '../../../core/entities/body_tracker_result.dart';
import '../../../core/entities/feedback_event.dart';

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
