import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_logo_transparent_progress_indicator_widget.dart';

class LoadingOverlayWidget extends StatefulWidget {
  const LoadingOverlayWidget({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  State<LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<LoadingOverlayWidget> {
  OverlayEntry? _overlay;
  CustomLogoTransparentProgressIndicatorWidget? _progressIndicator;

  @override
  void initState() {
    super.initState();
    _progressIndicator = CustomLogoTransparentProgressIndicatorWidget();
  }

  @override
  void didUpdateWidget(LoadingOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isLoading != oldWidget.isLoading) {
        if (widget.isLoading) {
          _showOverlay();
        } else {
          _hideOverlay();
        }
      }
    });
  }

  void _showOverlay() {
    if (_overlay != null) return; 
    
    _overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: SizedBox(
            width: 250.w,
            height: 250.h,
            child: _progressIndicator,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
