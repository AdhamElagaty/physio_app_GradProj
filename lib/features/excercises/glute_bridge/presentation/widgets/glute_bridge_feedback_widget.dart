import 'package:flutter/material.dart';

import '../../../../exercise_flow_management/presentation/widgets/exercise_progress_indicator_widget.dart';
import '../../../../common_exercise/domain/entities/exercise_feedback.dart';
import '../../../../common_exercise/presentation/models/metric_data.dart';
import '../../../../common_exercise/presentation/widgets/universal_exercise_feedback_widget.dart';
import '../../domain/entities/glute_bridge_result.dart';
import '../../domain/entities/glute_bridge_state.dart';
import '../../domain/logic/glute_bridge_tracker.dart';

class GluteBridgeFeedbackWidget extends StatelessWidget {
  const GluteBridgeFeedbackWidget({
    super.key,
    required this.result,
  });

  final GluteBridgeResult result;

  List<MetricData> _buildMetrics(BuildContext context) {
    final theme = Theme.of(context);
    final trackerResult = result.trackerResult!;

    final isActiveHold =
        trackerResult.currentPoseState == GluteBridgeState.holding ||
            trackerResult.currentPoseState == GluteBridgeState.up;

    String currentHoldDisplay = "-";
    Color holdValueColor = theme.textTheme.titleLarge?.color ?? Colors.grey;

    if (isActiveHold) {
      final holdDuration = result.holdDurationNow;
      currentHoldDisplay = "${holdDuration.toStringAsFixed(1)}s";
      holdValueColor = Colors.blueAccent;
    }

    return [
      MetricData(
        icon: Icons.repeat_rounded,
        label: "Reps",
        value: "${result.reps}",
        iconColor: Colors.deepPurpleAccent,
      ),
      MetricData(
        icon: Icons.timer_outlined,
        label: "Current Hold",
        value: currentHoldDisplay,
        iconColor: isActiveHold ? Colors.blueAccent : Colors.grey,
        valueColor: holdValueColor,
        isHighlighted: isActiveHold,
      ),
      MetricData(
        icon: Icons.star_border_rounded,
        label: "Set Max Hold",
        value: "${trackerResult.maxHoldDuration.toStringAsFixed(1)}s",
        iconColor: Colors.amber[700],
      ),
    ];
  }

  Widget? _buildProgressIndicator() {
    final trackerResult = result.trackerResult!;
    final isActiveHold =
        trackerResult.currentPoseState == GluteBridgeState.holding ||
            trackerResult.currentPoseState == GluteBridgeState.up;

    if (isActiveHold && GluteBridgeTracker.correctHoldTimeGoal > 0) {
      return ExerciseProgressIndicatorWidget(
        currentProgress: result.holdDurationNow,
        targetProgress: GluteBridgeTracker.correctHoldTimeGoal,
        progressLabel: "Target Hold",
        unit: "s",
        progressTrackColor: Colors.blueAccent.shade400,
        progressTrackCompletedColor: Colors.greenAccent.shade700,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final trackerResult = result.trackerResult;

    if (trackerResult == null || trackerResult.isVisible == false) {
      final feedback = result.trainerFeedback ??
          ExerciseFeedback.error(
            trackerResult == null
                ? "Initializing tracker..."
                : "No person detected.",
          );

      return UniversalExerciseFeedbackWidget(
        primaryFeedback: feedback,
        metrics: const [],
        showEarlyState: true,
        isInitializing: trackerResult == null,
      );
    }

    return UniversalExerciseFeedbackWidget(
      primaryFeedback: result.feedback ?? result.trainerFeedback,
      primaryIcon: result.feedback != null ? Icons.flag_circle_rounded : null,
      metrics: _buildMetrics(context),
      progressIndicator: _buildProgressIndicator(),
    );
  }
}
