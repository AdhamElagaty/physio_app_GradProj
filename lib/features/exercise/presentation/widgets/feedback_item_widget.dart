import 'package:flutter/material.dart';

import '../../domain/detection/core/entities/exercise_feedback.dart';

class FeedbackItemWidget extends StatelessWidget {
  const FeedbackItemWidget({
    super.key,
    required this.feedback,
  });

  final ExerciseFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: feedback.color.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: feedback.color.borderColor, width: 1)
        ),
        child: Text(
          feedback.text,
          style: TextStyle(
            fontSize: 15, 
            color: feedback.color.textColor,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }
}
