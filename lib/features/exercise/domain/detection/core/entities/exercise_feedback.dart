import 'package:flutter/material.dart';

import 'enums/feedback_category.dart';
import 'exercise_feedback_color.dart';

class ExerciseFeedback {
  final String text;
  final ExerciseFeedbackColor color;
  final FeedbackCategory category;
  
  ExerciseFeedback(this.text, this.color, this.category);
  
  factory ExerciseFeedback.goodForm({String message = "Good form!", ExerciseFeedbackColor? color}) {
    color ??= ExerciseFeedbackColor(Color(0xFF00FF00));
    return ExerciseFeedback(message, color, FeedbackCategory.execution);
  }

  factory ExerciseFeedback.badForm(String message, {ExerciseFeedbackColor? color}) {
    color ??= ExerciseFeedbackColor(Color.fromARGB(255, 255, 42, 42));
    return ExerciseFeedback(message, color, FeedbackCategory.execution);
  }

  factory ExerciseFeedback.warningForm(String message, {ExerciseFeedbackColor? color}) {
    color ??= ExerciseFeedbackColor(Color(0xFFFFC800));
    return ExerciseFeedback(message, color, FeedbackCategory.execution);
  }

  factory ExerciseFeedback.neutral(String message, {ExerciseFeedbackColor? color}) {
    color ??= ExerciseFeedbackColor(Color(0xFFFFFFFF));
    return ExerciseFeedback(message, color, FeedbackCategory.info);
  }

  factory ExerciseFeedback.error(String message, {ExerciseFeedbackColor? color}) {
    color ??= ExerciseFeedbackColor(Color.fromARGB(255, 255, 0, 0));
    return ExerciseFeedback(message, color, FeedbackCategory.error);
  }
}
