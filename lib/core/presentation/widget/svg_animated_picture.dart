import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SvgAnimatedPicture extends StatefulWidget {
  const SvgAnimatedPicture({
    super.key,
    required this.svgMarkup,
    this.controller,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
  });

  final String svgMarkup;

  final SvgAnimationController? controller;

  final BoxFit fit;

  final Widget? placeholder;

  final Widget? errorWidget;

  @override
  State<SvgAnimatedPicture> createState() => _SvgAnimatedPictureState();
}

class _SvgAnimatedPictureState extends State<SvgAnimatedPicture> {
  late final WebViewController _webViewController;
  
  late Uri _dataUri;

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _dataUri = _generateDataUri(widget.svgMarkup, widget.fit);
    _initWebView();
    widget.controller?._attach(_webViewController);
  }

  @override
  void didUpdateWidget(SvgAnimatedPicture oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Attach/detach controller if it has changed.
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(_webViewController);
    }

    if (widget.svgMarkup != oldWidget.svgMarkup || widget.fit != oldWidget.fit) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _dataUri = _generateDataUri(widget.svgMarkup, widget.fit);
      });
      _webViewController.loadRequest(_dataUri);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          });
        },
        onWebResourceError: (error) {
          log('WebView error: ${error.description}', error: error.errorCode, name: 'SvgAnimatedPicture');
          if (mounted) {
             setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ))
      ..addJavaScriptChannel(
        'SVGatorFlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          log('Received message from SVG: ${message.message}');
        },
      )
      ..loadRequest(_dataUri);
  }

  Uri _generateDataUri(String svg, BoxFit fit) {
    final fitValue = _getFitValue(fit);

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <style>
    body, html {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: transparent;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    svg {
      width: 100%;
      height: 100%;
      object-fit: $fitValue;
      user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none; /* IE 10+ */
    }
  </style>
</head>
<body>
  $svg
</body>
</html>
''';

    return Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );
  }

  String _getFitValue(BoxFit fit) {
    switch (fit) {
      case BoxFit.cover: return 'cover';
      case BoxFit.fill: return 'fill';
      case BoxFit.none: return 'none';
      case BoxFit.scaleDown: return 'scale-down';
      case BoxFit.contain:
      default:
        return 'contain';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          widget.placeholder ??
              const Center(child: CircularProgressIndicator()),
        if (_hasError)
          widget.errorWidget ??
              const Center(
                child: Icon(Icons.error_outline, color: Colors.red, size: 48.0),
              ),
      ],
    );
  }
}

class SvgAnimationController extends ChangeNotifier {
  WebViewController? _webViewController;

  void _attach(WebViewController controller) {
    _webViewController = controller;
  }

  void _detach() {
    _webViewController = null;
  }

  Future<void> play() async => _runJavascript('window.svgator.play()');
  Future<void> pause() async => _runJavascript('window.svgator.pause()');
  Future<void> stop() async => _runJavascript('window.svgator.stop()');
  Future<void> restart() async => _runJavascript('window.svgator.restart()');

  Future<void> _runJavascript(String script) async {
    if (_webViewController == null) {
      log('Warning: SvgAnimationController is not attached to a SvgAnimatedPicture widget.');
      return;
    }
    try {
      await _webViewController!.runJavaScript(script);
    } catch (e) {
      log('Error executing JavaScript on SVG: $e');
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }
}
