import 'package:flutter/material.dart';

import '../../../excercises/bicep_curl/domain/entities/bicep_curl_result.dart';
import '../../../excercises/bicep_curl/presentation/widgets/bicep_feedback_widget.dart';
import '../../../common_exercise/domain/entities/exercise_result.dart';
import '../../../common_exercise/presentation/widgets/universal_exercise_feedback_widget.dart';
import '../../../excercises/glute_bridge/domain/entities/glute_bridge_result.dart';
import '../../../excercises/glute_bridge/presentation/widgets/glute_bridge_feedback_widget.dart';
import '../../../excercises/plank/domain/entities/plank_result.dart';
import '../../../excercises/plank/presentation/widgets/plank_feedback_widget.dart';

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
