import 'package:gradproject/features/common_exercise/domain/entities/enums/feedback_type.dart';

class OrientationFeedbackTypes {
  final FeedbackType setupHoldOrientation;
  final FeedbackType setupPersonNotOriented;
  final FeedbackType setupSuccess;
  final FeedbackType setupVisibilityPartial;
  final FeedbackType setupPhoneAccelerometerWait;
  final FeedbackType setupPhoneOrientationIssue;

  OrientationFeedbackTypes({
    required this.setupHoldOrientation,
    required this.setupPersonNotOriented,
    required this.setupSuccess,
    required this.setupVisibilityPartial,
    required this.setupPhoneAccelerometerWait,
    required this.setupPhoneOrientationIssue,
  });
}
