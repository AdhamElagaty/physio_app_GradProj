import '../../../../features/exercise/domain/detection/core/entities/feedback_event.dart';
import '../../../utils/device_orientation_utils/physical_orientation.dart';

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
