import 'package:flutter/material.dart';

class BaseFeedbackCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const BaseFeedbackCardWidget({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                theme.cardColor.withValues(alpha: 0.95),
                theme.cardColor.withValues(alpha: 0.85),
              ]
            : [
                Colors.white,
                Colors.grey.shade50,
              ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 15.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
            blurRadius: 8.0,
            spreadRadius: -5.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
