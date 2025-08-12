import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;
  bool _isStreaming = false;

  Future<bool> initialize() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        debugPrint("Camera permission denied");
        return false;
      }
    }

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      debugPrint("No cameras available");
      return false;
    }
    _selectedCameraIdx = _cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (_selectedCameraIdx == -1) _selectedCameraIdx = 0;

    return _initializeCameraController();
  }

  Future<bool> _initializeCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) return false;
    final cameraDescription = _cameras![_selectedCameraIdx];
    final imageFormatGroup = Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888;
    
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );

    try {
      await _cameraController!.initialize();
      debugPrint("Camera initialized: ${cameraDescription.name}");
      return true;
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      _cameraController?.dispose();
      _cameraController = null;
      return false;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras!.length;
    
    final bool wasStreaming = _isStreaming;
    if (wasStreaming) await stopImageStream();
    await _cameraController?.dispose();

    await _initializeCameraController();
    if (wasStreaming && _cameraController != null && _cameraController!.value.isInitialized) {
    }
  }

  CameraLensDirection get currentLensDirection {
    if (_cameraController == null || _cameras == null) return CameraLensDirection.external;
    return _cameras![_selectedCameraIdx].lensDirection;
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      await _cameraController!.startImageStream(onImage);
      _isStreaming = true;
      debugPrint("Camera stream started");
    }
  }

  Future<void> stopImageStream() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
      _isStreaming = false;
      debugPrint("Camera stream stopped");
    }
  }

  void dispose() {
    _isStreaming = false;
    _cameraController?.dispose();
    _cameraController = null;
    debugPrint("CameraService disposed");
  }
}