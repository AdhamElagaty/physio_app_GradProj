import 'package:flutter/material.dart';

class MetricItemWidget extends StatelessWidget {
  const MetricItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveValueColor = valueColor ?? theme.textTheme.titleMedium?.color;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: isHighlighted 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveIconColor.withValues(alpha: 0.1),
                effectiveIconColor.withValues(alpha: 0.05),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [
                    Colors.grey.shade800.withValues(alpha: 0.3),
                    Colors.grey.shade900.withValues(alpha: 0.2),
                  ]
                : [
                    Colors.grey.shade50,
                    Colors.grey.shade100.withValues(alpha: 0.5),
                  ],
            ),
        borderRadius: BorderRadius.circular(16.0),
        border: isHighlighted 
          ? Border.all(
              color: effectiveIconColor.withValues(alpha: 0.4),
              width: 2.0,
            )
          : Border.all(
              color: isDark 
                ? Colors.grey.shade700.withValues(alpha: 0.3)
                : Colors.grey.shade200,
              width: 1.0,
            ),
        boxShadow: isHighlighted
          ? [
              BoxShadow(
                color: effectiveIconColor.withValues(alpha: 0.2),
                blurRadius: 12.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: isDark 
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.08),
                blurRadius: 8.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon, 
              color: effectiveIconColor, 
              size: isHighlighted ? 22.0 : 20.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1.0),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: effectiveValueColor,
              fontSize: isHighlighted ? 15.0 : 14.0,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
