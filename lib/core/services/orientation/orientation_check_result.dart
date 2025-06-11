import 'package:gradproject/core/utils/device_orientation_utils/physical_orientation.dart';
import 'package:gradproject/features/common_exercise/domain/entities/feedback_event.dart';

class OrientationCheckResult {
  final bool isOrientedCorrectly;
  final FeedbackEvent feedbackEvent;
  final PhysicalOrientation physicalOrientation;

  OrientationCheckResult(
    this.isOrientedCorrectly,
    this.feedbackEvent,
    this.physicalOrientation,
  );
}
