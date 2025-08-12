import 'package:flutter/material.dart';
import '../model/metric_data.dart';
import 'metric_item_widget.dart';

class MetricsRowWidget extends StatelessWidget {
  final List<MetricData> metrics;
  final MainAxisAlignment alignment;
  final double spacing;

  const MetricsRowWidget({
    super.key,
    required this.metrics,
    this.alignment = MainAxisAlignment.spaceAround,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metrics.asMap().entries.map((entry) {
        final isLast = entry.key == metrics.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: MetricItemWidget(
              icon: entry.value.icon,
              label: entry.value.label,
              value: entry.value.value,
              iconColor: entry.value.iconColor,
              valueColor: entry.value.valueColor,
              isHighlighted: entry.value.isHighlighted,
            ),
          ),
        );
      }).toList(),
    );
  }
}

