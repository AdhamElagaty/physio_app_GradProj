import 'exercise_feedback.dart';

abstract class ExerciseResult {
  final bool status;
  final ExerciseFeedback? feedback;

  const ExerciseResult({
    required this.status,
    this.feedback,
  });
}