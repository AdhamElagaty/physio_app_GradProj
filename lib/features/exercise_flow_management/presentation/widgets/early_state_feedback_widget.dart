import 'package:flutter/material.dart';

import '../../../common_exercise/domain/entities/exercise_feedback.dart';
import '../../../common_exercise/presentation/widgets/base_feedback_card_widget.dart';

class EarlyStateFeedbackWidget extends StatefulWidget {
  final ExerciseFeedback feedback;
  final bool isInitializing;

  const EarlyStateFeedbackWidget({
    super.key,
    required this.feedback,
    this.isInitializing = false,
  });

  @override
  State<EarlyStateFeedbackWidget> createState() => _EarlyStateFeedbackWidgetState();
}

class _EarlyStateFeedbackWidgetState extends State<EarlyStateFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    if (widget.isInitializing) {
      _pulseController.repeat(reverse: true);
    }
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: BaseFeedbackCardWidget(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: widget.isInitializing ? _pulseAnimation : _fadeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isInitializing ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          widget.feedback.color.iconColor.withValues(alpha: 0.2),
                          widget.feedback.color.iconColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: widget.feedback.color.iconColor.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                    ),
                    child: Icon(
                      widget.isInitializing ? Icons.hourglass_empty_rounded : Icons.visibility_off_outlined,
                      size: 32.0,
                      color: widget.feedback.color.iconColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: widget.feedback.color.backgroundColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: widget.feedback.color.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                widget.feedback.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.feedback.color.textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
