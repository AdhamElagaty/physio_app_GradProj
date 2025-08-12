import 'package:flutter/material.dart';

import '../../../../core/utils/styles/app_colors.dart';

class OtpFieldBox extends StatefulWidget {
  final String text;
  final bool isFocused;
  final bool isPasting;
  final bool isRemoving;
  final bool isSuccess;
  final bool isError;
  final int index;
  final VoidCallback? onAnimationComplete;

  const OtpFieldBox({
    super.key, 
    required this.text, 
    required this.isFocused,
    this.isPasting = false,
    this.isRemoving = false,
    this.isSuccess = false,
    this.isError = false,
    this.index = 0,
    this.onAnimationComplete,
  });

  @override
  State<OtpFieldBox> createState() => _OtpFieldBoxState();
}

class _OtpFieldBoxState extends State<OtpFieldBox>
    with TickerProviderStateMixin {
  late AnimationController _writeController;
  late AnimationController _removeController;
  late AnimationController _pasteController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _errorController;
  
  // Write animations
  late Animation<double> _writeScaleAnimation;
  late Animation<double> _writeFadeAnimation;
  late Animation<Offset> _writeSlideAnimation;
  late Animation<double> _writeRotateAnimation;
  
  // Remove animations
  late Animation<double> _removeScaleAnimation;
  late Animation<double> _removeFadeAnimation;
  late Animation<Offset> _removeSlideAnimation;
  
  // Paste animations
  late Animation<double> _pasteScaleAnimation;
  late Animation<double> _pasteFadeAnimation;
  late Animation<Offset> _pasteSlideAnimation;
  late Animation<double> _pasteGlowAnimation;
  
  // Success animations
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successGlowAnimation;
  late Animation<Color?> _successColorAnimation;
  
  // Error animations
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _errorScaleAnimation;
  late Animation<Color?> _errorColorAnimation;
  
  // Pulse animation for focus
  late Animation<double> _pulseAnimation;
  
  String _previousText = '';
  bool _wasPasting = false;
  bool _wasRemoving = false;
  bool _wasSuccess = false;
  bool _wasError = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousText = widget.text;
    _wasPasting = widget.isPasting;
    _wasRemoving = widget.isRemoving;
    _wasSuccess = widget.isSuccess;
    _wasError = widget.isError;
    
    if (widget.text.isNotEmpty) {
      _playWriteAnimation();
    }
  }

  void _initializeAnimations() {
    // Write animation controller
    _writeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _writeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _writeController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _writeFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _writeController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    _writeSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _writeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    ));

    _writeRotateAnimation = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _writeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    // Remove animation controller
    _removeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _removeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInBack),
    ));

    _removeFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _removeSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.0),
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInCubic),
    ));

    // Paste animation controller
    _pasteController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pasteScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pasteController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    _pasteFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pasteController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));

    _pasteSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pasteController,
      curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
    ));

    _pasteGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pasteController,
      curve: Curves.easeInOut,
    ));

    // Success animation controller
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _successScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    ));

    _successGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _successColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppColors.teal.withValues(alpha: 0.3),
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    // Error animation controller
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _errorShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _errorScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));

    _errorColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withValues(alpha: 0.3),
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    // Pulse animation for focus
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Add status listeners
    _writeController.addStatusListener(_onAnimationStatusChanged);
    _removeController.addStatusListener(_onAnimationStatusChanged);
    _pasteController.addStatusListener(_onAnimationStatusChanged);
    _successController.addStatusListener(_onAnimationStatusChanged);
    _errorController.addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      widget.onAnimationComplete?.call();
    }
  }

  void _playWriteAnimation() {
    _isAnimating = true;
    _writeController.reset();
    _writeController.forward();
  }

  void _playRemoveAnimation() {
    _isAnimating = true;
    _removeController.reset();
    _removeController.forward();
  }

  void _playPasteAnimation() {
    _isAnimating = true;
    final delay = Duration(milliseconds: widget.index * 80);
    Future.delayed(delay, () {
      if (mounted) {
        _pasteController.reset();
        _pasteController.forward();
      }
    });
  }

  void _playSuccessAnimation() {
    _isAnimating = true;
    final delay = Duration(milliseconds: widget.index * 60);
    Future.delayed(delay, () {
      if (mounted) {
        _successController.reset();
        _successController.forward();
      }
    });
  }

  void _playErrorAnimation() {
    _isAnimating = true;
    _errorController.reset();
    _errorController.forward();
  }

  void _startPulse() {
    if (!_isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  void didUpdateWidget(OtpFieldBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle focus changes
    if (widget.isFocused != oldWidget.isFocused) {
      if (widget.isFocused && widget.text.isEmpty) {
        _startPulse();
      } else {
        _stopPulse();
      }
    }

    // Handle success state
    if (widget.isSuccess && !_wasSuccess) {
      _playSuccessAnimation();
    }
    
    // Handle error state
    else if (widget.isError && !_wasError) {
      _playErrorAnimation();
    }
    
    // Handle paste animation
    else if (widget.isPasting && !_wasPasting && widget.text.isNotEmpty) {
      _playPasteAnimation();
    }
    // Handle remove animation
    else if (widget.isRemoving && !_wasRemoving && widget.text.isEmpty && _previousText.isNotEmpty) {
      _playRemoveAnimation();
    }
    // Handle regular text changes (not paste or remove)
    else if (widget.text != _previousText && !widget.isPasting && !widget.isRemoving && !widget.isSuccess && !widget.isError) {
      if (widget.text.isNotEmpty && _previousText.isEmpty) {
        // Number added
        _playWriteAnimation();
      } else if (widget.text.isEmpty && _previousText.isNotEmpty) {
        // Number removed (normal backspace)
        _playRemoveAnimation();
      } else if (widget.text.isNotEmpty && _previousText.isNotEmpty) {
        // Number changed
        _playWriteAnimation();
      }
    }
    
    _previousText = widget.text;
    _wasPasting = widget.isPasting;
    _wasRemoving = widget.isRemoving;
    _wasSuccess = widget.isSuccess;
    _wasError = widget.isError;
  }

  @override
  void dispose() {
    _writeController.dispose();
    _removeController.dispose();
    _pasteController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText() {
    if (widget.text.isEmpty && !_wasError && !_removeController.isAnimating) {
      return const SizedBox.shrink();
    }

    Widget textWidget = Text(
      widget.text.isEmpty ? _previousText : widget.text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: widget.isSuccess 
            ? AppColors.teal 
            : widget.isError 
                ? AppColors.red 
                : null,
      ),
      textAlign: TextAlign.center,
    );

    if (widget.isError) {
      return AnimatedBuilder(
        animation: _errorController,
        builder: (context, child) {
          final shake = _errorShakeAnimation.value;
          final offset = Offset(
            10 * (shake < 0.5 ? shake * 2 : (1 - shake) * 2) * 
            (shake < 0.25 || (shake > 0.5 && shake < 0.75) ? 1 : -1),
            0,
          );
          
          return Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: _errorScaleAnimation.value,
              child: textWidget,
            ),
          );
        },
      );
    } else if (widget.isSuccess) {
      return AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          return Transform.scale(
            scale: _successScaleAnimation.value,
            child: textWidget,
          );
        },
      );
    } else if (widget.isPasting) {
      return AnimatedBuilder(
        animation: _pasteController,
        builder: (context, child) {
          return Transform.rotate(
            angle: (1 - _pasteGlowAnimation.value) * 0.1,
            child: FadeTransition(
              opacity: _pasteFadeAnimation,
              child: SlideTransition(
                position: _pasteSlideAnimation,
                child: ScaleTransition(
                  scale: _pasteScaleAnimation,
                  child: textWidget,
                ),
              ),
            ),
          );
        },
      );
    } else if (widget.isRemoving && _previousText.isNotEmpty) {
      return AnimatedBuilder(
        animation: _removeController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _removeFadeAnimation,
            child: SlideTransition(
              position: _removeSlideAnimation,
              child: ScaleTransition(
                scale: _removeScaleAnimation,
                child: Text(
                  _previousText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );
    } else {
      return AnimatedBuilder(
        animation: _writeController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _writeRotateAnimation.value,
            child: FadeTransition(
              opacity: _writeFadeAnimation,
              child: SlideTransition(
                position: _writeSlideAnimation,
                child: ScaleTransition(
                  scale: _writeScaleAnimation,
                  child: textWidget,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Flexible(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _successController, _errorController]),
        builder: (context, child) {
          Color? overlayColor;
          if (widget.isSuccess) {
            overlayColor = _successColorAnimation.value;
          } else if (widget.isError) {
            overlayColor = _errorColorAnimation.value;
          }

          return Transform.scale(
            scale: widget.isFocused && widget.text.isEmpty ? _pulseAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 60.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: overlayColor ?? (widget.isFocused 
                    ? colorScheme.primary.withValues(alpha: 0.1) 
                    : colorScheme.surface.withValues(alpha: 0.5)),
                border: Border.all(
                  color: widget.isSuccess 
                      ? AppColors.teal
                      : widget.isError 
                          ? AppColors.red
                          : widget.isFocused 
                              ? colorScheme.primary 
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                  width: (widget.isSuccess || widget.isError || widget.isFocused) ? 2.0 : 1.0,
                ),
                boxShadow: [
                  if (widget.isFocused && !widget.isSuccess && !widget.isError)
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  if (widget.isSuccess)
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.4 * _successGlowAnimation.value),
                      blurRadius: 15.0 * _successGlowAnimation.value,
                      offset: const Offset(0, 0),
                    ),
                  if (widget.isPasting)
                    BoxShadow(
                      color: colorScheme.secondary.withValues(
                        alpha: 0.4 * _pasteGlowAnimation.value,
                      ),
                      blurRadius: 20.0 * _pasteGlowAnimation.value,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: Center(
                child: SelectionContainer.disabled(
                  child: _buildAnimatedText(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}