import 'package:flutter/material.dart';

import '../../domain/detection/exercises/bicep_curl/entities/bicep_curl_result.dart';
import 'specific_exercise/bicep_curl/bicep_feedback_widget.dart';
import '../../domain/detection/core/entities/exercise_result.dart';
import 'universal_exercise_feedback_widget.dart';
import '../../domain/detection/exercises/glute_bridge/entities/glute_bridge_result.dart';
import '../../domain/detection/exercises/plank/entities/plank_result.dart';
import 'specific_exercise/plank/plank_feedback_widget.dart';
import 'specific_exercise/glute_bridge/glute_bridge_feedback_widget.dart';

class FeedbackDisplayWidget extends StatelessWidget {
  final ExerciseResult? exerciseResult;

  const FeedbackDisplayWidget({super.key, this.exerciseResult});

  @override
  Widget build(BuildContext context) {
    if (exerciseResult == null) {
      return const SizedBox.shrink();
    }

    switch (exerciseResult) {
      case GluteBridgeResult gluteBridgeResult:
        return GluteBridgeFeedbackWidget(result: gluteBridgeResult);
      case BicepCurlResult bicepCurlResult:
        return BicepFeedbackWidget(result: bicepCurlResult);
      case PlankResult plankResult:
        return PlankFeedbackWidget(result: plankResult);
      default:
        return UniversalExerciseFeedbackWidget(
          primaryFeedback: exerciseResult?.feedback,
          metrics: const [],
          showEarlyState: exerciseResult?.feedback == null,
        );
    }
  }
}
