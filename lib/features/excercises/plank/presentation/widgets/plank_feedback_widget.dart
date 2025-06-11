import 'package:flutter/material.dart';

import '../../../../common_exercise/domain/entities/enums/feedback_category.dart';
import '../../../../common_exercise/domain/entities/enums/feedback_type.dart';
import '../../../../exercise_flow_management/presentation/widgets/exercise_progress_indicator_widget.dart';
import '../../../../common_exercise/domain/entities/exercise_feedback.dart';
import '../../../../common_exercise/presentation/models/metric_data.dart';
import '../../../../common_exercise/presentation/widgets/universal_exercise_feedback_widget.dart';
import '../../domain/entities/plank_result.dart';
import '../../domain/entities/plank_state.dart';
import '../../domain/logic/plank_tracker.dart';

class PlankFeedbackWidget extends StatelessWidget {
  const PlankFeedbackWidget({
    super.key,
    required this.result,
  });

  final PlankResult result;

  List<MetricData> _buildMetrics(BuildContext context) {
    final theme = Theme.of(context);
    final trackerResult = result.trackerResult;

    final bool isActiveHold =
        trackerResult?.currentPoseState == PlankState.correct;

    String currentHoldDisplay = "-";
    Color holdValueColor = theme.textTheme.titleLarge?.color ?? Colors.grey;

    if (trackerResult != null && isActiveHold) {
      currentHoldDisplay = "${result.currentHoldDuration.toStringAsFixed(1)}s";
      holdValueColor = Colors.blueAccent;
    }

    return [
      MetricData(
        icon: Icons.check_circle_outline,
        label: "Holds Done",
        value: "${result.successfulHoldsCount}",
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
        value: trackerResult != null
            ? "${trackerResult.maxHoldDurationThisSet.toStringAsFixed(1)}s"
            : "-",
        iconColor: Colors.amber[700],
      ),
    ];
  }

  Widget? _buildProgressIndicator() {
    final trackerResult = result.trackerResult;
    if (trackerResult == null) return null;

    final bool isActiveHold =
        trackerResult.currentPoseState == PlankState.correct;

    if (isActiveHold && PlankTracker.correctHoldTimeGoal > 0) {
      return ExerciseProgressIndicatorWidget(
        currentProgress: result.currentHoldDuration,
        targetProgress: PlankTracker.correctHoldTimeGoal,
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

    ExerciseFeedback? primaryFeedback = result.feedback;
    if (primaryFeedback == null) {
      bool trainerFeedbackIsGeneric =
          result.trainerFeedback?.category == FeedbackCategory.processing ||
              result.trainerFeedback?.category == FeedbackCategory.processing;

      if (result.trainerFeedback != null && !trainerFeedbackIsGeneric) {
        primaryFeedback = result.trainerFeedback;
      } else if (trackerResult?.feedbackEvent != null &&
          trackerResult!.feedbackEvent.type !=
              FeedbackType.neutralProcessing) {}
      primaryFeedback ??= result.trainerFeedback;
    }

    if (trackerResult == null || trackerResult.isVisible == false) {
      final initialOrErrorFeedback = result.trainerFeedback ??
          result.feedback ??
          ExerciseFeedback.error(
            trackerResult == null
                ? "Initializing Plank..."
                : "No person detected. Please get into Plank position.",
          );

      return UniversalExerciseFeedbackWidget(
        primaryFeedback: initialOrErrorFeedback,
        metrics: _buildMetrics(context),
        showEarlyState: true,
        isInitializing: trackerResult == null,
      );
    }

    return UniversalExerciseFeedbackWidget(
      primaryFeedback: primaryFeedback,
      secondaryFeedback: (primaryFeedback != result.trainerFeedback)
          ? result.trainerFeedback
          : null,
      primaryIcon: result.feedback != null &&
              result.feedback!.category == FeedbackCategory.goal
          ? Icons.flag_circle_rounded
          : null,
      metrics: _buildMetrics(context),
      progressIndicator: _buildProgressIndicator(),
    );
  }
}
