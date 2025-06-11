import 'package:flutter/material.dart';

class ExerciseProgressIndicatorWidget extends StatefulWidget {
  final double currentProgress;
  final double targetProgress;
  final String progressLabel;
  final String unit;
  final Color? progressTrackColor;
  final Color? progressTrackCompletedColor;

  const ExerciseProgressIndicatorWidget({
    super.key,
    required this.currentProgress,
    required this.targetProgress,
    required this.progressLabel,
    this.unit = "",
    this.progressTrackColor,
    this.progressTrackCompletedColor,
  });

  @override
  State<ExerciseProgressIndicatorWidget> createState() => _ExerciseProgressIndicatorWidgetState();
}

class _ExerciseProgressIndicatorWidgetState extends State<ExerciseProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = widget.targetProgress > 0 ? (widget.currentProgress / widget.targetProgress) : 0.0;
    final cappedPercent = percent.clamp(0.0, 1.0);
    
    String progressText;
    if (widget.targetProgress > 0) {
      progressText = '${widget.currentProgress.toStringAsFixed(0)} / ${widget.targetProgress.toStringAsFixed(0)} ${widget.unit}'.trim();
    } else {
      progressText = '${widget.currentProgress.toStringAsFixed(0)} ${widget.unit}'.trim();
    }
    
    if (widget.targetProgress <= 0) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? [
                  Colors.grey.shade800.withValues(alpha: 0.3),
                  Colors.grey.shade900.withValues(alpha: 0.2),
                ]
              : [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
          ),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDark 
              ? Colors.grey.shade700.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.progressLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.1,
                fontSize: 11.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                progressText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  letterSpacing: 0.1,
                  fontSize: 10.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color trackColor = widget.progressTrackColor ?? theme.primaryColor;
    if (cappedPercent >= 1.0 && widget.progressTrackCompletedColor != null) {
      trackColor = widget.progressTrackCompletedColor!;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [
                Colors.grey.shade800.withValues(alpha: 0.3),
                Colors.grey.shade900.withValues(alpha: 0.2),
              ]
            : [
                Colors.grey.shade50,
                Colors.grey.shade100,
              ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark 
            ? Colors.grey.shade700.withValues(alpha: 0.3)
            : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.progressLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                  fontSize: 11.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: trackColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  progressText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: trackColor,
                    letterSpacing: 0.1,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Colors.grey.shade700.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Container(
                    height: 8.0,
                    width: MediaQuery.of(context).size.width * cappedPercent * _progressAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          trackColor,
                          trackColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: trackColor.withValues(alpha: 0.3),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
