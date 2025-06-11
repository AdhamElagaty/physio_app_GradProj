import 'package:flutter/material.dart';

import '../../../../common_exercise/domain/entities/exercise_feedback.dart';

class ArmFeedbackItemWidget extends StatelessWidget {
  final ExerciseFeedback? feedback;
  final String label;

  const ArmFeedbackItemWidget({
    super.key,
    this.feedback,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        gradient: feedback != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  feedback!.color.backgroundColor,
                  feedback!.color.backgroundColor.withValues(alpha: 0.8),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.grey.shade800.withValues(alpha: 0.3),
                        Colors.grey.shade900.withValues(alpha: 0.2),
                      ]
                    : [
                        Colors.grey.shade100,
                        Colors.grey.shade50,
                      ],
              ),
        borderRadius: BorderRadius.circular(12.0),
        border: feedback != null
            ? Border.all(
                color: feedback!.color.borderColor.withValues(alpha: 0.6),
                width: 1.5,
              )
            : Border.all(
                color: isDark
                    ? Colors.grey.shade600.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                width: 1.0,
              ),
        boxShadow: [
          BoxShadow(
            color: feedback != null
                ? feedback!.color.borderColor.withValues(alpha: 0.15)
                : (isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.08)),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          feedback?.text ?? label,
          style: feedback != null
              ? theme.textTheme.bodySmall?.copyWith(
                  color: feedback!.color.textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  fontSize: 12.0,
                )
              : TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
