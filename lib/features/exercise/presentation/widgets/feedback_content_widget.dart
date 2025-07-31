import 'package:flutter/material.dart';
import '../../domain/detection/core/entities/exercise_feedback.dart';
import '../model/metric_data.dart';
import 'metrics_row_widget.dart';
import 'prominent_feedback_display_widget.dart';

class FeedbackContentWidget extends StatelessWidget {
  final ExerciseFeedback? prominentFeedback;
  final IconData? prominentIcon;
  final List<MetricData> metrics;
  final Widget? progressIndicator;
  final Widget? additionalContent;

  const FeedbackContentWidget({
    super.key,
    this.prominentFeedback,
    this.prominentIcon,
    required this.metrics,
    this.progressIndicator,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProminentFeedbackDisplayWidget(
          feedback: prominentFeedback,
          iconData: prominentIcon,
        ),
        if (metrics.isNotEmpty) ...[
          MetricsRowWidget(metrics: metrics),
          const SizedBox(height: 6.0),
        ],
        if (progressIndicator != null) ...[
          progressIndicator!,
          const SizedBox(height: 6.0),
        ],
        if (additionalContent != null)
          additionalContent!,
      ],
    );
  }
}
