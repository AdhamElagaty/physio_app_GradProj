import 'package:flutter/material.dart';

import '../../../model/metric_data.dart';
import '../../exercise_progress_indicator_widget.dart';
import '../../metrics_row_widget.dart';

class BicepRepCounterWidget extends StatelessWidget {
  final int leftReps;
  final int rightReps;
  final int? totalReps;
  final int? repGoal;

  const BicepRepCounterWidget({
    super.key,
    required this.leftReps,
    required this.rightReps,
    this.totalReps,
    this.repGoal,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      MetricData(
        icon: Icons.front_hand,
        label: "Left",
        value: leftReps.toString(),
        iconColor: Colors.blue,
      ),
      MetricData(
        icon: Icons.back_hand,
        label: "Right",
        value: rightReps.toString(),
        iconColor: Colors.green,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (repGoal != null && repGoal! > 0) ...[
            ExerciseProgressIndicatorWidget(
              currentProgress: (totalReps ?? (leftReps + rightReps)).toDouble(),
              targetProgress: repGoal!.toDouble(),
              progressLabel: 'Total Progress',
              unit: 'reps',
            ),
            const SizedBox(height: 4),
          ],
          MetricsRowWidget(metrics: metrics),
        ],
      ),
    );
  }
}
