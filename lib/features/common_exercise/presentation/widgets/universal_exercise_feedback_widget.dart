import 'package:flutter/material.dart';
import '../../../exercise_flow_management/presentation/widgets/early_state_feedback_widget.dart';
import '../../domain/entities/exercise_feedback.dart';
import '../models/metric_data.dart';
import 'base_feedback_card_widget.dart';
import 'feedback_content_widget.dart';
import 'prominent_feedback_display_widget.dart';

class UniversalExerciseFeedbackWidget extends StatelessWidget {
  final ExerciseFeedback? primaryFeedback;
  final ExerciseFeedback? secondaryFeedback;
  final IconData? primaryIcon;
  final List<MetricData> metrics;
  final Widget? progressIndicator;
  final Widget? additionalContent;
  final bool showEarlyState;
  final bool isInitializing;

  const UniversalExerciseFeedbackWidget({
    super.key,
    this.primaryFeedback,
    this.secondaryFeedback,
    this.primaryIcon,
    required this.metrics,
    this.progressIndicator,
    this.additionalContent,
    this.showEarlyState = false,
    this.isInitializing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showEarlyState) {
      return EarlyStateFeedbackWidget(
        feedback: primaryFeedback ?? ExerciseFeedback.error("Initializing..."),
        isInitializing: isInitializing,
      );
    }

    if (_shouldShowProminentOnly()) {
      return BaseFeedbackCardWidget(
        child: ProminentFeedbackDisplayWidget(
          feedback: primaryFeedback,
          iconData: primaryIcon,
        ),
      );
    }

    return BaseFeedbackCardWidget(
      child: FeedbackContentWidget(
        prominentFeedback: primaryFeedback ?? secondaryFeedback,
        prominentIcon: primaryIcon,
        metrics: metrics,
        progressIndicator: progressIndicator,
        additionalContent: additionalContent,
      ),
    );
  }

  bool _shouldShowProminentOnly() {
    return primaryFeedback != null &&
           metrics.isEmpty &&
           progressIndicator == null &&
           additionalContent == null;
  }
}
