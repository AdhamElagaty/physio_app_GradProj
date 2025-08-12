import 'package:flutter/material.dart';

import '../../../../domain/detection/core/entities/exercise_feedback.dart';
import 'arm_feedback_item_widget.dart';

class ArmFeedbackWidget extends StatelessWidget {
  final ExerciseFeedback? leftArmFeedback;
  final ExerciseFeedback? rightArmFeedback;
  final String leftLabel;
  final String rightLabel;

  const ArmFeedbackWidget({
    super.key,
    this.leftArmFeedback,
    this.rightArmFeedback,
    this.leftLabel = "Left Arm",
    this.rightLabel = "Right Arm",
  });

  @override
  Widget build(BuildContext context) {
    if (leftArmFeedback == null && rightArmFeedback == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: ArmFeedbackItemWidget(
            feedback: leftArmFeedback,
            label: leftLabel,
          ),
        ),
        const SizedBox(width: 6.0),
        Expanded(
          child: ArmFeedbackItemWidget(
            feedback: rightArmFeedback,
            label: rightLabel,
          ),
        ),
      ],
    );
  }
}
