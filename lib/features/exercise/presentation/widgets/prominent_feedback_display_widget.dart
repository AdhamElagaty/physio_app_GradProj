import 'package:flutter/material.dart';

import '../../domain/detection/core/entities/exercise_feedback.dart';

class ProminentFeedbackDisplayWidget extends StatelessWidget {
  const ProminentFeedbackDisplayWidget({super.key, 
    this.feedback,
    this.iconData
  });

  final ExerciseFeedback? feedback;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (feedback != null && feedback!.text.isNotEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
            vertical: iconData != null ? 10.0 : 8.0,
            horizontal: iconData != null ? 14.0 : 12.0
        ),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              feedback!.color.backgroundColor,
              feedback!.color.backgroundColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: feedback!.color.borderColor.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: feedback!.color.borderColor.withValues(alpha: 0.2),
              blurRadius: 12.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: feedback!.color.iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  iconData, 
                  color: feedback!.color.iconColor, 
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                feedback!.text,
                style: iconData != null
                    ? theme.textTheme.bodyMedium?.copyWith(
                        color: feedback!.color.textColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                        fontSize: 15.0,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: feedback!.color.textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        fontSize: 15.0,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isDark 
              ? Colors.grey.shade600.withValues(alpha: 0.3)
              : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.primaryColor.withValues(alpha: 0.6),
              size: 16.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              "Ready",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}