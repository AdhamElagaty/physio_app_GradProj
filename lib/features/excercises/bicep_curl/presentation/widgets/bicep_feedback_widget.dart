import 'package:flutter/material.dart';

import '../../../../exercise_flow_management/presentation/widgets/exercise_progress_indicator_widget.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_category.dart';
import '../../../../common_exercise/presentation/models/metric_data.dart';
import '../../../../common_exercise/presentation/widgets/universal_exercise_feedback_widget.dart';
import '../../domain/entities/bicep_curl_result.dart';
import 'arm_feedback_widget.dart';

class BicepFeedbackWidget extends StatelessWidget {
  const BicepFeedbackWidget({
    super.key,
    required this.result,
  });

  final BicepCurlResult result;

  List<MetricData> _buildMetrics() {
    return [
      MetricData(
        icon: Icons.fitness_center,
        label: "Left Reps",
        value: result.leftReps.toString(),
        iconColor: Colors.blueAccent,
      ),
      MetricData(
        icon: Icons.fitness_center,
        label: "Right Reps",
        value: result.rightReps.toString(),
        iconColor: Colors.greenAccent.shade700,
      ),
    ];
  }

  Widget? _buildProgressIndicator() {
    if (result.currentRepGoal != null && result.currentRepGoal! > 0) {
      return ExerciseProgressIndicatorWidget(
        currentProgress: (result.leftReps + result.rightReps).toDouble(),
        targetProgress: result.currentRepGoal!.toDouble(),
        progressLabel: 'Total Progress',
        unit: 'reps',
      );
    }
    return null;
  }

  Widget? _buildArmFeedback() {
    return ArmFeedbackWidget(
      leftArmFeedback: result.leftArmTrainerFeedback,
      rightArmFeedback: result.rightArmTrainerFeedback,
    );
  }

  bool _isEarlyState() {
    return result.leftReps == 0 &&
        result.rightReps == 0 &&
        result.leftArmTrainerFeedback == null &&
        result.rightArmTrainerFeedback == null &&
        result.goalFeedback == null &&
        result.generalTrainerFeedback != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEarlyState()) {
      final isInitializing = result.generalTrainerFeedback?.text
              .toLowerCase()
              .contains('initializing') ??
          false;

      return UniversalExerciseFeedbackWidget(
        primaryFeedback: result.generalTrainerFeedback,
        metrics: const [],
        showEarlyState: true,
        isInitializing: isInitializing,
      );
    }

    final isGeneralError =
        result.generalTrainerFeedback?.category == FeedbackCategory.error;
    final showProminentOnly = isGeneralError &&
        result.leftArmTrainerFeedback == null &&
        result.rightArmTrainerFeedback == null &&
        result.goalFeedback == null;

    return UniversalExerciseFeedbackWidget(
      primaryFeedback: result.goalFeedback ?? result.generalTrainerFeedback,
      primaryIcon:
          result.goalFeedback != null ? Icons.flag_circle_rounded : null,
      metrics: showProminentOnly ? [] : _buildMetrics(),
      progressIndicator: showProminentOnly ? null : _buildProgressIndicator(),
      additionalContent: showProminentOnly ? null : _buildArmFeedback(),
    );
  }
}
